# ADR-001: Use Local-First Architecture

## Status

Accepted

## Date

2026-07-05

## Context

This project is a portfolio-safe Data Reliability Platform.

The goal is to simulate a production-style data engineering platform without using real company data, confidential business logic, paid cloud infrastructure, or production credentials.

The platform should help demonstrate:

1. Data ingestion
2. Batch incremental processing
3. Lake, delta, and ODS layers
4. Data quality checks
5. Root cause analysis
6. Impact analysis
7. AI-assisted investigation in later versions
8. Professional engineering documentation

The project must be easy to run locally so that another engineer, recruiter, or interviewer can understand and reproduce the system without needing access to private infrastructure.

## Decision

We will build the platform using a local-first architecture.

The initial technology choices are:

1. Docker for local reproducible services
2. PostgreSQL for online and offline database simulation
3. Python for data generation, ingestion, and data quality logic
4. Airflow for orchestration in a later implementation stage
5. Git and GitHub for version control
6. Markdown documentation for architecture decisions and onboarding

The V1 data flow is:

```text
online_db.transactions
        ↓
lake_transactions
        ↓
delta_transactions
        ↓
ods_transactions