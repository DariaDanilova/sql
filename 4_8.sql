-- Формировать таблицу для отчета будем последовательно.
WITH 
table_v1 AS -- отчет по всем зарплатам сотрудников в каждом отделе.
(SELECT department_id, 
        CASE 
            WHEN salary IS NULL AND GROUPING(salary) = 0 
            THEN NVL(salary, 0) else employees.salary 
        END salary, 
GROUPING(department_id) AS grouping_dep_id, GROUPING(salary) AS grouping_salary
FROM employees
GROUP BY ROLLUP(department_id, salary)
ORDER BY department_id, salary NULLS FIRST -- чтобы в последствии номер отдела был сверху
),

table_v2 AS -- добавляем к предыдущей таблице столбец rownum
(SELECT ROWNUM rn, department_id, salary, grouping_dep_id, grouping_salary
FROM table_v1),

table_v3 AS -- добавляем к предыдущей таблице столбец с именами соответствующих сотрудников и столбец с названиями отделов
(SELECT t2.rn, t2.department_id, e.first_name, e.last_name, TO_CHAR(t2.salary) AS salary, d.department_name, t2.grouping_dep_id, t2.grouping_salary
FROM table_v2 t2 
LEFT JOIN employees e -- LEFT, поскольку столбец salary содержит null
ON t2.department_id = e.department_id AND NVL(t2.salary, 0) = NVL(e.salary, 0) -- NVL, иначе не получится сравнить ячейки, где null значения
AND t2.grouping_salary = 0 -- чтобы не внести изменения в строки промежуточных итогов
JOIN departments d
ON t2.department_id = d.department_id
WHERE t2.department_id IS NOT NULL -- чтобы исключить сотрудников без отдела, а также итоговую строку
ORDER BY t2.rn)

SELECT CASE
            WHEN grouping_salary = 0 THEN NVL(first_name, ' ')
            ELSE 'Отдел №'
       END first_name, 
       
       CASE
            WHEN grouping_salary = 0 THEN last_name
            ELSE TO_CHAR(department_id)
       END last_name, 
       
       CASE 
            WHEN grouping_salary = 1 THEN ('«' || department_name || '»')
            ELSE NVL(salary, 0)
       END salary
FROM table_v3;
