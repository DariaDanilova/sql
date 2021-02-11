-- создаем исходную таблицу
CREATE TABLE "Test"
("Дата" DATE CONSTRAINT pk_test Primary Key, "Сумма" NUMBER(5, 2));

-- заполняем ее данными
INSERT INTO "Test"
VALUES ('27.02.2020', '312,00');
INSERT INTO "Test"
VALUES ('05.03.2020', '833,00');
INSERT INTO "Test"
VALUES ('12.03.2020', '225,00');
INSERT INTO "Test"
VALUES ('19.03.2020', '453,00');
INSERT INTO "Test"
VALUES ('26.03.2020', '774,00');
INSERT INTO "Test"
VALUES ('02.04.2020', '719,00');
INSERT INTO "Test"
VALUES ('09.04.2020', '136,00');
INSERT INTO "Test"
VALUES ('16.04.2020', '133,00');
INSERT INTO "Test"
VALUES ('23.04.2020', '157,00');
INSERT INTO "Test"
VALUES ('30.04.2020', '850,00');
INSERT INTO "Test"
VALUES ('07.05.2020', '940,00');
INSERT INTO "Test"
VALUES ('14.05.2020', '933,00');
INSERT INTO "Test"
VALUES ('21.05.2020', '422,00');
INSERT INTO "Test"
VALUES ('28.05.2020', '952,00');
INSERT INTO "Test"
VALUES ('04.06.2020', '136,00');
INSERT INTO "Test"
VALUES ('11.06.2020', '701,00');

WITH
monthly_date AS
( -- добавляем столбец true_date с последним числом месяца
SELECT "Дата", "Сумма", LAST_DAY("Дата") AS true_date
FROM "Test"
),
monthly_date_v2 AS
( -- распределяем правильно сумму по месяцам
SELECT "Дата", "Сумма", true_date, 
        CASE 
        WHEN true_date - "Дата" < 7
        THEN "Сумма" + (LEAD("Сумма", 1, 0) OVER (ORDER BY "Дата"))/7*(true_date - "Дата")
        WHEN LAG(true_date - "Дата", 1, 0) OVER (ORDER BY "Дата") < 7
        THEN "Сумма"/7*(7 - LAG(true_date - "Дата", 1, 0) OVER (ORDER BY "Дата"))
        ELSE "Сумма"
        END AS right_sum
FROM monthly_date
),
results AS
( -- приводим данные к требуемому виду
SELECT TO_CHAR(true_date, 'DD.mon.YY') AS "Дата мес", REPLACE(TO_CHAR(ROUND(SUM(right_sum), 2), '99999.99'), '.', ',') AS "Сумма"
FROM monthly_date_v2
GROUP BY true_date
ORDER BY true_date
)
-- выводим данные и добавляем последнюю строку с 0 рублями
SELECT *
FROM results
UNION ALL
SELECT TO_CHAR(LAST_DAY(MAX(TO_DATE("Дата мес"))+1), 'DD.mon.YY') AS "Дата мес", '0,00' AS "Сумма"
FROM results;