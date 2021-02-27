SET DEFINE OFF;

DECLARE
v_j NUMBER(3);
v_max_len_substr VARCHAR2(20);
indx NUMBER(5) := 0;
v_current_row data_tab.str%TYPE; --текущая строка таблицы data_tab
v_substr_str data_tab.str%TYPE; --подстрока текущей строки

-- индексная таблица для хранения записей подстрок текущей строки
TYPE str_table_type IS TABLE OF data_tab.str%TYPE
INDEX BY PLS_INTEGER;
current_substrs str_table_type; --текущие подстроки текущей строки
true_substrs str_table_type; --только подстроки, удовлетворяющие условию задачи

e_big_row_or_empty_table EXCEPTION;
PRAGMA EXCEPTION_INIT(e_big_row_or_empty_table, -06512);
e_buffer_overflow EXCEPTION;
PRAGMA EXCEPTION_INIT(e_buffer_overflow, -20000);
e_row_in_table EXCEPTION;
PRAGMA EXCEPTION_INIT(e_row_in_table, -00001);
e_big_value EXCEPTION;
PRAGMA EXCEPTION_INIT(e_big_value, -06502);

BEGIN
    --итерируемся по каждой текущей строке таблицы data_tab
    FOR row_i IN (SELECT str FROM data_tab) LOOP
        v_current_row := LOWER(row_i.str);
        
        v_j := 0;
        --итерируемся по каждому элементу текущей строки <=> начальный символ подстроки
        FOR fisrt_sym IN 1..LENGTH(v_current_row) LOOP
            v_substr_str := SUBSTR(v_current_row, fisrt_sym, 1);
           
            v_j := v_j + 1;
            current_substrs(v_j) := v_substr_str;
            
            --начиная с начального символа подстроки до конца строки, формируем всевозможные подстроки
            FOR symbol_len IN fisrt_sym+1..LENGTH(v_current_row) LOOP
                v_substr_str := v_substr_str || SUBSTR(v_current_row, symbol_len, 1);
              DBMS_OUTPUT.PUT_LINE(v_substr_str);
            
                v_j := v_j + 1;
              --заполняем индексную таблицу
                current_substrs(v_j) := v_substr_str;
            END LOOP;
            --DBMS_OUTPUT.PUT_LINE(fisrt_sym);
            v_substr_str := ' ';
        END LOOP;
        
        --вывод индексной таблицы
       /*  for i in 1..v_j loop
              DBMS_OUTPUT.PUT_LINE(v_current_row || ' index ' || i || ' value ' || TO_CHAR(current_substrs(i)));
            end loop;*/

        --подстроки, встречающиеся ровно 2 раза   
        FOR i IN 1..v_j LOOP
            IF regexp_count(v_current_row, TO_CHAR(current_substrs(i))) != 2 THEN
             -- DBMS_OUTPUT.PUT_LINE(current_substrs(i) || ' deleted');
              current_substrs.DELETE(i);
              --else DBMS_OUTPUT.PUT_LINE(v_current_row || ' index ' || i ||' '|| current_substrs(i) || ' not deleted');
            END IF;
        END LOOP;
              
        -- находим максимальную по длине подстроку в каждой строке
        v_max_len_substr := '';
        FOR i IN 1..v_j LOOP
            IF current_substrs.EXISTS(i) THEN
                IF LENGTH(current_substrs(i)) > nvl(LENGTH(v_max_len_substr), 0) THEN 
                    v_max_len_substr := current_substrs(i);
                END IF;
            ELSE CONTINUE; END IF;
            END LOOP;
      --  DBMS_OUTPUT.PUT_LINE(v_max_len_substr);
        
        -- удалим элементы длины, которых не равны длине v_max_len_substr
        FOR i IN 1..v_j LOOP
            IF current_substrs.EXISTS(i) THEN
                IF LENGTH(current_substrs(i)) != LENGTH(v_max_len_substr) then 
                    current_substrs.DELETE(i);
                END IF;
            END IF;
        END LOOP;
        
        --посмотреть результат после удаления
        /*FOR i IN 1..v_j LOOP
            IF current_substrs.EXISTS(i) THEN
                dbms_output.put_line(i || '  ' || current_substrs(i));
            end if;
          end loop;*/
        
       -- удалим дубли подходящих нам по условию задачи подстрок
        FOR i IN 1..v_j LOOP
            IF current_substrs.EXISTS(i) THEN
                IF i != current_substrs.FIRST AND current_substrs(i) = current_substrs(current_substrs.PRIOR(i)) AND 
                LENGTH(current_substrs(i)) = LENGTH(v_max_len_substr) THEN
                --dbms_output.put_line(i || ' deleted ' || current_substrs(i));
                current_substrs.DELETE(i);
                END IF;
            END IF;
        END LOOP;
        
    --проходимся по всей индексной таблице подстрок и заносим в новую индексную таблицу true_substrs элементы из current_substrs
       indx := 0;
       FOR i IN 1..v_j LOOP
            IF current_substrs.EXISTS(i) THEN
                    --dbms_output.put_line(i || ' ' || current_substrs(i)); 
                    indx := indx + 1;
                    true_substrs(indx) := current_substrs(i);
                  -- dbms_output.put_line(indx || ' ' ||true_substrs(indx));
                END IF;
        END LOOP;
        
        --заносим результаты в итоговую таблицу results
        IF true_substrs.LAST IS NULL 
            THEN INSERT INTO results VALUES(v_current_row, '-', '-', '-');
        ELSE
            indx := true_substrs.FIRST;
            WHILE indx IS NOT null LOOP
                IF indx != true_substrs.FIRST THEN
                    INSERT INTO results VALUES(' ', true_substrs(indx), regexp_instr(v_current_row, true_substrs(indx)),
                                                regexp_instr(v_current_row, true_substrs(indx), 1, 2));
                ELSE 
                    INSERT INTO  results VALUES(row_i.str, true_substrs(indx), regexp_instr(v_current_row, true_substrs(indx)),
                                                regexp_instr(v_current_row, true_substrs(indx), 1, 2));
                END IF;
                indx := true_substrs.NEXT(indx); 
             END LOOP;
        END IF;
        
        --очищаем индексную таблицу для следующих новых подстрок
        true_substrs.DELETE;
    END LOOP;

    EXCEPTION
        WHEN e_buffer_overflow THEN DBMS_OUTPUT.PUT_LINE('ERROR! Buffer overflow, limit of 20000 bytes!');
        WHEN e_big_row_or_empty_table THEN DBMS_OUTPUT.PUT_LINE('ERROR! The table is empty or some row is too big');
        WHEN e_row_in_table THEN DBMS_OUTPUT.PUT_LINE('ERROR! The row is already in the table.');
        WHEN e_big_value THEN DBMS_OUTPUT.PUT_LINE('ERROR! Too big value.');
        WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('some error');
END;
/

SELECT *
FROM results;

truncate table results;