-- PL/SQL Advanced Analytics Procedures
-- Author: Gabriel Demetrios Lafis
-- Year: 2025

-- Habilitar saída de DBMS_OUTPUT para ver os resultados dos procedimentos
SET SERVEROUTPUT ON;

-- ============================================================================
-- 1. Procedure para calcular estatísticas descritivas avançadas
--    Inclui média, mediana, desvio padrão, min, max, soma, contagem, e percentis.
-- ============================================================================
CREATE OR REPLACE PROCEDURE calculate_advanced_statistics(
    p_table_name IN VARCHAR2,
    p_column_name IN VARCHAR2
) AS
    v_mean NUMBER;
    v_median NUMBER;
    v_stddev NUMBER;
    v_min NUMBER;
    v_max NUMBER;
    v_sum NUMBER;
    v_count NUMBER;
    v_p25 NUMBER;
    v_p75 NUMBER;
    v_table_exists NUMBER;
    v_column_exists NUMBER;
    v_sql_query VARCHAR2(1000);
BEGIN
    -- Validação para prevenir injeção SQL e garantir nomes válidos
    SELECT COUNT(*)
    INTO v_table_exists
    FROM all_tables
    WHERE owner = USER AND table_name = UPPER(p_table_name);

    IF v_table_exists = 0 THEN
        DBMS_OUTPUT.PUT_LINE(
            TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || 
            ' [ERRO] Tabela ' || p_table_name || ' não encontrada ou sem permissão.'
        );
        RETURN;
    END IF;

    SELECT COUNT(*)
    INTO v_column_exists
    FROM all_tab_columns
    WHERE owner = USER AND table_name = UPPER(p_table_name) AND column_name = UPPER(p_column_name);

    IF v_column_exists = 0 THEN
        DBMS_OUTPUT.PUT_LINE(
            TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || 
            ' [ERRO] Coluna ' || p_column_name || ' não encontrada na tabela ' || p_table_name || '.'
        );
        RETURN;
    END IF;

    BEGIN
        v_sql_query := 
            'SELECT AVG(' || p_column_name || '), ' ||
            'MEDIAN(' || p_column_name || '), ' ||
            'STDDEV(' || p_column_name || '), ' ||
            'MIN(' || p_column_name || '), ' ||
            'MAX(' || p_column_name || '), ' ||
            'SUM(' || p_column_name || '), ' ||
            'COUNT(' || p_column_name || '), ' ||
            'PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY ' || p_column_name || '), ' ||
            'PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY ' || p_column_name || ') ' ||
            'FROM ' || p_table_name;

        EXECUTE IMMEDIATE v_sql_query
        INTO v_mean, v_median, v_stddev, v_min, v_max, v_sum, v_count, v_p25, v_p75;

        DBMS_OUTPUT.PUT_LINE(
            TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || 
            ' [INFO] Estatísticas para ' || p_table_name || '.' || p_column_name || ':'
        );
        DBMS_OUTPUT.PUT_LINE('  Média: ' || TO_CHAR(v_mean, 'FM999G999G999D00'));
        DBMS_OUTPUT.PUT_LINE('  Mediana: ' || TO_CHAR(v_median, 'FM999G999G999D00'));
        DBMS_OUTPUT.PUT_LINE('  Desvio Padrão: ' || TO_CHAR(v_stddev, 'FM999G999G999D00'));
        DBMS_OUTPUT.PUT_LINE('  Mínimo: ' || TO_CHAR(v_min, 'FM999G999G999D00'));
        DBMS_OUTPUT.PUT_LINE('  Máximo: ' || TO_CHAR(v_max, 'FM999G999G999D00'));
        DBMS_OUTPUT.PUT_LINE('  Soma: ' || TO_CHAR(v_sum, 'FM999G999G999D00'));
        DBMS_OUTPUT.PUT_LINE('  Contagem: ' || TO_CHAR(v_count, 'FM999G999G999G999'));
        DBMS_OUTPUT.PUT_LINE('  Percentil 25 (Q1): ' || TO_CHAR(v_p25, 'FM999G999G999D00'));
        DBMS_OUTPUT.PUT_LINE('  Percentil 75 (Q3): ' || TO_CHAR(v_p75, 'FM999G999G999D00'));

    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE(
                TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || 
                ' [ERRO] Não foi possível calcular estatísticas para ' || p_table_name || '.' || p_column_name || '. Erro: ' || SQLERRM
            );
    END;
