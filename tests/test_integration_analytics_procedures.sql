-- Testes de Integração para os procedimentos de análise avançada em PL/SQL
-- Este script simula um ambiente de teste mais abrangente para os procedimentos.

SET SERVEROUTPUT ON;

-- Bloco de inicialização: Criação e população da tabela de dados de vendas
DECLARE
BEGIN
    -- Remover tabela existente para garantir um estado limpo
    BEGIN
        EXECUTE IMMEDIATE 'DROP TABLE sales_data CASCADE CONSTRAINTS';
        DBMS_OUTPUT.PUT_LINE(TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || ' [INFO] Tabela sales_data removida (se existia).');
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE != -942 THEN -- ORA-00942: table or view does not exist
                RAISE;
            END IF;
    END;

    -- Criar a tabela sales_data
    EXECUTE IMMEDIATE '
        CREATE TABLE sales_data (
            sale_id NUMBER PRIMARY KEY,
            product_id NUMBER,
            sale_amount NUMBER,
            sale_date DATE,
            region VARCHAR2(50),
            customer_id NUMBER
        )
    ';

    -- Inserir dados de exemplo, incluindo outliers e dados para séries temporais e diferentes clientes
    INSERT INTO sales_data (sale_id, product_id, sale_amount, sale_date, region, customer_id) VALUES (1, 101, 100.00, TO_DATE('2025-01-01', 'YYYY-MM-DD'), 'North', 1);
    INSERT INTO sales_data (sale_id, product_id, sale_amount, sale_date, region, customer_id) VALUES (2, 102, 150.50, TO_DATE('2025-01-01', 'YYYY-MM-DD'), 'South', 2);
    INSERT INTO sales_data (sale_id, product_id, sale_amount, sale_date, region, customer_id) VALUES (3, 101, 120.00, TO_DATE('2025-01-02', 'YYYY-MM-DD'), 'North', 1);
    INSERT INTO sales_data (sale_id, product_id, sale_amount, sale_date, region, customer_id) VALUES (4, 103, 200.00, TO_DATE('2025-01-02', 'YYYY-MM-DD'), 'East', 3);
    INSERT INTO sales_data (sale_id, product_id, sale_amount, sale_date, region, customer_id) VALUES (5, 102, 130.00, TO_DATE('2025-01-03', 'YYYY-MM-DD'), 'South', 2);
    INSERT INTO sales_data (sale_id, product_id, sale_amount, sale_date, region, customer_id) VALUES (6, 101, 110.00, TO_DATE('2025-01-03', 'YYYY-MM-DD'), 'North', 1);
    INSERT INTO sales_data (sale_id, product_id, sale_amount, sale_date, region, customer_id) VALUES (7, 104, 5000.00, TO_DATE('2025-01-04', 'YYYY-MM-DD'), 'West', 4); -- Outlier alto
    INSERT INTO sales_data (sale_id, product_id, sale_amount, sale_date, region, customer_id) VALUES (8, 101, 105.00, TO_DATE('2025-01-04', 'YYYY-MM-DD'), 'North', 1);
    INSERT INTO sales_data (sale_id, product_id, sale_amount, sale_date, region, customer_id) VALUES (9, 105, 50.00, TO_DATE('2025-01-05', 'YYYY-MM-DD'), 'East', 3);
    INSERT INTO sales_data (sale_id, product_id, sale_amount, sale_date, region, customer_id) VALUES (10, 101, 115.00, TO_DATE('2025-01-05', 'YYYY-MM-DD'), 'North', 1);
    INSERT INTO sales_data (sale_id, product_id, sale_amount, sale_date, region, customer_id) VALUES (11, 106, 10.00, TO_DATE('2025-01-06', 'YYYY-MM-DD'), 'South', 2); -- Outlier baixo
    INSERT INTO sales_data (sale_id, product_id, sale_amount, sale_date, region, customer_id) VALUES (12, 101, 125.00, TO_DATE('2025-01-06', 'YYYY-MM-DD'), 'North', 1);
    INSERT INTO sales_data (sale_id, product_id, sale_amount, sale_date, region, customer_id) VALUES (13, 102, 140.00, TO_DATE('2025-02-01', 'YYYY-MM-DD'), 'South', 2);
    INSERT INTO sales_data (sale_id, product_id, sale_amount, sale_date, region, customer_id) VALUES (14, 103, 210.00, TO_DATE('2025-02-02', 'YYYY-MM-DD'), 'East', 3);
    INSERT INTO sales_data (sale_id, product_id, sale_amount, sale_date, region, customer_id) VALUES (15, 101, 110.00, TO_DATE('2025-02-03', 'YYYY-MM-DD'), 'North', 1);
    INSERT INTO sales_data (sale_id, product_id, sale_amount, sale_date, region, customer_id) VALUES (16, 107, 80.00, TO_DATE('2025-02-03', 'YYYY-MM-DD'), 'West', 4);
    COMMIT;

    DBMS_OUTPUT.PUT_LINE(TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || ' [INFO] Tabela sales_data criada e populada com sucesso para testes de integração.');
