from rest_framework import serializers
from django.contrib.auth import authenticate, get_user_model
from django.contrib.auth.password_validation import validate_password

from .models import CustomUser


class UserSerializer(serializers.ModelSerializer):
    tenant_id = serializers.SerializerMethodField()
    landlord_id = serializers.SerializerMethodField()

    class Meta:
        model = CustomUser
        fields = [
            'id',
            'username',
            'email',
            'first_name',
            'last_name',
            'role',
            'tenant_id',
            'landlord_id',
            'province',
            'district',
            'city',
            'ward',
        ]
        read_only_fields = ['id']

    def get_tenant_id(self, obj):
        if obj.role == CustomUser.Role.TENANT:
            return obj.id
        return None

    def get_landlord_id(self, obj):
        if obj.role == CustomUser.Role.LANDLORD:
            return obj.id
        return None


class TokenPairSerializer(serializers.Serializer):
    refresh = serializers.CharField()
    access = serializers.CharField()


class AuthResponseSerializer(serializers.Serializer):
    message = serializers.CharField()
    tokens = TokenPairSerializer()
    user = UserSerializer()


class MessageResponseSerializer(serializers.Serializer):
    message = serializers.CharField()


class ErrorResponseSerializer(serializers.Serializer):
    error = serializers.CharField()


class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)
    ward = serializers.IntegerField(required=False, allow_null=True)

    class Meta:
        model = CustomUser
        fields = [
            'username',
            'email',
            'password',
            'role',
            'province',
            'district',
            'city',
            'ward',
        ]

    def validate_password(self, value):
        validate_password(value)
        return value

    def validate_role(self, value):
        allowed = {choice[0] for choice in CustomUser.Role.choices}
        if value not in allowed:
            raise serializers.ValidationError('Role must be either tenant or landlord.')
        return value

    def validate(self, attrs):
        role = attrs.get('role', CustomUser.Role.TENANT)

        if role == CustomUser.Role.LANDLORD:
            required_fields = ['province', 'district', 'city', 'ward']
            errors = {}
            for field in required_fields:
                value = attrs.get(field)
                if value in (None, ''):
                    errors[field] = [f'{field} is required for landlord registration.']

            ward = attrs.get('ward')
            if ward is not None and ward <= 0:
                errors['ward'] = ['ward must be a positive number.']

            if errors:
                raise serializers.ValidationError(errors)
        else:
            attrs['province'] = None
            attrs['district'] = None
            attrs['city'] = None
            attrs['ward'] = None

        return attrs

    def create(self, validated_data):
        user = CustomUser.objects.create_user(
            username=validated_data['username'],
            email=validated_data.get('email', ''),
            password=validated_data['password'],
            role=validated_data.get('role', CustomUser.Role.TENANT),
            province=validated_data.get('province'),
            district=validated_data.get('district'),
            city=validated_data.get('city'),
            ward=validated_data.get('ward'),
        )
        return user


class LoginSerializer(serializers.Serializer):
    usernameOrEmail = serializers.CharField(required=False, allow_blank=True)
    username = serializers.CharField(required=False, allow_blank=True)
    email = serializers.EmailField(required=False)
    password = serializers.CharField(write_only=True)

    def validate(self, attrs):
        username_or_email = attrs.get('usernameOrEmail')
        username = attrs.get('username')
        email = attrs.get('email')
        password = attrs.get('password')

        identifier = username_or_email or username or email

        if not identifier:
            raise serializers.ValidationError({'non_field_errors': ['Provide username or email.']})

        resolved_username = identifier
        if '@' in identifier and not username:
            user_model = get_user_model()
            email_matches = user_model.objects.filter(email__iexact=identifier).order_by('id')
            count = email_matches.count()
            if count == 0:
                raise serializers.ValidationError({'non_field_errors': ['Invalid username/email or password.']})
            if count > 1:
                raise serializers.ValidationError({'non_field_errors': ['Multiple accounts use this email. Please login with username.']})
            resolved_username = email_matches.first().username

        user = authenticate(username=resolved_username, password=password)
        if not user:
            raise serializers.ValidationError({'non_field_errors': ['Invalid username/email or password.']})
        if not user.is_active:
            raise serializers.ValidationError({'non_field_errors': ['User account is disabled.']})

        attrs['user'] = user
        return attrs


class LogoutSerializer(serializers.Serializer):
    refresh = serializers.CharField()


class ChangePasswordSerializer(serializers.Serializer):
    old_password = serializers.CharField(write_only=True)
    new_password = serializers.CharField(write_only=True)
    new_password_confirm = serializers.CharField(write_only=True)

    def validate(self, attrs):
        request = self.context.get('request')
        user = getattr(request, 'user', None)

        if not user or not user.is_authenticated:
            raise serializers.ValidationError({'non_field_errors': ['Authentication required.']})

        if not user.check_password(attrs['old_password']):
            raise serializers.ValidationError({'old_password': ['Current password is incorrect.']})

        if attrs['new_password'] != attrs['new_password_confirm']:
            raise serializers.ValidationError({'new_password_confirm': ['New passwords do not match.']})

        validate_password(attrs['new_password'], user=user)
        return attrs
