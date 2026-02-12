-- Testes para os procedimentos de análise avançada em PL/SQL
-- Este arquivo contém exemplos de como os procedimentos PL/SQL seriam testados
-- em um ambiente Oracle Database ou similar.

-- Pré-requisitos:
-- 1. Um ambiente Oracle Database (ou compatível) com os procedimentos implantados.
-- 2. Acesso a um cliente SQL (SQL*Plus, SQL Developer, DBeaver, etc.).
-- 3. Os procedimentos em src/analytics_procedures.sql devem estar compilados no schema.

SET SERVEROUTPUT ON;

-- Bloco de inicialização para criar a tabela de teste
DECLARE
BEGIN
    -- Criar uma tabela de exemplo para demonstração
    EXECUTE IMMEDIATE 'DROP TABLE sales_data CASCADE CONSTRAINTS';
    DBMS_OUTPUT.PUT_LINE(TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || ' [INFO] Tabela sales_data removida (se existia).');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN -- ORA-00942: table or view does not exist
            RAISE;
        END IF;
END;
/

DECLARE
BEGIN
    -- Criar uma tabela de exemplo para demonstração
    EXECUTE IMMEDIATE '
        CREATE TABLE sales_data (
            sale_id NUMBER PRIMARY KEY,
            product_id NUMBER,
            sale_amount NUMBER,
            sale_date DATE,
            region VARCHAR2(50)
        )
    ';

    -- Inserir dados de exemplo, incluindo alguns outliers e dados para séries temporais
    INSERT INTO sales_data (sale_id, product_id, sale_amount, sale_date, region) VALUES (1, 101, 100.00, TO_DATE('2025-01-01', 'YYYY-MM-DD'), 'North');
    INSERT INTO sales_data (sale_id, product_id, sale_amount, sale_date, region) VALUES (2, 102, 150.50, TO_DATE('2025-01-01', 'YYYY-MM-DD'), 'South');
    INSERT INTO sales_data (sale_id, product_id, sale_amount, sale_date, region) VALUES (3, 101, 120.00, TO_DATE('2025-01-02', 'YYYY-MM-DD'), 'North');
    INSERT INTO sales_data (sale_id, product_id, sale_amount, sale_date, region) VALUES (4, 103, 200.00, TO_DATE('2025-01-02', 'YYYY-MM-DD'), 'East');
    INSERT INTO sales_data (sale_id, product_id, sale_amount, sale_date, region) VALUES (5, 102, 130.00, TO_DATE('2025-01-03', 'YYYY-MM-DD'), 'South');
    INSERT INTO sales_data (sale_id, product_id, sale_amount, sale_date, region) VALUES (6, 101, 110.00, TO_DATE('2025-01-03', 'YYYY-MM-DD'), 'North');
    INSERT INTO sales_data (sale_id, product_id, sale_amount, sale_date, region) VALUES (7, 104, 5000.00, TO_DATE('2025-01-04', 'YYYY-MM-DD'), 'West'); -- Outlier
    INSERT INTO sales_data (sale_id, product_id, sale_amount, sale_date, region) VALUES (8, 101, 105.00, TO_DATE('2025-01-04', 'YYYY-MM-DD'), 'North');
    INSERT INTO sales_data (sale_id, product_id, sale_amount, sale_date, region) VALUES (9, 105, 50.00, TO_DATE('2025-01-05', 'YYYY-MM-DD'), 'East');
    INSERT INTO sales_data (sale_id, product_id, sale_amount, sale_date, region) VALUES (10, 101, 115.00, TO_DATE('2025-01-05', 'YYYY-MM-DD'), 'North');
    INSERT INTO sales_data (sale_id, product_id, sale_amount, sale_date, region) VALUES (11, 106, 10.00, TO_DATE('2025-01-06', 'YYYY-MM-DD'), 'South'); -- Outlier
    INSERT INTO sales_data (sale_id, product_id, sale_amount, sale_date, region) VALUES (12, 101, 125.00, TO_DATE('2025-01-06', 'YYYY-MM-DD'), 'North');
    INSERT INTO sales_data (sale_id, product_id, sale_amount, sale_date, region) VALUES (13, 102, 140.00, TO_DATE('2025-02-01', 'YYYY-MM-DD'), 'South');
    INSERT INTO sales_data (sale_id, product_id, sale_amount, sale_date, region) VALUES (14, 103, 210.00, TO_DATE('2025-02-02', 'YYYY-MM-DD'), 'East');
    INSERT INTO sales_data (sale_id, product_id, sale_amount, sale_date, region) VALUES (15, 101, 110.00, TO_DATE('2025-02-03', 'YYYY-MM-DD'), 'North');
    COMMIT;

    DBMS_OUTPUT.PUT_LINE(TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || ' [INFO] Tabela sales_data criada e populada com sucesso para testes.');
END;
/