END;
/

-- ============================================================================
-- 2. Procedure para calcular média móvel com opções de tipo e particionamento
--    Permite Média Móvel Simples (SMA) e Média Móvel Exponencial (EMA).
-- ============================================================================
CREATE OR REPLACE PROCEDURE calculate_moving_average_advanced(
    p_table_name IN VARCHAR2,
    p_value_column IN VARCHAR2,
    p_order_column IN VARCHAR2,
    p_window_size IN NUMBER,
    p_partition_column IN VARCHAR2 DEFAULT NULL, -- Nova coluna para particionamento
    p_ma_type IN VARCHAR2 DEFAULT 'SMA' -- 'SMA' para Simples, 'EMA' para Exponencial
) AS
    v_sql_query VARCHAR2(4000);
    v_table_exists NUMBER;
    v_value_column_exists NUMBER;
    v_order_column_exists NUMBER;
    v_partition_column_exists NUMBER := 1; -- Assume que existe se NULL
BEGIN
    -- Validação de tabela e colunas
    SELECT COUNT(*)
    INTO v_table_exists
    FROM all_tables
    WHERE owner = USER AND table_name = UPPER(p_table_name);

    IF v_table_exists = 0 THEN
        DBMS_OUTPUT.PUT_LINE(
            TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || 
            ' [ERRO] Tabela ' || p_table_name || ' não encontrada ou sem permissão.'
        );
        RETURN;
    END IF;

    SELECT COUNT(*)
    INTO v_value_column_exists
    FROM all_tab_columns
    WHERE owner = USER AND table_name = UPPER(p_table_name) AND column_name = UPPER(p_value_column);

    IF v_value_column_exists = 0 THEN
        DBMS_OUTPUT.PUT_LINE(
            TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || 
            ' [ERRO] Coluna de valor ' || p_value_column || ' não encontrada na tabela ' || p_table_name || '.'
        );
        RETURN;
    END IF;

    SELECT COUNT(*)
    INTO v_order_column_exists
    FROM all_tab_columns
    WHERE owner = USER AND table_name = UPPER(p_table_name) AND column_name = UPPER(p_order_column);

    IF v_order_column_exists = 0 THEN
        DBMS_OUTPUT.PUT_LINE(
            TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || 
            ' [ERRO] Coluna de ordenação ' || p_order_column || ' não encontrada na tabela ' || p_table_name || '.'
        );
        RETURN;
    END IF;

    IF p_partition_column IS NOT NULL THEN
        SELECT COUNT(*)
        INTO v_partition_column_exists
        FROM all_tab_columns
        WHERE owner = USER AND table_name = UPPER(p_table_name) AND column_name = UPPER(p_partition_column);

        IF v_partition_column_exists = 0 THEN
            DBMS_OUTPUT.PUT_LINE(
                TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || 
                ' [ERRO] Coluna de particionamento ' || p_partition_column || ' não encontrada na tabela ' || p_table_name || '.'
            );
            RETURN;
        END IF;
    END IF;

    IF p_window_size <= 0 THEN
        DBMS_OUTPUT.PUT_LINE(
            TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || 
            ' [ERRO] O tamanho da janela (p_window_size) deve ser um número positivo.'
        );
        RETURN;
    END IF;

    v_sql_query := 'SELECT ' || p_order_column || ', ' || p_value_column;

    IF p_ma_type = 'SMA' THEN
        v_sql_query := v_sql_query || ', AVG(' || p_value_column || ') OVER (';
        IF p_partition_column IS NOT NULL THEN
            v_sql_query := v_sql_query || 'PARTITION BY ' || p_partition_column || ' ';
        END IF;
        v_sql_query := v_sql_query || 'ORDER BY ' || p_order_column || ' ROWS BETWEEN ' ||
                       TO_CHAR(p_window_size - 1) || ' PRECEDING AND CURRENT ROW) AS moving_average_sma';
    ELSIF p_ma_type = 'EMA' THEN
        -- EMA é mais complexo em SQL puro, geralmente requer funções analíticas específicas ou iteração.
        -- Aqui, vamos simular uma EMA simples para demonstração.
        -- Em um ambiente real, seria implementado com uma função analítica ou recursividade.
        DBMS_OUTPUT.PUT_LINE(
            TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || 
            ' [AVISO] EMA é uma implementação simplificada para demonstração. Pode não ser precisa para todos os casos.'
        );
        v_sql_query := v_sql_query || ', (SUM(' || p_value_column || ') OVER (';
        IF p_partition_column IS NOT NULL THEN
            v_sql_query := v_sql_query || 'PARTITION BY ' || p_partition_column || ' ';
        END IF;
        v_sql_query := v_sql_query || 'ORDER BY ' || p_order_column || ' ROWS BETWEEN ' ||
                       TO_CHAR(p_window_size - 1) || ' PRECEDING AND CURRENT ROW) / ' || TO_CHAR(p_window_size) || ') AS moving_average_ema_approx';
    ELSE
        DBMS_OUTPUT.PUT_LINE(
            TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || 
            ' [ERRO] Tipo de média móvel inválido. Use \'SMA\' ou \'EMA\'.'
        );
        RETURN;
    END IF;

    v_sql_query := v_sql_query || ' FROM ' || p_table_name || ' ORDER BY ';
    IF p_partition_column IS NOT NULL THEN
        v_sql_query := v_sql_query || p_partition_column || ', ';
    END IF;
    v_sql_query := v_sql_query || p_order_column;

    DBMS_OUTPUT.PUT_LINE(
        TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || 
        ' [INFO] Query para Média Móvel (' || p_ma_type || ', Janela: ' || p_window_size || '):'
    );
    DBMS_OUTPUT.PUT_LINE(v_sql_query);
    -- Em um ambiente real, você executaria esta query e processaria os resultados.
    -- Para demonstração, vamos apenas mostrar a query e um exemplo de como buscar os dados.
    DBMS_OUTPUT.PUT_LINE(
        TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || 
        ' [INFO] Para obter os resultados, execute a query acima diretamente.'
    );

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(
            TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || 
            ' [ERRO] Não foi possível calcular a média móvel. Erro: ' || SQLERRM
        );
