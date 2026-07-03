from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('agreements', '0003_agreement_created_at_agreement_signed_at'),
    ]

    operations = [
        migrations.AddField(
            model_name='agreement',
            name='rent_price',
            field=models.DecimalField(decimal_places=2, default=0, max_digits=10),
            preserve_default=False,
        ),
        migrations.AddField(
            model_name='agreement',
            name='rent_mode',
            field=models.CharField(choices=[('fixed', 'Fixed'), ('increment', 'Increment')], default='fixed', max_length=20),
            preserve_default=False,
        ),
        migrations.AddField(
            model_name='agreement',
            name='fixed_duration_type',
            field=models.CharField(blank=True, choices=[('months', 'Months'), ('years', 'Years')], max_length=10, null=True),
        ),
        migrations.AddField(
            model_name='agreement',
            name='fixed_duration_value',
            field=models.PositiveIntegerField(blank=True, null=True),
        ),
        migrations.AddField(
            model_name='agreement',
            name='initial_rent',
            field=models.DecimalField(blank=True, decimal_places=2, max_digits=10, null=True),
        ),
        migrations.AddField(
            model_name='agreement',
            name='increment_every',
            field=models.CharField(blank=True, choices=[('monthly', 'Monthly'), ('every_3_months', 'Every 3 Months'), ('every_6_months', 'Every 6 Months'), ('yearly', 'Yearly')], max_length=20, null=True),
        ),
        migrations.AddField(
            model_name='agreement',
            name='increment_type',
            field=models.CharField(blank=True, choices=[('fixed_amount', 'Fixed Amount'), ('percentage', 'Percentage')], max_length=20, null=True),
        ),
        migrations.AddField(
            model_name='agreement',
            name='increase_by',
            field=models.DecimalField(blank=True, decimal_places=2, max_digits=10, null=True),
        ),
        migrations.AddField(
            model_name='agreement',
            name='house_rules',
            field=models.TextField(blank=True, default=''),
        ),
        migrations.AddField(
            model_name='agreement',
            name='additional_description',
            field=models.TextField(blank=True, default=''),
        ),
        migrations.AddField(
            model_name='agreement',
            name='landlord_is_signed',
            field=models.BooleanField(default=False),
        ),
        migrations.AddField(
            model_name='agreement',
            name='landlord_signed_at',
            field=models.DateTimeField(blank=True, null=True),
        ),
        migrations.AlterField(
            model_name='agreement',
            name='content',
            field=models.TextField(blank=True, default=''),
        ),
    ]
