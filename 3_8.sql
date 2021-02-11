SELECT ucc.constraint_name AS fk_name, ucc.table_name AS fk_table, ucc.column_name AS fk_col,
       ucс_parent.table_name AS pk_table, ucс_parent.column_name AS pk_col
FROM user_cons_columns ucc -- информация о колонках, которые попадают под ограничения
JOIN user_constraints uc -- содержит описания ограничений таблиц пользователя
ON ucc.constraint_name = uc.constraint_name
JOIN user_cons_columns ucс_parent -- присоединяем, чтобы выполнялись 4 и 5 условия задачи
ON uc.r_constraint_name = ucс_parent.constraint_name
WHERE uc.constraint_type = 'R' AND ucc.position = ucс_parent.position /* "R" - тип ограничения внешнего ключа,
                    указываем равенство position, т.к. внешний ключ может состоять из нескольких столбцов.*/
ORDER BY 2, 1, 3;