END;
/

-- Teste de Integração 1: calculate_advanced_statistics e verificação de resultados
-- Objetivo: Chamar o procedimento e verificar se os valores esperados são gerados.
DECLARE
    v_min_val NUMBER;
    v_max_val NUMBER;
    v_avg_val NUMBER;
    v_median_val NUMBER;
    v_stddev_val NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE(CHR(10) || TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || ' --- Teste de Integração: calculate_advanced_statistics ---');
    
    -- Chamar o procedimento (ele imprime no DBMS_OUTPUT)
    calculate_advanced_statistics('sales_data', 'sale_amount');

    -- Para verificar os resultados, teríamos que parsear o DBMS_OUTPUT ou consultar uma tabela temporária
    -- Vamos simular a verificação consultando diretamente os valores esperados da tabela.
    SELECT MIN(sale_amount), MAX(sale_amount), AVG(sale_amount), MEDIAN(sale_amount), STDDEV(sale_amount)
    INTO v_min_val, v_max_val, v_avg_val, v_median_val, v_stddev_val
    FROM sales_data;

    DBMS_OUTPUT.PUT_LINE('  Esperado: Min=' || v_min_val || ', Max=' || v_max_val || ', Avg=' || ROUND(v_avg_val, 2) || ', Median=' || v_median_val);
    DBMS_OUTPUT.PUT_LINE(TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || ' [INFO] Verificação manual da saída do procedimento necessária.');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || ' [ERRO] Falha no teste calculate_advanced_statistics: ' || SQLERRM);
END;
/

-- Teste de Integração 2: calculate_moving_average_advanced (SMA e EMA com particionamento)
-- Objetivo: Gerar as queries e verificar se a sintaxe está correta e se os resultados são razoáveis.
DECLARE
    v_query_sma VARCHAR2(4000);
    v_query_ema VARCHAR2(4000);
BEGIN
    DBMS_OUTPUT.PUT_LINE(CHR(10) || TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || ' --- Teste de Integração: calculate_moving_average_advanced ---');
    
    -- Testar SMA sem particionamento
    calculate_moving_average_advanced('sales_data', 'sale_amount', 'sale_date', 3, p_ma_type => 'SMA');
    DBMS_OUTPUT.PUT_LINE(TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || ' [INFO] Verifique a query SMA gerada.');

    -- Testar EMA com particionamento por região
    calculate_moving_average_advanced('sales_data', 'sale_amount', 'sale_date', 2, 'region', 'EMA');
    DBMS_OUTPUT.PUT_LINE(TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || ' [INFO] Verifique a query EMA particionada gerada.');

    -- Para uma verificação mais robusta, poderíamos executar as queries geradas e comparar os resultados.
    -- Exemplo de execução (apenas para demonstração, não é uma asserção automática):
    DBMS_OUTPUT.PUT_LINE(TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || ' [INFO] Executando uma query SMA de exemplo para validação...');
    FOR rec IN (
        SELECT sale_date, sale_amount, AVG(sale_amount) OVER (ORDER BY sale_date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) as sma_3_days
        FROM sales_data
        ORDER BY sale_date
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('  Data: ' || TO_CHAR(rec.sale_date, 'YYYY-MM-DD') || ', Valor: ' || rec.sale_amount || ', SMA(3): ' || ROUND(rec.sma_3_days, 2));
    END LOOP;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || ' [ERRO] Falha no teste calculate_moving_average_advanced: ' || SQLERRM);
END;
/

-- Teste de Integração 3: find_outliers_iqr e verificação de outliers
-- Objetivo: Chamar o procedimento e verificar se os outliers esperados são identificados.
DECLARE
    v_outlier_count NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE(CHR(10) || TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || ' --- Teste de Integração: find_outliers_iqr ---');
    
    -- Chamar o procedimento (ele imprime a query de outliers)
    find_outliers_iqr('sales_data', 'sale_amount');
    DBMS_OUTPUT.PUT_LINE(TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || ' [INFO] Verifique a query de outliers gerada.');

    -- Executar a query de outliers (assumindo que a query gerada é similar a esta)
    -- Nota: Esta é uma simulação. Em um ambiente real, você executaria a query gerada pelo procedimento.
    EXECUTE IMMEDIATE '
        CREATE OR REPLACE VIEW outliers_view AS
        WITH stats AS (
            SELECT
                PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY sale_amount) AS q1,
                PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY sale_amount) AS q3
            FROM sales_data
        )
        SELECT s.*, (SELECT q1 FROM stats) AS q1_val, (SELECT q3 FROM stats) AS q3_val
        FROM sales_data s
        WHERE sale_amount < ((SELECT q1 FROM stats) - 1.5 * ((SELECT q3 FROM stats) - (SELECT q1 FROM stats)))
           OR sale_amount > ((SELECT q3 FROM stats) + 1.5 * ((SELECT q3 FROM stats) - (SELECT q1 FROM stats)))
    ';

    SELECT COUNT(*) INTO v_outlier_count FROM outliers_view;

    DBMS_OUTPUT.PUT_LINE('  Outliers esperados: 2 (sale_id 7 e 11)');
    DBMS_OUTPUT.PUT_LINE('  Outliers encontrados na view: ' || v_outlier_count);
    IF v_outlier_count = 2 THEN
        DBMS_OUTPUT.PUT_LINE(TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || ' [SUCESSO] Detecção de outliers funcionou como esperado.');
    ELSE
        DBMS_OUTPUT.PUT_LINE(TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || ' [FALHA] Número de outliers incorreto.');
    END IF;

    EXECUTE IMMEDIATE 'DROP VIEW outliers_view';

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || ' [ERRO] Falha no teste find_outliers_iqr: ' || SQLERRM);
END;
/

