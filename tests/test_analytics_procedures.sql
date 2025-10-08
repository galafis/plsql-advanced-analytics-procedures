
-- Testes para os procedimentos de análise avançada em PL/SQL
-- Este arquivo contém exemplos de como os procedimentos PL/SQL seriam testados
-- em um ambiente Oracle Database ou similar.

-- Pré-requisitos:
-- 1. Um ambiente Oracle Database (ou compatível) com os procedimentos implantados.
-- 2. Acesso a um cliente SQL (SQL*Plus, SQL Developer, DBeaver, etc.).

-- Exemplo de Teste 1: Testar o procedimento CALCULATE_CUSTOMER_LTV
-- Objetivo: Verificar se o LTV do cliente é calculado corretamente.

SET SERVEROUTPUT ON;

DECLARE
    v_customer_id NUMBER := 101;
    v_ltv         NUMBER;
BEGIN
    -- Chamar o procedimento
    ANALYTICS_PKG.CALCULATE_CUSTOMER_LTV(
        p_customer_id => v_customer_id,
        p_ltv         => v_ltv
    );

    -- Verificar o resultado
    DBMS_OUTPUT.PUT_LINE(
        'LTV para o cliente ' || v_customer_id || ': ' || v_ltv
    );

    -- Adicionar asserções (em um ambiente de teste real, isso seria automatizado)
    IF v_ltv > 0 THEN
        DBMS_OUTPUT.PUT_LINE('Teste CALCULATE_CUSTOMER_LTV: SUCESSO');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Teste CALCULATE_CUSTOMER_LTV: FALHA - LTV não calculado corretamente');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro durante o teste CALCULATE_CUSTOMER_LTV: ' || SQLERRM);
END;
/

-- Exemplo de Teste 2: Testar o procedimento GENERATE_SALES_FORECAST
-- Objetivo: Verificar se o procedimento gera uma previsão de vendas para um período.

DECLARE
    v_start_date DATE := TO_DATE('2025-01-01', 'YYYY-MM-DD');
    v_end_date   DATE := TO_DATE('2025-01-31', 'YYYY-MM-DD');
    v_forecast_count NUMBER;
BEGIN
    -- Chamar o procedimento
    ANALYTICS_PKG.GENERATE_SALES_FORECAST(
        p_start_date => v_start_date,
        p_end_date   => v_end_date
    );

    -- Verificar se os dados foram inseridos na tabela de previsão
    SELECT COUNT(*) INTO v_forecast_count FROM SALES_FORECAST WHERE FORECAST_DATE BETWEEN v_start_date AND v_end_date;

    DBMS_OUTPUT.PUT_LINE(
        'Previsões geradas para o período ' || v_start_date || ' a ' || v_end_date || ': ' || v_forecast_count
    );

    IF v_forecast_count > 0 THEN
        DBMS_OUTPUT.PUT_LINE('Teste GENERATE_SALES_FORECAST: SUCESSO');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Teste GENERATE_SALES_FORECAST: FALHA - Nenhuma previsão gerada');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro durante o teste GENERATE_SALES_FORECAST: ' || SQLERRM);
END;
/

-- Para executar estes testes:
-- 1. Conecte-se ao seu banco de dados Oracle usando um cliente SQL.
-- 2. Execute este script SQL.
-- 3. Analise a saída do DBMS_OUTPUT para verificar os resultados dos testes.

