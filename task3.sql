DEFINE chosen_date = '-11.2.2'
WITH 
recursion(n) AS
( -- рекурсия
SELECT TO_DATE('&&chosen_date', 'YYYY.MM.DD') AS n
FROM dual
UNION ALL
SELECT n - 7 AS n
FROM recursion
WHERE n > TO_DATE('&&chosen_date', 'YYYY.MM.DD') - 21
)
SELECT TO_CHAR(n, 'DD.MM.YYYY') AS results --преобразуем данные к требуемому виду
FROM recursion
-- для дат начиная с 21 декабря 1 года. Будет выводиться менее 3 предшествующих недель.
WHERE TO_CHAR(n,'DD.MM.YYYY') != '00.00.0000';