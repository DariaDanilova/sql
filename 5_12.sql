WITH data_table AS -- исходные данные
(
SELECT 'rtyew' AS str FROM dual
UNION ALL
SELECT 'trrwye' FROM dual
UNION ALL
SELECT 'aabc' FROM dual
UNION ALL
SELECT 'baca' FROM dual
UNION ALL
SELECT 'trwye' FROM dual
),

str_RN AS -- добавляем нумерацию строк к исходным данным
(
SELECT ROWNUM rn_str, str
FROM data_table
),

max_str_length AS -- столбец из длины самого длинного слова (от 1 до макс.длины)
(
SELECT LEVEL occure_number
FROM dual
CONNECT BY LEVEL <= (SELECT MAX(LENGTH(str))
                     FROM data_table)),

str_occurrences AS -- выводим слова столько раз, какова их длина 
(
SELECT data_table.str, m.occure_number
FROM data_table
JOIN max_str_length m
ON m.occure_number <= LENGTH(data_table.str)
),

str_to_column AS -- преобразуем строку в столбец, используя occure_number из таблицы str_occurrences
(
SELECT SUBSTR(ss.str, occure_number, 1) AS symbol, ss.str, rn_str
FROM str_occurrences ss
JOIN str_RN
ON str_RN.str = ss.str
ORDER BY 3,1
),

str_to_column_v2 AS -- пронумеруем все строки таблицы str_to_column
(
SELECT ROWNUM rn_symbols, symbol, rn_str, str 
FROM str_to_column
),

column_to_str AS -- преобразуем столбец обратно в строки
( -- строки которые изначально в таблице data_table различались только порядком, при "сборке" получатся одинаковыми 
SELECT DISTINCT SYS_CONNECT_BY_PATH(symbol,'->') AS symbols, rn_symbols
FROM str_to_column_v2
WHERE CONNECT_BY_ISLEAF = 1 -- =1, если строка не имеет наследников
START WITH rn_symbols IN (SELECT MIN(rn_symbols) 
                   FROM str_to_column_v2 
                   GROUP BY rn_str)
CONNECT BY PRIOR rn_symbols = rn_symbols-1 AND PRIOR rn_str = rn_str
),

final_str AS -- оставляем только не повторяющиеся строки по столбцу symbols
(
SELECT symbols, MIN(rn_symbols) AS rn_symbols
FROM column_to_str
GROUP BY symbols
),
-- формируем итог
results AS ( -- формируем итог
SELECT sv2.str "RESULT"
FROM final_str f
JOIN str_to_column_v2 sv2 -- соединяем с str_to_column_v2, т.к. в ней есть столбец с исходными данными
ON f.rn_symbols = sv2.rn_symbols)

SELECT *
FROM results;