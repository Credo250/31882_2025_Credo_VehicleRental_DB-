# Power BI Integration Guide

1. Data source:
   - Connect Power BI Desktop to Oracle Database using the Oracle connector.
   - Use `vehicle_app` read-only user created in sql/security_roles.sql.

2. Tables recommended:
   - vehicles, rentals, payments, branches, customers, maintenance

3. Recommended joins:
   - rentals.vehicle_id -> vehicles.vehicle_id
   - rentals.customer_id -> customers.customer_id
   - payments.rental_id -> rentals.rental_id
   - vehicles.branch info via rentals.branch_id

4. DAX measures (examples)
   - TotalRevenue = SUM(payments[amount])
   - TotalRentals = COUNTROWS(rentals)
   - ActiveRentals = CALCULATE(COUNTROWS(rentals), rentals[status]="ACTIVE")
   - AverageDailyRate = AVERAGEX(VALUES(vehicles[vehicle_id]), vehicles[daily_rate])

5. Suggested visuals:
   - KPI: TotalRevenue, ActiveRentals
   - Line chart: revenue by month
   - Bar chart: rentals by vehicle category
   - Map or filled map: branch performance (requires branch latitude/longitude; add lat/long if available)
   - Table: current active rentals with customer & vehicle

6. Exporting for Power BI
   - If direct Oracle connection not possible, export key views as CSV:
     - CREATE VIEW v_rentals_reporting AS SELECT ...;
     - Use SQL*Plus or SQL Developer to spool CSV.

7. Refresh & scheduled update
   - Publish PBIX to Power BI Service and set dataset credentials to use gateway if Oracle is on-prem.

8. Example advanced KPI (utilization %):
   - Utilization% = DIVIDE( SUM(rentals_days), COUNT(vehicles) * DaysInPeriod ) * 100
   - rentals_days: computed from rental records (end_date-start_date+1)