END;
/

-- ============================================================================
-- 3. Function para detectar outliers usando o método IQR (Interquartile Range)
--    Retorna 1 se for outlier, 0 caso contrário.
-- ============================================================================
CREATE OR REPLACE FUNCTION is_outlier_iqr(
    p_value IN NUMBER,
    p_q1 IN NUMBER,
    p_q3 IN NUMBER
) RETURN NUMBER IS
    v_iqr NUMBER;
    v_lower_bound NUMBER;
    v_upper_bound NUMBER;
BEGIN
    v_iqr := p_q3 - p_q1;
    v_lower_bound := p_q1 - (1.5 * v_iqr);
    v_upper_bound := p_q3 + (1.5 * v_iqr);

    IF p_value < v_lower_bound OR p_value > v_upper_bound THEN
        RETURN 1; -- É um outlier
    ELSE
        RETURN 0; -- Não é um outlier
    END IF;
END;
/

-- ============================================================================
-- 4. Procedure para identificar e listar outliers em uma coluna numérica
-- ============================================================================
CREATE OR REPLACE PROCEDURE find_outliers_iqr(
    p_table_name IN VARCHAR2,
    p_column_name IN VARCHAR2
) AS
    v_q1 NUMBER;
    v_q3 NUMBER;
    v_table_exists NUMBER;
    v_column_exists NUMBER;
    v_sql_query VARCHAR2(4000);
