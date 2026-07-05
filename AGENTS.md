# AGENTS.md

## Prime Directive

This repository is a portfolio-safe Data Reliability Platform.

The agent must optimize for:

1. Readability
2. Simplicity
3. Small, reviewable changes
4. Clear explanations
5. Beginner-friendly structure
6. Portfolio-safe implementation

The goal is not to produce the most advanced solution.

The goal is to produce a solution that another engineer can understand, run, review, and explain.

---

## Agent Role

The agent works as an implementation assistant.

The human owner is responsible for architecture decisions, final review, commits, and pushes.

The agent should help by:

1. Creating focused code changes
2. Explaining changes clearly
3. Suggesting simple commit messages
4. Identifying risks and assumptions
5. Asking for approval before high-impact changes

---

## General Project Guidelines

These rules apply to all files and languages in this repository.

1. Keep changes small and focused.
2. Prefer simple, readable solutions over clever solutions.
3. Use clear and descriptive names.
4. Organize files by responsibility.
5. Avoid adding unnecessary frameworks, tools, or services.
6. Explain important design decisions in simple language.
7. Update documentation when adding meaningful functionality.
8. Make the project easy for a new engineer to understand.
9. If a task requires an architecture change, explain the proposed change first and wait for approval.
10. Ask for human review before committing or pushing code.

---

## Current V1 Scope

The first version of the platform focuses on this flow:

```text
online_db.transactions
        ↓
lake_transactions
        ↓
delta_transactions
        ↓
ods_transactions
```

V1 should focus on:

1. Source transaction schema
2. Offline lake table
3. Delta table for daily changed records
4. ODS table for fullscale/latest-state data
5. Basic data quality result tracking

V1 should not include unless explicitly requested:

1. Fact tables
2. Dimension tables
3. Mart tables
4. AI agents
5. Kubernetes
6. Cloud services
7. Production Airflow deployment

---

## Repository Structure

```text
airflow/   - Airflow DAGs and orchestration code
docker/    - Docker-related configuration
docs/      - Architecture documents and decision records
python/    - Python data generator, ingestion, and data quality logic
scripts/   - Helper scripts
sql/       - SQL logic for lake, delta, ODS, migrations, and DQ checks
```

---

## Documentation Guidelines

When editing documentation:

1. Use simple and clear English.
2. Explain what the component does.
3. Explain why the component exists.
4. Explain where it fits in the pipeline.
5. Avoid unnecessary jargon.
6. Prefer diagrams or simple flow explanations when helpful.
7. Keep onboarding-friendly sections up to date.

Important documentation files:

```text
README.md
AGENTS.md
docs/architecture/
docs/decisions/
```

---

## Human Review and Approval Rules

The agent must work as an implementation assistant, not as the final decision maker.

Before committing or pushing any code, the agent must:

1. Show the changed files.
2. Summarize what changed in simple language.
3. Explain why the change was made.
4. Mention any risks, assumptions, or parts that need human review.
5. Suggest a simple commit message.
6. Wait for explicit human approval before running `git commit`.
7. Wait for explicit human approval before running `git push`.

The agent should not commit or push automatically unless the repository owner clearly says:

```text
approved, commit
```

or:

```text
approved, push
```

Commit messages should be simple and easy to understand.

Use this format when possible:

```text
type: short description
```

Recommended types:

```text
feat:     new feature
fix:      bug fix
docs:     documentation change
chore:    setup or maintenance
test:     test-related change
refactor: code restructuring without behavior change
```

Examples:

```text
docs: add AGENTS.md instructions
docs: add ADR-001 local-first architecture
feat: add transaction source schema
feat: add lake transaction schema
fix: ignore IDE files
chore: initialize project folders
```

---

## PostgreSQL Guidelines

When writing PostgreSQL SQL:

1. Use PostgreSQL-compatible syntax.
2. Use explicit column names instead of `SELECT *` in transformation logic.
3. Use readable table and column names.
4. Use readable aliases.
5. Keep joins easy to follow.
6. Prefer simple CTEs when they improve readability.
7. Avoid deeply nested queries unless necessary.
8. Add comments for important table purposes or transformation rules.
9. Make date filters and incremental logic easy to understand.
10. Keep SQL formatted consistently.

