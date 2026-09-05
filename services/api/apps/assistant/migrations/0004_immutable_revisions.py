from django.db import migrations


def protect(apps, schema_editor):
    if schema_editor.connection.vendor == "sqlite":
        for operation in ("UPDATE", "DELETE"):
            schema_editor.execute(f"""
                CREATE TRIGGER proposal_revision_no_{operation.lower()}
                BEFORE {operation} ON assistant_proposalrevision
                BEGIN SELECT RAISE(ABORT, 'Proposal revisions are immutable'); END
            """)
    elif schema_editor.connection.vendor == "postgresql":
        schema_editor.execute("""
            CREATE FUNCTION reject_proposal_revision_mutation() RETURNS trigger
            LANGUAGE plpgsql AS $$ BEGIN
                RAISE EXCEPTION 'Proposal revisions are immutable';
            END $$
        """)
        schema_editor.execute("""
            CREATE TRIGGER proposal_revision_immutable BEFORE UPDATE OR DELETE
            ON assistant_proposalrevision FOR EACH ROW
            EXECUTE FUNCTION reject_proposal_revision_mutation()
        """)


def unprotect(apps, schema_editor):
    if schema_editor.connection.vendor == "sqlite":
        for operation in ("update", "delete"):
            schema_editor.execute(f"DROP TRIGGER IF EXISTS proposal_revision_no_{operation}")
    elif schema_editor.connection.vendor == "postgresql":
        schema_editor.execute(
            "DROP TRIGGER IF EXISTS proposal_revision_immutable ON assistant_proposalrevision"
        )
        schema_editor.execute("DROP FUNCTION IF EXISTS reject_proposal_revision_mutation()")


class Migration(migrations.Migration):
    dependencies = [("assistant", "0003_assistantproposal_data_fingerprint_proposalrevision")]
    operations = [migrations.RunPython(protect, unprotect)]