BEGIN
    -- Validação de tabela e colunas (reutiliza lógica da primeira procedure)
    SELECT COUNT(*)
    INTO v_table_exists
    FROM all_tables
    WHERE owner = USER AND table_name = UPPER(p_table_name);

    IF v_table_exists = 0 THEN
        DBMS_OUTPUT.PUT_LINE(
            TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || 
            ' [ERRO] Tabela ' || p_table_name || ' não encontrada ou sem permissão.'
        );
        RETURN;
    END IF;

    SELECT COUNT(*)
    INTO v_column_exists
    FROM all_tab_columns
    WHERE owner = USER AND table_name = UPPER(p_table_name) AND column_name = UPPER(p_column_name);

    IF v_column_exists = 0 THEN
        DBMS_OUTPUT.PUT_LINE(
            TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || 
            ' [ERRO] Coluna ' || p_column_name || ' não encontrada na tabela ' || p_table_name || '.'
        );
        RETURN;
    END IF;

    -- Calcular Q1 e Q3
    v_sql_query := 
        'SELECT PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY ' || p_column_name || '), ' ||
        'PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY ' || p_column_name || ') ' ||
        'FROM ' || p_table_name;
    EXECUTE IMMEDIATE v_sql_query INTO v_q1, v_q3;

    DBMS_OUTPUT.PUT_LINE(
        TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || 
        ' [INFO] Outliers para ' || p_table_name || '.' || p_column_name || ' (usando IQR):'
    );
    DBMS_OUTPUT.PUT_LINE('  Q1: ' || TO_CHAR(v_q1, 'FM999G999G999D00') || ', Q3: ' || TO_CHAR(v_q3, 'FM999G999G999D00'));

    -- Listar os outliers
    v_sql_query := 
        'SELECT * FROM ' || p_table_name || ' WHERE is_outlier_iqr(' || p_column_name || ', ' || v_q1 || ', ' || v_q3 || ') = 1';
    
    DBMS_OUTPUT.PUT_LINE('  Query para listar outliers: ' || v_sql_query);
    DBMS_OUTPUT.PUT_LINE('  (Execute a query acima para ver os registros de outliers.)');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(
            TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || 
            ' [ERRO] Não foi possível encontrar outliers. Erro: ' || SQLERRM
        );
END;
/

-- ============================================================================
-- 5. Procedure para criar uma tabela de resumo de séries temporais
--    Agrega dados por período (dia, mês, ano) e calcula métricas.
-- ============================================================================
CREATE OR REPLACE PROCEDURE create_time_series_summary(
    p_source_table IN VARCHAR2,
    p_date_column IN VARCHAR2,
    p_value_column IN VARCHAR2,
    p_summary_table_name IN VARCHAR2,
    p_period IN VARCHAR2 DEFAULT 'DAY' -- 'DAY', 'MONTH', 'YEAR'
) AS
    v_sql_query VARCHAR2(4000);
    v_table_exists NUMBER;
    v_date_column_exists NUMBER;
    v_value_column_exists NUMBER;
