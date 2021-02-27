--создаем таблицу входных данных, содержащую символьные строки
CREATE TABLE data_tab (str VARCHAR2(100) CONSTRAINT pk_data_tab PRIMARY KEY);

--создаем таблицу выходных данных
CREATE TABLE results ("Строка" VARCHAR2(100), "Подстрока" VARCHAR2(100), "Номер позиции начала 1" VARCHAR2(2),
"Номер позиции начала 2" VARCHAR2(2),
CONSTRAINT pk_results PRIMARY KEY ("Строка", "Подстрока"));

--заполняем таблицу
INSERT ALL
INTO data_tab VALUES ('oRACLEAoracleTjwlkggBjwlkgg')
INTO data_tab VALUES ('yyyyyyyy')
INTO data_tab VALUES ('create')
SELECT * FROM dual;
COMMIT;