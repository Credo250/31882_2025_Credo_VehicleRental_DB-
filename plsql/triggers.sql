-

-- DML block triggers (attach to any table you want protected)
CREATE OR REPLACE TRIGGER trg_block_rentals_dml
BEFORE INSERT OR UPDATE OR DELETE ON rentals
FOR EACH ROW
BEGIN
  business_rules_pkg.check_dml_allowed;
END;
/
CREATE OR REPLACE TRIGGER trg_block_vehicles_dml
BEFORE INSERT OR UPDATE OR DELETE ON vehicles
FOR EACH ROW
BEGIN
  business_rules_pkg.check_dml_allowed;
END;
/
CREATE OR REPLACE TRIGGER trg_block_customers_dml
BEFORE INSERT OR UPDATE OR DELETE ON customers
FOR EACH ROW
BEGIN
  business_rules_pkg.check_dml_allowed;
END;
/
-- AUDIT Trigger template: records old/new values into audit_log for key tables
CREATE OR REPLACE TRIGGER trg_audit_rentals
AFTER INSERT OR UPDATE OR DELETE ON rentals
FOR EACH ROW
DECLARE
  v_old CLOB := NULL;
  v_new CLOB := NULL;
BEGIN
  IF INSERTING THEN
    v_new := 'rental_id=' || NVL(TO_CHAR(:NEW.rental_id),'NULL') ||
             ', vehicle_id=' || NVL(TO_CHAR(:NEW.vehicle_id),'NULL') ||
             ', customer_id=' || NVL(TO_CHAR(:NEW.customer_id),'NULL') ||
             ', start_date=' || NVL(TO_CHAR(:NEW.start_date,'YYYY-MM-DD HH24:MI:SS'),'NULL') ||
             ', end_date=' || NVL(TO_CHAR(:NEW.end_date,'YYYY-MM-DD HH24:MI:SS'),'NULL') ||
             ', total_amount=' || NVL(TO_CHAR(:NEW.total_amount),'NULL');
    INSERT INTO audit_log (username, operation, table_name, pk_value, old_values, new_values)
      VALUES (SYS_CONTEXT('USERENV','SESSION_USER'), 'INSERT', 'RENTALS', NVL(TO_CHAR(:NEW.rental_id),'NULL'), NULL, v_new);
  ELSIF UPDATING THEN
    v_old := 'rental_id=' || NVL(TO_CHAR(:OLD.rental_id),'NULL') || ', status=' || NVL(:OLD.status,'NULL');
    v_new := 'rental_id=' || NVL(TO_CHAR(:NEW.rental_id),'NULL') || ', status=' || NVL(:NEW.status,'NULL');
    INSERT INTO audit_log (username, operation, table_name, pk_value, old_values, new_values)
      VALUES (SYS_CONTEXT('USERENV','SESSION_USER'), 'UPDATE', 'RENTALS', NVL(TO_CHAR(:NEW.rental_id),'NULL'), v_old, v_new);
  ELSIF DELETING THEN
    v_old := 'rental_id=' || NVL(TO_CHAR(:OLD.rental_id),'NULL');
    INSERT INTO audit_log (username, operation, table_name, pk_value, old_values, new_values)
      VALUES (SYS_CONTEXT('USERENV','SESSION_USER'), 'DELETE', 'RENTALS', NVL(TO_CHAR(:OLD.rental_id),'NULL'), v_old, NULL);
  END IF;
END;
/

-- Similar audit triggers for vehicles, customers, payments, maintenance
CREATE OR REPLACE TRIGGER trg_audit_vehicles
AFTER INSERT OR UPDATE OR DELETE ON vehicles
FOR EACH ROW
BEGIN
  IF INSERTING THEN
    INSERT INTO audit_log (username, operation, table_name, pk_value, old_values, new_values)
    VALUES (SYS_CONTEXT('USERENV','SESSION_USER'),'INSERT','VEHICLES',NVL(TO_CHAR(:NEW.vehicle_id),'NULL'),NULL,
            'reg='||NVL(:NEW.reg_number,'NULL')||',status='||NVL(:NEW.status,'NULL'));
  ELSIF UPDATING THEN
    INSERT INTO audit_log (username, operation, table_name, pk_value, old_values, new_values)
    VALUES (SYS_CONTEXT('USERENV','SESSION_USER'),'UPDATE','VEHICLES',NVL(TO_CHAR(:NEW.vehicle_id),'NULL'),
            'status='||NVL(:OLD.status,'NULL'),
            'status='||NVL(:NEW.status,'NULL'));
  ELSIF DELETING THEN
    INSERT INTO audit_log (username, operation, table_name, pk_value, old_values, new_values)
    VALUES (SYS_CONTEXT('USERENV','SESSION_USER'),'DELETE','VEHICLES',NVL(TO_CHAR(:OLD.vehicle_id),'NULL'),
            'reg='||NVL(:OLD.reg_number,'NULL'), NULL);
  END IF;
END;
/
CREATE OR REPLACE TRIGGER trg_audit_customers
AFTER INSERT OR UPDATE OR DELETE ON customers
FOR EACH ROW
BEGIN
  IF INSERTING THEN
    INSERT INTO audit_log (username, operation, table_name, pk_value, old_values, new_values)
    VALUES (SYS_CONTEXT('USERENV','SESSION_USER'),'INSERT','CUSTOMERS',NVL(TO_CHAR(:NEW.customer_id),'NULL'),NULL,
            'name='||NVL(:NEW.full_name,'NULL'));
  ELSIF UPDATING THEN
    INSERT INTO audit_log (username, operation, table_name, pk_value, old_values, new_values)
    VALUES (SYS_CONTEXT('USERENV','SESSION_USER'),'UPDATE','CUSTOMERS',NVL(TO_CHAR(:NEW.customer_id),'NULL'),
            'name='||NVL(:OLD.full_name,'NULL'),'name='||NVL(:NEW.full_name,'NULL'));
  ELSIF DELETING THEN
    INSERT INTO audit_log (username, operation, table_name, pk_value, old_values, new_values)
    VALUES (SYS_CONTEXT('USERENV','SESSION_USER'),'DELETE','CUSTOMERS',NVL(TO_CHAR(:OLD.customer_id),'NULL'),
            'name='||NVL(:OLD.full_name,'NULL'), NULL);
  END IF;
END;
/
-- You can add similar triggers for payments and maintenance as required.
