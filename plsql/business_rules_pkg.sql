CREATE OR REPLACE PACKAGE business_rules_pkg IS
  PROCEDURE check_dml_allowed;
  FUNCTION is_today_public_holiday RETURN BOOLEAN;
END business_rules_pkg;
/
CREATE OR REPLACE PACKAGE BODY business_rules_pkg IS

  FUNCTION is_today_public_holiday RETURN BOOLEAN IS
    v_count NUMBER := 0;
  BEGIN
    SELECT COUNT(*) INTO v_count FROM public_holidays WHERE TRUNC(holiday_date) = TRUNC(SYSDATE);
    RETURN v_count > 0;
  EXCEPTION
    WHEN OTHERS THEN
     
      RETURN FALSE;
  END is_today_public_holiday;

  PROCEDURE check_dml_allowed IS
    v_day_abbr VARCHAR2(3);
  BEGIN
    v_day_abbr := TO_CHAR(SYSDATE,'DY','NLS_DATE_LANGUAGE=ENGLISH'); 
    IF v_day_abbr IN ('MON','TUE','WED','THU','FRI') THEN
      RAISE_APPLICATION_ERROR(-20001, 'DML operations are not allowed on weekdays by project policy.');
    END IF;

    
    IF is_today_public_holiday THEN
      RAISE_APPLICATION_ERROR(-20002, 'DML operations are not allowed on public holidays.');
    END IF;

 

  EXCEPTION
    WHEN OTHERS THEN

      RAISE;
  END check_dml_allowed;

END business_rules_pkg;
/
