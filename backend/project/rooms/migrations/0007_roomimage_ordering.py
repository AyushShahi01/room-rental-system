from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('rooms', '0006_room_additional_description_room_fixed_duration_type_and_more'),
    ]

    operations = [
        migrations.AlterModelOptions(
            name='roomimage',
            options={'ordering': ('-created_at', '-id')},
        ),
    ]
