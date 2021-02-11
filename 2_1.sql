WITH t1 AS
-- t1. ��������� �������, ����� ����� ���� ���������� ������� ������� �������� �/� ������, ��� ������������ �� ������� ������������
(SELECT e.department_id, e.last_name, e.salary, COUNT(DISTINCT col.salary) count_coll
FROM employees e
LEFT JOIN employees col -- LEFT, ����� ������� ���� ����������� �� ������� �����������
ON e.department_id = col.department_id AND e.salary > col.salary /* ������� e.employee_id != col.employee_id �� ����� ��������,
                                                                 �.�. ���� ���������� ��� ������������(����� ��� �� ����� ������).
                                                                 ��������� ������ ������� � ������ WHERE ������: 
                                                                 WHERE e.salary > col.salary �� ����������� �������.*/
GROUP BY e.department_id, e.last_name, e.salary
ORDER BY e.department_id, e.last_name, e.salary DESC)

-- t2. ����� ������������ ����� � ������������
, t2 AS
(SELECT emp.department_id, COUNT(DISTINCT col.salary) min_ranck
FROM employees emp
LEFT JOIN employees col 
ON emp.department_id = col.department_id AND emp.salary > col.salary                                          
GROUP BY emp.department_id)

SELECT t1.department_id, t1.last_name, t1.salary, 
CASE WHEN salary IS NULL THEN NULL 
ELSE t2.min_ranck - t1.count_coll + 1 END AS salary_ranc
FROM t1
LEFT JOIN t2
ON t2.department_id = t1.department_id
ORDER BY t1.department_id, salary_ranc;

