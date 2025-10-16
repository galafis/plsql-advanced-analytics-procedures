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
        -- Lógica para calcular VaR e ES
        v_sql_query := 
            q'[WITH returns AS (
                SELECT 
                    (t.']' || p_value_column || q'[' - LAG(t.']' || p_value_column || q'[, 1, t.']' || p_value_column || q'[) OVER (ORDER BY t.']' || p_date_column || q'[')) / LAG(t.']' || p_value_column || q'[, 1, t.']' || p_value_column || q'[) OVER (ORDER BY t.']' || p_date_column || q'[) AS daily_return
                FROM ]' || p_portfolio_table || q'[ t
            )
            SELECT 
                PERCENTILE_CONT(0.05) WITHIN GROUP (ORDER BY daily_return) AS var_95,
                AVG(CASE WHEN daily_return < PERCENTILE_CONT(0.05) WITHIN GROUP (ORDER BY daily_return) THEN daily_return ELSE NULL END) AS es_95
            FROM returns]';

        EXECUTE IMMEDIATE v_sql_query INTO v_var_95, v_es_95;

        DBMS_OUTPUT.PUT_LINE('[INFO] Análise de Risco do Portfólio:');
        DBMS_OUTPUT.PUT_LINE('  Value at Risk (VaR 95%): ' || TO_CHAR(v_var_95 * 100, 'FM999D00') || '%');
        DBMS_OUTPUT.PUT_LINE('  Expected Shortfall (ES 95%): ' || TO_CHAR(v_es_95 * 100, 'FM999D00') || '%');

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
        -- Lógica para detecção de fraude
        v_sql_query := 
            q'[WITH stats AS (
                SELECT 
                    ']' || p_customer_id_column || q'[,
                    AVG(']' || p_amount_column || q'[) as avg_amount,
                    STDDEV(']' || p_amount_column || q'[) as stddev_amount
                FROM ]' || p_transactions_table || q'[
                GROUP BY ]' || p_customer_id_column || q'[
            )
            SELECT 
                t.']' || p_customer_id_column || q'[,
                t.']' || p_amount_column || q'[,
                (t.']' || p_amount_column || q'[ - s.avg_amount) / s.stddev_amount AS z_score
            FROM ]' || p_transactions_table || q'[ t
            JOIN stats s ON t.']' || p_customer_id_column || q'[ = s.']' || p_customer_id_column || q'[']';

        EXECUTE IMMEDIATE v_sql_query BULK COLLECT INTO l_results;

        DBMS_OUTPUT.PUT_LINE('[INFO] Detecção de Fraude em Transações (Z-score > 3):');
        FOR i IN 1..l_results.COUNT LOOP
            IF l_results(i).z_score > 3 THEN
                DBMS_OUTPUT.PUT_LINE('  Cliente: ' || l_results(i).customer_id || ', Valor: ' || l_results(i).amount || ', Z-score: ' || l_results(i).z_score);
            END IF;
        END LOOP;

    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('[ERRO] Falha na detecção de fraude: ' || SQLERRM);
    END transaction_fraud_detection;

END FINANCIAL_ANALYSIS_PKG;
/