-- Teste 1: calculate_advanced_statistics
-- Objetivo: Verificar se as estatísticas descritivas avançadas são calculadas e exibidas.
DECLARE
BEGIN
    DBMS_OUTPUT.PUT_LINE(CHR(10) || TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || ' --- Teste: calculate_advanced_statistics ---');
    calculate_advanced_statistics('sales_data', 'sale_amount');
    -- A verificação detalhada da saída seria manual ou via parsing do DBMS_OUTPUT em um framework de teste.
    DBMS_OUTPUT.PUT_LINE(TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || ' [INFO] Verifique a saída acima para as estatísticas.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || ' [ERRO] Falha no teste calculate_advanced_statistics: ' || SQLERRM);
END;
/

-- Teste 2: calculate_moving_average_advanced (SMA sem particionamento)
-- Objetivo: Verificar se a query de SMA é gerada corretamente.
DECLARE
BEGIN
    DBMS_OUTPUT.PUT_LINE(CHR(10) || TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || ' --- Teste: calculate_moving_average_advanced (SMA) ---');
    calculate_moving_average_advanced('sales_data', 'sale_amount', 'sale_date', 3, p_ma_type => 'SMA');
    DBMS_OUTPUT.PUT_LINE(TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || ' [INFO] Verifique a query de SMA gerada acima.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || ' [ERRO] Falha no teste calculate_moving_average_advanced (SMA): ' || SQLERRM);
END;
/

-- Teste 3: calculate_moving_average_advanced (EMA com particionamento)
-- Objetivo: Verificar se a query de EMA particionada é gerada corretamente.
DECLARE
BEGIN
    DBMS_OUTPUT.PUT_LINE(CHR(10) || TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || ' --- Teste: calculate_moving_average_advanced (EMA com Particionamento) ---');
    calculate_moving_average_advanced('sales_data', 'sale_amount', 'sale_date', 2, 'region', 'EMA');
    DBMS_OUTPUT.PUT_LINE(TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || ' [INFO] Verifique a query de EMA particionada gerada acima.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || ' [ERRO] Falha no teste calculate_moving_average_advanced (EMA): ' || SQLERRM);
END;
/

-- Teste 4: find_outliers_iqr
-- Objetivo: Verificar se a detecção de outliers funciona e a query é exibida.
DECLARE
BEGIN
    DBMS_OUTPUT.PUT_LINE(CHR(10) || TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || ' --- Teste: find_outliers_iqr ---');
    find_outliers_iqr('sales_data', 'sale_amount');
    DBMS_OUTPUT.PUT_LINE(TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || ' [INFO] Verifique a saída para Q1, Q3 e a query de outliers.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || ' [ERRO] Falha no teste find_outliers_iqr: ' || SQLERRM);
END;
/

-- Teste 5: create_time_series_summary (Mensal)
-- Objetivo: Verificar se a tabela de resumo de séries temporais é criada.
DECLARE
    v_table_exists NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE(CHR(10) || TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || ' --- Teste: create_time_series_summary (Mensal) ---');
    create_time_series_summary('sales_data', 'sale_date', 'sale_amount', 'monthly_sales_summary', 'MONTH');

    -- Verificar se a tabela foi criada
    SELECT COUNT(*)
    INTO v_table_exists
    FROM all_tables
    WHERE owner = USER AND table_name = UPPER('monthly_sales_summary');

    IF v_table_exists = 1 THEN
        DBMS_OUTPUT.PUT_LINE(TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || ' [SUCESSO] Tabela monthly_sales_summary criada.');
        -- Opcional: Consultar alguns dados para verificar o conteúdo
        DBMS_OUTPUT.PUT_LINE(TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || ' [INFO] Conteúdo de monthly_sales_summary (primeiro registro):');
        FOR rec IN (SELECT period_start_date, sum_value FROM monthly_sales_summary ORDER BY period_start_date FETCH FIRST 1 ROWS ONLY) LOOP
            DBMS_OUTPUT.PUT_LINE('  Data: ' || TO_CHAR(rec.period_start_date, 'YYYY-MM-DD') || ', Soma: ' || TO_CHAR(rec.sum_value, 'FM999G999G999D00'));
        END LOOP;
    ELSE
        DBMS_OUTPUT.PUT_LINE(TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || ' [FALHA] Tabela monthly_sales_summary não foi criada.');
    END IF;

    -- Limpar a tabela de resumo criada para este teste
    EXECUTE IMMEDIATE 'DROP TABLE monthly_sales_summary';
    DBMS_OUTPUT.PUT_LINE(TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || ' [INFO] Tabela monthly_sales_summary removida.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || ' [ERRO] Falha no teste create_time_series_summary: ' || SQLERRM);
END;
/

-- Bloco de limpeza final para remover a tabela de teste
DECLARE
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE sales_data CASCADE CONSTRAINTS';
    DBMS_OUTPUT.PUT_LINE(TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || ' [INFO] Tabela sales_data removida ao final dos testes.');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN -- ORA-00942: table or view does not exist
            RAISE;
        END IF;
END;
/

-- Para executar estes testes:
-- 1. Conecte-se ao seu banco de dados Oracle usando um cliente SQL.
-- 2. Execute este script SQL.
-- 3. Analise a saída do DBMS_OUTPUT para verificar os resultados dos testes.

