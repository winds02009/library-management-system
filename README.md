# Library Management System

Individual project (Database Technologies and Management). Relational database design for a library, implemented in SQL (MySQL / Oracle SQL), with ER diagrams, triggers and stored procedures.

## Contents
- Tables: `Library`, `Student`, `Staff`, `Book`, `Transactions` with primary/foreign keys and constraints
- Trigger `enforce_quantity_constraint` to keep book stock valid
- PL/SQL package `library_system` (stored procedures/functions for library operations)
- Report with ER diagram and design explanation in `docs/`

## Structure
- `library_system.sql` - schema, sample data, trigger and package
- `docs/report.pdf` / `docs/report.docx` - project report (ER diagram, design)

## How to run
Run `library_system.sql` in Oracle SQL Developer / SQL*Plus (PL/SQL package and trigger use Oracle syntax). The table definitions can be adapted for MySQL.