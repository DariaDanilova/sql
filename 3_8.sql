SELECT ucc.constraint_name AS fk_name, ucc.table_name AS fk_table, ucc.column_name AS fk_col,
       uc�_parent.table_name AS pk_table, uc�_parent.column_name AS pk_col
FROM user_cons_columns ucc -- ���������� � ��������, ������� �������� ��� �����������
JOIN user_constraints uc -- �������� �������� ����������� ������ ������������
ON ucc.constraint_name = uc.constraint_name
JOIN user_cons_columns uc�_parent -- ������������, ����� ����������� 4 � 5 ������� ������
ON uc.r_constraint_name = uc�_parent.constraint_name
WHERE uc.constraint_type = 'R' AND ucc.position = uc�_parent.position /* "R" - ��� ����������� �������� �����,
                    ��������� ��������� position, �.�. ������� ���� ����� �������� �� ���������� ��������.*/
ORDER BY 2, 1, 3;
