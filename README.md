## 10-Minute Engineer Onboarding

If another engineer joins this project, they should be able to understand the following within the first 10 minutes:

1. **Big Picture and Project Goal**
   Understand what the Data Reliability Platform is, why it exists, what problem it solves, and how it simulates a production-style data platform.

2. **Current Project State**
   Understand what has already been built, what is currently in progress, and which version or milestone the project is currently targeting.

3. **Known Issues, Blockers, and Development Challenges**
   Understand the common problems, technical blockers, trade-offs, and difficulties encountered during development, so they do not repeat the same mistakes.

4. **Upcoming Sprint Plan**
   Understand the planned work for the next few sprints, including the next features, technical improvements, and documentation tasks.

5. **Contribution Opportunities**
   Understand where they can help based on their skills, such as Python, SQL, Airflow, Docker, data quality checks, documentation, testing, architecture, or AI agents.

6. **How to Run the Project Locally**
   Understand how to clone the repository, set up the environment, start the services, run the pipeline, execute tests, and verify that everything works correctly.

## Local Setup

The V1 local environment uses two PostgreSQL containers:

- `online_postgres` simulates the source transaction database.
- `offline_postgres` stores the lake, delta, ODS, and data quality tables.

Start both databases:

```powershell
docker compose up -d
```

Check that both containers are running and healthy:

```powershell
docker compose ps
```

Apply the V1 migrations from the repository root:

```powershell
.\scripts\apply_migrations.ps1
```

If PowerShell blocks the script, run it with a temporary execution policy bypass:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\apply_migrations.ps1
```

Only run the migration script on a fresh database. It will fail if the target tables already exist.

### Seed Online Transaction Data

After applying the migrations, load the synthetic e-wallet transactions:

```powershell
.\scripts\seed_online_transactions.ps1
```

If PowerShell blocks the script, run it with a temporary execution policy bypass:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\seed_online_transactions.ps1
```

Do not run the seed script twice on the same database. Duplicate `transaction_id` values will cause it to fail.

Verify the online database table:

```powershell
docker compose exec online_postgres psql -U postgres -d online_db -c "\dt"
```

Verify the offline database tables:

```powershell
docker compose exec offline_postgres psql -U postgres -d offline_db -c "\dt"
```

Stop the containers without deleting their data:

```powershell
docker compose down
```

To reset the local databases, stop the containers and delete their named volumes:

```powershell
docker compose down -v
```

**Warning:** `docker compose down -v` permanently deletes all data stored in the local PostgreSQL volumes.
