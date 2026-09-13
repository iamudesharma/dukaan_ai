from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [("assistant", "0004_immutable_revisions")]

    operations = [
        migrations.AddField(
            model_name="assistantproposal",
            name="preview_data",
            field=models.JSONField(blank=True, default=dict),
        ),
    ]