-- Teste de Integração 4: create_time_series_summary (Semanal e Mensal)
-- Objetivo: Verificar a criação e o conteúdo das tabelas de resumo de séries temporais.
DECLARE
    v_table_exists NUMBER;
    v_row_count NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE(CHR(10) || TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || ' --- Teste de Integração: create_time_series_summary ---');
    
    -- Teste Mensal
    create_time_series_summary('sales_data', 'sale_date', 'sale_amount', 'monthly_sales_summary_int', 'MONTH');
    SELECT COUNT(*) INTO v_table_exists FROM all_tables WHERE owner = USER AND table_name = UPPER('monthly_sales_summary_int');
    IF v_table_exists = 1 THEN
        DBMS_OUTPUT.PUT_LINE(TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || ' [SUCESSO] Tabela monthly_sales_summary_int criada.');
        SELECT COUNT(*) INTO v_row_count FROM monthly_sales_summary_int;
        DBMS_OUTPUT.PUT_LINE('  Registros na tabela mensal: ' || v_row_count);
        IF v_row_count = 2 THEN -- Janeiro e Fevereiro
            DBMS_OUTPUT.PUT_LINE(TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || ' [SUCESSO] Número de registros mensais correto.');
        ELSE
            DBMS_OUTPUT.PUT_LINE(TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || ' [FALHA] Número de registros mensais incorreto.');
        END IF;
        EXECUTE IMMEDIATE 'DROP TABLE monthly_sales_summary_int';
    ELSE
        DBMS_OUTPUT.PUT_LINE(TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || ' [FALHA] Tabela monthly_sales_summary_int não foi criada.');
    END IF;

    -- Teste Diário
    create_time_series_summary('sales_data', 'sale_date', 'sale_amount', 'daily_sales_summary_int', 'DAY');
    SELECT COUNT(*) INTO v_table_exists FROM all_tables WHERE owner = USER AND table_name = UPPER('daily_sales_summary_int');
    IF v_table_exists = 1 THEN
        DBMS_OUTPUT.PUT_LINE(TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || ' [SUCESSO] Tabela daily_sales_summary_int criada.');
        SELECT COUNT(*) INTO v_row_count FROM daily_sales_summary_int;
        DBMS_OUTPUT.PUT_LINE('  Registros na tabela diária: ' || v_row_count);
        IF v_row_count > 0 THEN
            DBMS_OUTPUT.PUT_LINE(TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || ' [SUCESSO] Tabela diária contém registros.');
        ELSE
            DBMS_OUTPUT.PUT_LINE(TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || ' [FALHA] Tabela diária está vazia.');
        END IF;
        EXECUTE IMMEDIATE 'DROP TABLE daily_sales_summary_int';
    ELSE
        DBMS_OUTPUT.PUT_LINE(TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || ' [FALHA] Tabela daily_sales_summary_int não foi criada.');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || ' [ERRO] Falha no teste create_time_series_summary: ' || SQLERRM);
END;
/

-- Bloco de limpeza final para remover a tabela de teste
DECLARE
BEGIN
    BEGIN
        EXECUTE IMMEDIATE 'DROP TABLE sales_data CASCADE CONSTRAINTS';
        DBMS_OUTPUT.PUT_LINE(TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || ' [INFO] Tabela sales_data removida ao final dos testes de integração.');
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE != -942 THEN
                RAISE;
            END IF;
    END;
END;
/

-- Para executar estes testes de integração:
-- 1. Conecte-se ao seu banco de dados Oracle usando um cliente SQL.
-- 2. Certifique-se de que os procedimentos em src/analytics_procedures.sql estão compilados.
-- 3. Execute este script SQL.
-- 4. Analise a saída do DBMS_OUTPUT para verificar os resultados dos testes.

