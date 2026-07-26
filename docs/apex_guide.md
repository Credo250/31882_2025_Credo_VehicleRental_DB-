# Oracle APEX App Plan

1. App name: Vehicle Rental MIS App

2. Pages:
   - Dashboard: charts (revenue, utilization, active rentals)
   - Vehicles: interactive grid (CRUD for vehicles) - grant only to backoffice role
   - Rentals: interactive report + create_rental button (calls stored proc)
   - Customers: interactive report
   - Payments: report + add payment
   - Maintenance: maintenance records
   - Audit Log: readonly report of audit_log
   - Admin: manage public_holidays (admin only)

3. Authentication:
   - Use APEX built-in authentication or Oracle schema accounts. For production, use custom authentication & roles.

4. Integration:
   - Use PL/SQL dynamic actions to call business_logic_pkg.create_rental and close_rental.

5. Deployment:
   - Export app as SQL file and include in repo under /apex.
