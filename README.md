# 31882_2025_Credo_VehicleRental_DB

Project: Vehicle Rental Management Information System (Vehicle Rental MIS)
Student: Credo Darwin
Student ID: 31882/2025
Course: DPR400210 - Database Programming (Oracle)

This repo contains:
- /sql/init_db.sql                -- Create schema user & grants (DBA required)
- /sql/sample_tables.sql          -- Create tables + sample data
- /sql/sample_queries.sql         -- Useful queries and report queries
- /plsql/business_rules_pkg.sql   -- Package: check_dml_allowed + holiday check
- /plsql/business_logic_pkg.sql   -- Business logic: create_rental, close_rental, calculations
- /plsql/triggers.sql             -- DML-block triggers + audit triggers
- /sql/security_roles.sql         -- Roles and limited-user creation (for app access)
- /docs/powerbi_guide.md          -- Power BI integration + DAX measures
- /docs/apex_guide.md             -- Oracle APEX app plan & pages
- /presentation/slides_text.txt   -- Text for <=10 slides (paste into PPT)
- /final_report/final_report.md   -- Final report outline and content

How to deploy
1. As a DBA (SYS or user with CREATE USER), run:
   sqlplus / as sysdba
   @sql/init_db.sql

   Update the password in that file before running.

2. Connect as project schema:
   sqlplus "31882_2025_Credo_VehicleRental_DB"/ChangeMe123!

3. Run schema scripts:
   @sql/sample_tables.sql
   @plsql/business_rules_pkg.sql
   @plsql/business_logic_pkg.sql
   @plsql/triggers.sql

4. Create the application user (see /sql/security_roles.sql) and follow docs to connect Power BI or APEX.

Change logs and notes
- DML blocking rule currently enforces blocking on weekdays (Mon–Fri) and public holidays (per assignment). To change to weekends, see comments in business_rules_pkg.sql.
- Always change passwords before production use.

Contact: Credo Darwin
