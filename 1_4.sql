DECLARE
    v_dept_name    departments.department_name%TYPE;
    v_dept_id   departments.department_id%TYPE;
BEGIN
    SELECT department_name, department_id
    INTO v_dept_name, v_dept_id
    FROM(SELECT department_name, department_id
         FROM departments d
         LEFT JOIN locations l
         ON d.location_id = l.location_id
         WHERE city = 'Southlake'
         ORDER BY department_id)--если таких департаментов несколько оставляем один,
    WHERE ROWNUM = 1;           -- с наименьшим значением department_id

    dbms_output.put_line('Департамент ' || v_dept_name || ' ' || v_dept_id || ' находится в городе Southlake');
END;
/