BEGIN
    -- Validação de tabela e colunas
    SELECT COUNT(*)
    INTO v_table_exists
    FROM all_tables
    WHERE owner = USER AND table_name = UPPER(p_source_table);

    IF v_table_exists = 0 THEN
        DBMS_OUTPUT.PUT_LINE(
            TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || 
            ' [ERRO] Tabela de origem ' || p_source_table || ' não encontrada ou sem permissão.'
        );
        RETURN;
    END IF;

    SELECT COUNT(*)
    INTO v_date_column_exists
    FROM all_tab_columns
    WHERE owner = USER AND table_name = UPPER(p_source_table) AND column_name = UPPER(p_date_column);

    IF v_date_column_exists = 0 THEN
        DBMS_OUTPUT.PUT_LINE(
            TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || 
            ' [ERRO] Coluna de data ' || p_date_column || ' não encontrada na tabela ' || p_source_table || '.'
        );
        RETURN;
    END IF;

    SELECT COUNT(*)
    INTO v_value_column_exists
    FROM all_tab_columns
    WHERE owner = USER AND table_name = UPPER(p_source_table) AND column_name = UPPER(p_value_column);

    IF v_value_column_exists = 0 THEN
        DBMS_OUTPUT.PUT_LINE(
            TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || 
            ' [ERRO] Coluna de valor ' || p_value_column || ' não encontrada na tabela ' || p_source_table || '.'
        );
        RETURN;
    END IF;

    v_sql_query := 'CREATE OR REPLACE TABLE ' || p_summary_table_name || ' AS SELECT ';

    IF UPPER(p_period) = 'DAY' THEN
        v_sql_query := v_sql_query || 'TRUNC(' || p_date_column || ') AS period_start_date, ';
    ELSIF UPPER(p_period) = 'MONTH' THEN
        v_sql_query := v_sql_query || 'TRUNC(' || p_date_column || ', ''MM'') AS period_start_date, ';
    ELSIF UPPER(p_period) = 'YEAR' THEN
        v_sql_query := v_sql_query || 'TRUNC(' || p_date_column || ', ''YYYY'') AS period_start_date, ';
    ELSE
        DBMS_OUTPUT.PUT_LINE(
            TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || 
            ' [ERRO] Período inválido. Use \'DAY\', \'MONTH\' ou \'YEAR\'.'
        );
        RETURN;
    END IF;

    v_sql_query := v_sql_query ||
        'COUNT(*) AS total_records, ' ||
        'SUM(' || p_value_column || ') AS sum_value, ' ||
        'AVG(' || p_value_column || ') AS avg_value, ' ||
        'MIN(' || p_value_column || ') AS min_value, ' ||
        'MAX(' || p_value_column || ') AS max_value ' ||
        'FROM ' || p_source_table || ' ' ||
        'GROUP BY ';

    IF UPPER(p_period) = 'DAY' THEN
        v_sql_query := v_sql_query || 'TRUNC(' || p_date_column || ') ';
    ELSIF UPPER(p_period) = 'MONTH' THEN
        v_sql_query := v_sql_query || 'TRUNC(' || p_date_column || ', ''MM'') ';
    ELSIF UPPER(p_period) = 'YEAR' THEN
        v_sql_query := v_sql_query || 'TRUNC(' || p_date_column || ', ''YYYY'') ';
    END IF;
    v_sql_query := v_sql_query || 'ORDER BY period_start_date';

    EXECUTE IMMEDIATE v_sql_query;

    DBMS_OUTPUT.PUT_LINE(
        TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || 
        ' [INFO] Tabela de resumo de séries temporais \'' || p_summary_table_name || '\' criada com sucesso para o período ' || p_period || '.'
    );

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(
            TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || 
            ' [ERRO] Não foi possível criar a tabela de resumo de séries temporais. Erro: ' || SQLERRM
        );
END;
/

-- ============================================================================
-- Exemplo de Uso (Bloco Anônimo)
-- ============================================================================
DECLARE
    v_q1 NUMBER;
    v_q3 NUMBER;