Example:

```sql
SELECT
    transaction_id,
    user_id,
    merchant_id,
    amount,
    transaction_status,
    created_at,
    modified_at
FROM online_transactions
WHERE modified_at >= :start_time
  AND modified_at < :end_time;
```

---

## Database Schema Guidelines

These rules apply when creating or modifying database schemas.

The agent must keep database schemas simple, explicit, and easy to understand.

### General Schema Rules

1. Use PostgreSQL-compatible DDL.
2. Use lowercase `snake_case` for table names and column names.
3. Use clear and descriptive names.
4. Prefer explicit data types.
5. Add primary keys when the table has a natural business identifier.
6. Add `created_at` and `modified_at` columns when modeling source transactional data.
7. Add ingestion metadata columns for offline pipeline tables when useful.
8. Add comments explaining the purpose of important tables.
9. Keep schemas beginner-friendly and easy to explain.
10. Do not add unnecessary tables, columns, indexes, triggers, or constraints unless required by the task.

### Naming Rules

Use table names that clearly describe the data layer:

```text
online_transactions
lake_transactions
delta_transactions
ods_transactions
dq_results
```

Use column names like:

```text
transaction_id
user_id
merchant_id
amount
currency
transaction_status
payment_method
created_at
modified_at
batch_date
extracted_at
loaded_at
source_table
```

Avoid unclear names like:

```text
id
data
value
flag
status1
temp_col
misc
```

unless there is a clear reason.

### Data Type Guidelines

Use simple PostgreSQL data types:

```sql
VARCHAR(50)       -- identifiers and short codes
VARCHAR(255)      -- names or longer text
NUMERIC(18,2)     -- money or transaction amount
TIMESTAMP         -- date and time
DATE              -- partition-like date or batch date
BOOLEAN           -- true/false flags
TEXT              -- longer descriptions
```

Avoid advanced PostgreSQL-specific features early unless explicitly requested, such as:

```text
JSONB
ARRAY
custom types
triggers
stored procedures
materialized views
partitioned tables
```

These can be introduced later when the project needs them.

### Online Tables

Online tables simulate source transactional systems.

They should:

1. Represent operational data.
2. Have a clear primary key.
3. Include `created_at` and `modified_at`.
4. Avoid pipeline metadata columns.

Example:

```sql
CREATE TABLE online_transactions (
    transaction_id VARCHAR(50) PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL,
    merchant_id VARCHAR(50) NOT NULL,
    amount NUMERIC(18,2) NOT NULL,
    currency VARCHAR(10) NOT NULL,
    transaction_status VARCHAR(30) NOT NULL,
    payment_method VARCHAR(30),
    created_at TIMESTAMP NOT NULL,
    modified_at TIMESTAMP NOT NULL
);
```

### Lake Tables

Lake tables simulate raw offline landing tables.

They should:

1. Stay close to the source structure.
2. Avoid heavy transformation.
3. Include ingestion metadata.
4. Preserve source values as much as possible.

Recommended metadata columns:

```text
batch_date
extracted_at
source_table
```

### Delta Tables

Delta tables store daily changed records.

They should:

1. Support incremental processing.
2. Be based on `modified_at`.
3. Include `batch_date`.
4. Allow deduplication by business key and latest `modified_at`.

### ODS Tables

ODS tables represent the fullscale source-aligned table.

They should:

1. Store the latest known state of each business record.
2. Use the source business key as the primary key when appropriate.
3. Preserve important source timestamps.
4. Include pipeline metadata when useful.

Recommended metadata columns:

```text
last_batch_date
loaded_at
```

### Schema Restrictions

The agent must not:

1. Use real company table names.
2. Use internal production schemas.
3. Add sensitive or confidential business logic.
4. Add unnecessary normalization too early.
5. Add fact, dimension, or mart tables during V1 unless explicitly requested.
6. Add indexes before explaining why they are needed.
7. Add partitioning before the project needs it.
8. Add advanced database features without approval.
9. Rename existing tables or columns without explaining the impact.
10. Break compatibility with PostgreSQL.

