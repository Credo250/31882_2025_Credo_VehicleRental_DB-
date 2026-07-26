
BEGIN
  EXECUTE IMMEDIATE 'CREATE ROLE vehicle_readonly';
EXCEPTION WHEN OTHERS THEN
  IF SQLCODE = -1920 THEN NULL; ELSE RAISE; END IF; -- ignore if exists
END;
/
-- Grant select on tables to role
GRANT SELECT ON branches TO vehicle_readonly;
GRANT SELECT ON vehicles TO vehicle_readonly;
GRANT SELECT ON customers TO vehicle_readonly;
GRANT SELECT ON rentals TO vehicle_readonly;
GRANT SELECT ON payments TO vehicle_readonly;
GRANT SELECT ON maintenance TO vehicle_readonly;
GRANT SELECT ON public_holidays TO vehicle_readonly;

-- Create application user (for Power BI / APEX connection)
CREATE USER vehicle_app IDENTIFIED BY "AppUser123!";
GRANT CREATE SESSION TO vehicle_app;
GRANT vehicle_readonly TO vehicle_app;

-- Optionally, grant INSERT/UPDATE limited for backoffice user
-- CREATE USER backoffice IDENTIFIED BY "Backoffice123!";
-- GRANT CREATE SESSION TO backoffice;
-- GRANT SELECT, INSERT, UPDATE ON rentals TO backoffice; -- as needed