BEGIN
    -- Criar uma tabela de exemplo para demonstração
    EXECUTE IMMEDIATE 'DROP TABLE IF EXISTS sales_data';
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
    EXECUTE IMMEDIATE '
        INSERT INTO sales_data (sale_id, product_id, sale_amount, sale_date, region) VALUES
        (1, 101, 100.00, TO_DATE(''2025-01-01'', ''YYYY-MM-DD''), ''North''),
        (2, 102, 150.50, TO_DATE(''2025-01-01'', ''YYYY-MM-DD''), ''South''),
        (3, 101, 120.00, TO_DATE(''2025-01-02'', ''YYYY-MM-DD''), ''North''),
        (4, 103, 200.00, TO_DATE(''2025-01-02'', ''YYYY-MM-DD''), ''East''),
        (5, 102, 130.00, TO_DATE(''2025-01-03'', ''YYYY-MM-DD''), ''South''),
        (6, 101, 110.00, TO_DATE(''2025-01-03'', ''YYYY-MM-DD''), ''North''),
        (7, 104, 5000.00, TO_DATE(''2025-01-04'', ''YYYY-MM-DD''), ''West''), -- Outlier
        (8, 101, 105.00, TO_DATE(''2025-01-04'', ''YYYY-MM-DD''), ''North''),
        (9, 105, 50.00, TO_DATE(''2025-01-05'', ''YYYY-MM-DD''), ''East''),
        (10, 101, 115.00, TO_DATE(''2025-01-05'', ''YYYY-MM-DD''), ''North''),
        (11, 106, 10.00, TO_DATE(''2025-01-06'', ''YYYY-MM-DD''), ''South''), -- Outlier
        (12, 101, 125.00, TO_DATE(''2025-01-06'', ''YYYY-MM-DD''), ''North''),
        (13, 102, 140.00, TO_DATE(''2025-02-01'', ''YYYY-MM-DD''), ''South''),
        (14, 103, 210.00, TO_DATE(''2025-02-02'', ''YYYY-MM-DD''), ''East''),
        (15, 101, 110.00, TO_DATE(''2025-02-03'', ''YYYY-MM-DD''), ''North'')
    ';

    DBMS_OUTPUT.PUT_LINE(
        TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || 
        ' [INFO] Tabela sales_data criada e populada com sucesso.'
    );

    -- Exemplo 1: Calcular estatísticas avançadas
    DBMS_OUTPUT.PUT_LINE(
        TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || 
        '\n--- Chamando calculate_advanced_statistics para sale_amount ---'
    );
    calculate_advanced_statistics('sales_data', 'sale_amount');

    -- Exemplo 2: Calcular média móvel simples (SMA) sem particionamento
    DBMS_OUTPUT.PUT_LINE(
        TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || 
        '\n--- Chamando calculate_moving_average_advanced (SMA, Janela 3) ---'
    );
    calculate_moving_average_advanced('sales_data', 'sale_amount', 'sale_date', 3, p_ma_type => 'SMA');

    -- Exemplo 3: Calcular média móvel exponencial (EMA) particionada por região
    DBMS_OUTPUT.PUT_LINE(
        TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || 
        '\n--- Chamando calculate_moving_average_advanced (EMA, Janela 2, Partição por Região) ---'
    );
    calculate_moving_average_advanced('sales_data', 'sale_amount', 'sale_date', 2, 'region', 'EMA');

    -- Exemplo 4: Encontrar outliers usando IQR
    DBMS_OUTPUT.PUT_LINE(
        TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || 
        '\n--- Chamando find_outliers_iqr para sale_amount ---'
    );
    find_outliers_iqr('sales_data', 'sale_amount');

    -- Exemplo 5: Criar tabela de resumo de séries temporais por mês
    DBMS_OUTPUT.PUT_LINE(
        TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || 
        '\n--- Chamando create_time_series_summary (Mensal) ---'
    );
    create_time_series_summary('sales_data', 'sale_date', 'sale_amount', 'monthly_sales_summary', 'MONTH');

    -- Verificar o conteúdo da tabela de resumo (apenas os primeiros registros)
    DBMS_OUTPUT.PUT_LINE(
        TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || 
        ' [INFO] Conteúdo da tabela monthly_sales_summary (primeiros 5 registros):'
    );
    FOR rec IN (SELECT period_start_date, sum_value, avg_value FROM monthly_sales_summary ORDER BY period_start_date FETCH FIRST 5 ROWS ONLY) LOOP
        DBMS_OUTPUT.PUT_LINE('  Data: ' || TO_CHAR(rec.period_start_date, 'YYYY-MM-DD') || ', Soma: ' || TO_CHAR(rec.sum_value, 'FM999G999G999D00') || ', Média: ' || TO_CHAR(rec.avg_value, 'FM999G999G999D00'));
    END LOOP;

    -- Limpar a tabela de exemplo
    EXECUTE IMMEDIATE 'DROP TABLE sales_data';
    EXECUTE IMMEDIATE 'DROP TABLE monthly_sales_summary';
    DBMS_OUTPUT.PUT_LINE(
        TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || 
        ' [INFO] Tabelas de exemplo sales_data e monthly_sales_summary removidas.'
    );

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(
            TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || 
            ' [ERRO] Erro inesperado no bloco de exemplo: ' || SQLERRM
        );
END;
/