### Schema Change Review Checklist

Before completing a schema-related task, the agent must explain:

1. Which tables were added or changed.
2. Why each table exists.
3. What each important column means.
4. Which column is the primary key.
5. How the table fits into the pipeline.
6. Whether the schema supports incremental loading.
7. Any assumptions or trade-offs.

---

## Python Guidelines

When writing Python:

1. Use simple, readable Python.
2. Use descriptive function and variable names.
3. Keep functions small and focused on one responsibility.
4. Avoid unnecessary abstraction.
5. Add type hints when they improve clarity.
6. Use docstrings for important functions.
7. Keep modules focused by responsibility.
8. Prefer explicit logic over hidden magic.
9. Write code that can be tested later.
10. Avoid introducing large dependencies unless needed.

Bad example:

```python
def proc(x):
    return [i for i in x if i[2] > 0]
```

Better example:

```python
def filter_positive_amount_transactions(transactions):
    return [
        transaction
        for transaction in transactions
        if transaction.amount > 0
    ]
```

---

## Docker Guidelines

When editing Docker-related files:

1. Keep local setup simple.
2. Use Docker for local development only unless instructed otherwise.
3. Only add new services when they are required for the current task.
4. Explain why each service exists.
5. Do not include secrets, passwords, tokens, or private credentials.
6. Use environment variables for configurable values.
7. Keep `docker-compose.yml` readable and well-commented.
8. Prefer stable official images when possible.

Prefer explicit versions:

```yaml
image: postgres:16
```

Avoid:

```yaml
image: postgres:latest
```

because `latest` can change unexpectedly and make the project harder to reproduce.

---

## Airflow Guidelines

When writing Airflow DAGs:

1. Keep DAGs small and readable.
2. Do not put heavy business logic directly inside DAG files.
3. Place reusable logic in Python modules.
4. Make task names clear.
5. Make dependencies easy to understand.
6. Use deterministic date/window logic.
7. Avoid relying on current system time for critical pipeline logic.
8. Add comments for important pipeline behavior.
9. Make DAGs easy to explain in an interview.
10. Do not add Airflow code before the task explicitly asks for it.

---

## Testing Guidelines

When adding or modifying logic:

1. Add tests when practical.
2. Keep tests simple and readable.
3. Test important data quality rules.
4. Test edge cases when they are relevant.
5. Do not overcomplicate the test structure early.
6. Prefer tests that help explain expected behavior.

---

## Versioning and Rollback Guidelines

The project should be built in a way that makes changes traceable, reviewable, and reversible.

If a bug, regression, or difficult problem happens, the team should be able to identify what changed and rollback to a previous stable version.

### General Versioning Principles

1. Keep changes small and focused.
2. Avoid large commits that mix unrelated changes.
3. Use clear commit messages.
4. Prefer incremental changes over big rewrites.
5. Document important architecture or schema decisions.
6. Make rollback possible whenever practical.
7. Do not change many layers at the same time unless explicitly requested.

Bad example:

```text
feat: update project
```

Better example:

```text
feat: add online transaction schema
feat: add lake transaction schema
feat: add delta transaction schema
feat: add ods transaction schema
docs: add ADR-001 local-first architecture
```

### Database Schema Versioning

Database schema changes should be versioned using migration-style files.

Schema files should use clear numbering:

```text
sql/migrations/
  001_create_online_transactions.sql
  002_create_lake_transactions.sql
  003_create_delta_transactions.sql
  004_create_ods_transactions.sql
  005_create_dq_results.sql
```

Each migration file should have one clear purpose.

Good:

```text
001_create_online_transactions.sql
```

Bad:

```text
update_tables.sql
new_schema.sql
final_schema.sql
schema_latest.sql
```

When modifying an existing schema, prefer adding a new migration file instead of silently editing old migration history, unless the project is still in the early draft phase and the human owner approves.

