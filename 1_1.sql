DEFINE string = '222'
SELECT '&string' AS "Строка",
    NVL((LENGTH('&string') - LENGTH(REPLACE('&string', '1', ''))), LENGTH('&string')) +  -- Вычитая длину измененной строки из длины исходной, получим сколько раз встречается требуемая цифра.
2 * NVL((LENGTH('&string') - LENGTH(REPLACE('&string', '2', ''))), LENGTH('&string')) +  -- Умножаем на 2, чтобы получить количество двойки в строке.
3 * NVL((LENGTH('&string') - LENGTH(REPLACE('&string', '3', ''))), LENGTH('&string')) +     
4 * NVL((LENGTH('&string') - LENGTH(REPLACE('&string', '4', ''))), LENGTH('&string')) +
5 * NVL((LENGTH('&string') - LENGTH(REPLACE('&string', '5', ''))), LENGTH('&string')) + 
6 * NVL((LENGTH('&string') - LENGTH(REPLACE('&string', '6', ''))), LENGTH('&string')) +
7 * NVL((LENGTH('&string') - LENGTH(REPLACE('&string', '7', ''))), LENGTH('&string')) + 
8 * NVL((LENGTH('&string') - LENGTH(REPLACE('&string', '8', ''))), LENGTH('&string')) +
9 * NVL((LENGTH('&string') - LENGTH(REPLACE('&string', '9', ''))), LENGTH('&string')) AS "Сумма цифр"
FROM dual;




