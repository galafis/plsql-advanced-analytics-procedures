-- PL/SQL Advanced Financial Analysis Module
-- Author: Gabriel Demetrios Lafis
-- Year: 2025

-- Habilitar saída de DBMS_OUTPUT para ver os resultados
SET SERVEROUTPUT ON;

-- ============================================================================
-- Pacote de Análise Financeira Avançada
-- ============================================================================
CREATE OR REPLACE PACKAGE FINANCIAL_ANALYSIS_PKG AS

    -- Procedure para Análise de Risco de Portfólio
    PROCEDURE portfolio_risk_analysis(
        p_portfolio_table IN VARCHAR2,
        p_value_column IN VARCHAR2,
        p_date_column IN VARCHAR2
    );

    -- Procedure para Detecção de Fraude em Transações
    PROCEDURE transaction_fraud_detection(
        p_transactions_table IN VARCHAR2,
        p_amount_column IN VARCHAR2,
        p_customer_id_column IN VARCHAR2
    );

END FINANCIAL_ANALYSIS_PKG;
/

CREATE OR REPLACE PACKAGE BODY FINANCIAL_ANALYSIS_PKG AS

    -- ============================================================================
    -- 1. Procedure para Análise de Risco de Portfólio
    --    Calcula o Value at Risk (VaR) e o Expected Shortfall (ES).
    -- ============================================================================
    PROCEDURE portfolio_risk_analysis(
        p_portfolio_table IN VARCHAR2,
        p_value_column IN VARCHAR2,
        p_date_column IN VARCHAR2
    ) AS
        v_var_95 NUMBER;
        v_es_95 NUMBER;
        v_sql_query VARCHAR2(2000);
    BEGIN
        -- Calcular retornos diários, VaR e Expected Shortfall
        v_sql_query :=
            'WITH returns AS (' ||
            ' SELECT (t.' || p_value_column || ' - LAG(t.' || p_value_column || ') OVER (ORDER BY t.' || p_date_column || '))' ||
            ' / NULLIF(LAG(t.' || p_value_column || ') OVER (ORDER BY t.' || p_date_column || '), 0) AS daily_return' ||
            ' FROM ' || p_portfolio_table || ' t' ||
            '), var_calc AS (' ||
            ' SELECT PERCENTILE_CONT(0.05) WITHIN GROUP (ORDER BY daily_return) AS var_value' ||
            ' FROM returns WHERE daily_return IS NOT NULL' ||
            ')' ||
            ' SELECT v.var_value,' ||
            ' (SELECT AVG(r.daily_return) FROM returns r' ||
            '  WHERE r.daily_return IS NOT NULL AND r.daily_return <= v.var_value)' ||
            ' FROM var_calc v';

        EXECUTE IMMEDIATE v_sql_query INTO v_var_95, v_es_95;

        DBMS_OUTPUT.PUT_LINE('[INFO] Análise de Risco do Portfólio:');
        DBMS_OUTPUT.PUT_LINE('  Value at Risk (VaR 95%): ' || TO_CHAR(v_var_95 * 100, 'FM990D00') || '%');
        DBMS_OUTPUT.PUT_LINE('  Expected Shortfall (ES 95%): ' || TO_CHAR(NVL(v_es_95, v_var_95) * 100, 'FM990D00') || '%');

    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('[ERRO] Falha na análise de risco do portfólio: ' || SQLERRM);
    END portfolio_risk_analysis;

    -- ============================================================================
    -- 2. Procedure para Detecção de Fraude em Transações
    --    Utiliza z-score para identificar transações anômalas.
    -- ============================================================================
    PROCEDURE transaction_fraud_detection(
        p_transactions_table IN VARCHAR2,
        p_amount_column IN VARCHAR2,
        p_customer_id_column IN VARCHAR2
    ) AS
        v_sql_query VARCHAR2(2000);
        TYPE result_rec IS RECORD (customer_id VARCHAR2(100), amount NUMBER, z_score NUMBER);
        TYPE result_table IS TABLE OF result_rec;
        l_results result_table;
    BEGIN
        -- Calcular z-score por cliente para identificar transações anômalas
        v_sql_query :=
            'WITH stats AS (' ||
            ' SELECT ' || p_customer_id_column || ',' ||
            ' AVG(' || p_amount_column || ') AS avg_amount,' ||
            ' STDDEV(' || p_amount_column || ') AS stddev_amount' ||
            ' FROM ' || p_transactions_table ||
            ' GROUP BY ' || p_customer_id_column ||
            ')' ||
            ' SELECT t.' || p_customer_id_column || ',' ||
            ' t.' || p_amount_column || ',' ||
            ' CASE WHEN s.stddev_amount = 0 OR s.stddev_amount IS NULL THEN 0' ||
            ' ELSE (t.' || p_amount_column || ' - s.avg_amount) / s.stddev_amount END' ||
            ' FROM ' || p_transactions_table || ' t' ||
            ' JOIN stats s ON t.' || p_customer_id_column || ' = s.' || p_customer_id_column;

        EXECUTE IMMEDIATE v_sql_query BULK COLLECT INTO l_results;

        DBMS_OUTPUT.PUT_LINE('[INFO] Detecção de Fraude em Transações (Z-score > 3):');
        FOR i IN 1..l_results.COUNT LOOP
            IF ABS(l_results(i).z_score) > 3 THEN
                DBMS_OUTPUT.PUT_LINE('  Cliente: ' || l_results(i).customer_id || ', Valor: ' || l_results(i).amount || ', Z-score: ' || ROUND(l_results(i).z_score, 2));
            END IF;
        END LOOP;

    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('[ERRO] Falha na detecção de fraude: ' || SQLERRM);
    END transaction_fraud_detection;

END FINANCIAL_ANALYSIS_PKG;
/

