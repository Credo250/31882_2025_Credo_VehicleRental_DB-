

CREATE OR REPLACE PACKAGE business_logic_pkg IS

  PROCEDURE create_rental(p_vehicle_id IN NUMBER, p_customer_id IN NUMBER, p_branch_id IN NUMBER, p_start_date IN DATE, p_end_date IN DATE);
  PROCEDURE close_rental(p_rental_id IN NUMBER);
  FUNCTION calc_rental_total(p_start_date IN DATE, p_end_date IN DATE, p_daily_rate IN NUMBER) RETURN NUMBER;
  PROCEDURE list_active_rentals;
END business_logic_pkg;
/
CREATE OR REPLACE PACKAGE BODY business_logic_pkg IS

  FUNCTION calc_rental_total(p_start_date IN DATE, p_end_date IN DATE, p_daily_rate IN NUMBER) RETURN NUMBER IS
    v_days NUMBER;
    v_total NUMBER;
  BEGIN
    IF p_end_date IS NULL THEN
      v_days := TRUNC(SYSDATE) - TRUNC(p_start_date) + 1;
    ELSE
      v_days := TRUNC(p_end_date) - TRUNC(p_start_date) + 1;
    END IF;
    IF v_days < 1 THEN v_days := 1; END IF;
    v_total := v_days * NVL(p_daily_rate,0);
    RETURN ROUND(v_total,2);
  END calc_rental_total;

  PROCEDURE create_rental(p_vehicle_id IN NUMBER, p_customer_id IN NUMBER, p_branch_id IN NUMBER, p_start_date IN DATE, p_end_date IN DATE) IS
    v_status VARCHAR2(20);
    v_daily_rate NUMBER;
  BEGIN

    SELECT status, daily_rate INTO v_status, v_daily_rate FROM vehicles WHERE vehicle_id = p_vehicle_id FOR UPDATE;
    IF v_status <> 'AVAILABLE' THEN
      RAISE_APPLICATION_ERROR(-20010, 'Vehicle is not available for rental.');
    END IF;

    INSERT INTO rentals (vehicle_id, customer_id, branch_id, start_date, end_date, daily_rate, status)
    VALUES (p_vehicle_id, p_customer_id, p_branch_id, p_start_date, p_end_date, v_daily_rate, 'ACTIVE');
    UPDATE vehicles SET status = 'RENTED' WHERE vehicle_id = p_vehicle_id;

    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END create_rental;

  PROCEDURE close_rental(p_rental_id IN NUMBER) IS
    v_vehicle_id NUMBER;
    v_start DATE;
    v_end   DATE;
    v_daily_rate NUMBER;
    v_total NUMBER;
  BEGIN
    SELECT vehicle_id, start_date, end_date, daily_rate INTO v_vehicle_id, v_start, v_end, v_daily_rate FROM rentals WHERE rental_id = p_rental_id FOR UPDATE;
    IF v_end IS NULL THEN
      UPDATE rentals SET end_date = TRUNC(SYSDATE) WHERE rental_id = p_rental_id;
      v_end := TRUNC(SYSDATE);
    END IF;

    v_total := calc_rental_total(v_start, v_end, v_daily_rate);

    UPDATE rentals SET total_amount = v_total, status = 'CLOSED' WHERE rental_id = p_rental_id;
    UPDATE vehicles SET status = 'AVAILABLE' WHERE vehicle_id = v_vehicle_id;

    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END close_rental;

  PROCEDURE list_active_rentals IS
    CURSOR c_active IS
      SELECT r.rental_id, v.reg_number, c.full_name, r.start_date, r.end_date, r.total_amount
      FROM rentals r
      JOIN vehicles v ON r.vehicle_id = v.vehicle_id
      JOIN customers c ON r.customer_id = c.customer_id
      WHERE r.status = 'ACTIVE';
  BEGIN
    FOR rec IN c_active LOOP
      DBMS_OUTPUT.PUT_LINE('Rental '||rec.rental_id||' Vehicle:'||rec.reg_number||' Customer:'||rec.full_name);
    END LOOP;
  END list_active_rentals;

END business_logic_pkg;
/