### Python Change Versioning

Python changes should be small and grouped by responsibility.

Examples:

```text
python/generator/       - synthetic data generation
python/ingestion/       - extract/load logic
python/dq/              - data quality checks
```

The agent should avoid changing generator, ingestion, and DQ logic in the same task unless explicitly requested.

### Docker and Runtime Versioning

Docker images should use explicit versions when practical.

When changing Docker-related files, the agent should explain:

1. Which service changed.
2. Why the change was needed.
3. Whether the change affects local setup.
4. Whether volumes or data need to be reset.
5. How to rollback the change.

### Documentation and ADR Versioning

Architecture decisions should be recorded in numbered ADR files.

Use this format:

```text
docs/decisions/
  ADR-001-local-first-architecture.md
  ADR-002-database-migration-strategy.md
  ADR-003-batch-incremental-ingestion.md
```

ADR files should not be deleted or rewritten casually.

If a decision changes later, create a new ADR that supersedes the previous one.

The old ADR should remain as project history.

### Rollback Expectations

Before making changes that affect schemas, Docker, Airflow, or core Python logic, the agent should consider rollback.

The agent should explain:

1. What can be reverted with Git.
2. What database changes may need a rollback script.
3. Whether local data may need to be recreated.
4. Whether the change affects only development or also future pipeline behavior.

---

## Impact Analysis Guidelines

Before making changes that affect schemas, pipelines, Docker services, Airflow DAGs, data quality checks, or core Python logic, the agent should perform a simple impact analysis.

The purpose is to understand:

1. What will change
2. Which components may be affected
3. What could break
4. What needs testing
5. What needs monitoring
6. How to rollback if needed

### Impact Analysis Questions

Before editing important files, the agent should consider:

1. Which layer is affected?

```text
online_db
lake
delta
ods
dq
airflow
docker
python
docs
```

2. Which downstream components may be affected?

Example:

```text
Changing online_transactions schema
→ affects lake_transactions
→ affects delta_transactions
→ affects ods_transactions
→ affects DQ checks
→ affects Airflow pipeline
```

3. Does this change affect data correctness?

Examples:

```text
row count
duplicate handling
null handling
amount calculation
status mapping
modified_at filter
primary key logic
```

4. Does this change affect local setup?

Examples:

```text
Docker services
database ports
environment variables
volumes
reset/rebuild steps
```

5. Does this change require monitoring?

Monitoring may be needed when the change affects:

```text
row counts
failed records
duplicate records
missing records
schema mismatch
late-arriving records
failed Airflow tasks
```

6. Does this change require tests?

If the change affects data behavior, the agent should suggest tests or checks.

### Required Impact Summary

For important changes, the agent should include an impact summary before completion:

```text
Impact Summary

Changed:
- What files/components changed

Affected layers:
- Which pipeline layers may be affected

Expected impact:
- What behavior should change

Risks:
- What could break

Validation:
- How to test or verify the change

Monitoring:
- What should be watched after the change

Rollback:
- How to revert if the change causes problems
```

### High-Impact Changes

The agent should not make high-impact changes silently.

High-impact changes include:

1. Changing primary keys
2. Renaming columns
3. Changing timestamp logic
4. Changing incremental filter logic
5. Changing merge/upsert logic
6. Changing Docker service names or ports
7. Changing Airflow DAG schedules
8. Changing DQ validation rules
9. Removing files or tables
10. Rewriting existing architecture decisions

For high-impact changes, the agent must explain the proposed change and wait for human approval before editing files.

---

## Safety and Privacy Guidelines

Never include:

1. Real company data
2. Internal table names
3. Production credentials
4. API keys
5. Tokens
6. Passwords
7. Private URLs
8. Confidential business logic

Use synthetic data only.

When unsure whether something is sensitive, treat it as sensitive and ask for clarification.

---

## Completion Checklist

Before saying a task is complete, the agent must provide:

1. Changed files
2. Summary of changes
3. Reason for the changes
4. How to review the changes
5. Any risks or assumptions
6. Suggested commit message
7. Whether tests or commands were run