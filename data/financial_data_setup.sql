-- Script para configuração de dados de exemplo para o módulo de análise financeira avançada
-- Author: Gabriel Demetrios Lafis
-- Year: 2025

SET SERVEROUTPUT ON;

-- 1. Tabela para Análise de Risco de Portfólio
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE portfolio_returns CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

CREATE TABLE portfolio_returns (
    return_id NUMBER PRIMARY KEY,
    asset_name VARCHAR2(100),
    return_value NUMBER(10, 4),
    return_date DATE
);

INSERT INTO portfolio_returns (return_id, asset_name, return_value, return_date) VALUES (1, 'StockA', 0.01, TO_DATE('2024-01-01', 'YYYY-MM-DD'));
INSERT INTO portfolio_returns (return_id, asset_name, return_value, return_date) VALUES (2, 'StockA', 0.015, TO_DATE('2024-01-02', 'YYYY-MM-DD'));
INSERT INTO portfolio_returns (return_id, asset_name, return_value, return_date) VALUES (3, 'StockA', -0.005, TO_DATE('2024-01-03', 'YYYY-MM-DD'));
INSERT INTO portfolio_returns (return_id, asset_name, return_value, return_date) VALUES (4, 'StockA', 0.02, TO_DATE('2024-01-04', 'YYYY-MM-DD'));
INSERT INTO portfolio_returns (return_id, asset_name, return_value, return_date) VALUES (5, 'StockA', -0.03, TO_DATE('2024-01-05', 'YYYY-MM-DD')); -- Potencial perda
INSERT INTO portfolio_returns (return_id, asset_name, return_value, return_date) VALUES (6, 'StockA', 0.008, TO_DATE('2024-01-06', 'YYYY-MM-DD'));
INSERT INTO portfolio_returns (return_id, asset_name, return_value, return_date) VALUES (7, 'StockA', -0.04, TO_DATE('2024-01-07', 'YYYY-MM-DD')); -- Potencial perda maior
INSERT INTO portfolio_returns (return_id, asset_name, return_value, return_date) VALUES (8, 'StockA', 0.012, TO_DATE('2024-01-08', 'YYYY-MM-DD'));
INSERT INTO portfolio_returns (return_id, asset_name, return_value, return_date) VALUES (9, 'StockA', 0.003, TO_DATE('2024-01-09', 'YYYY-MM-DD'));
INSERT INTO portfolio_returns (return_id, asset_name, return_value, return_date) VALUES (10, 'StockA', -0.01, TO_DATE('2024-01-10', 'YYYY-MM-DD'));

INSERT INTO portfolio_returns (return_id, asset_name, return_value, return_date) VALUES (11, 'StockB', 0.005, TO_DATE('2024-01-01', 'YYYY-MM-DD'));
INSERT INTO portfolio_returns (return_id, asset_name, return_value, return_date) VALUES (12, 'StockB', 0.007, TO_DATE('2024-01-02', 'YYYY-MM-DD'));
INSERT INTO portfolio_returns (return_id, asset_name, return_value, return_date) VALUES (13, 'StockB', -0.002, TO_DATE('2024-01-03', 'YYYY-MM-DD'));
INSERT INTO portfolio_returns (return_id, asset_name, return_value, return_date) VALUES (14, 'StockB', 0.01, TO_DATE('2024-01-04', 'YYYY-MM-DD'));
INSERT INTO portfolio_returns (return_id, asset_name, return_value, return_date) VALUES (15, 'StockB', -0.015, TO_DATE('2024-01-05', 'YYYY-MM-DD'));
COMMIT;

-- 2. Tabela para Detecção de Fraude em Transações
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE transactions CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

CREATE TABLE transactions (
    transaction_id NUMBER PRIMARY KEY,
    customer_id VARCHAR2(50),
    amount NUMBER(12, 2),
    transaction_date DATE
);

INSERT INTO transactions (transaction_id, customer_id, amount, transaction_date) VALUES (1, 'CUST001', 100.00, TO_DATE('2024-01-01', 'YYYY-MM-DD'));
INSERT INTO transactions (transaction_id, customer_id, amount, transaction_date) VALUES (2, 'CUST001', 120.50, TO_DATE('2024-01-02', 'YYYY-MM-DD'));
INSERT INTO transactions (transaction_id, customer_id, amount, transaction_date) VALUES (3, 'CUST001', 90.75, TO_DATE('2024-01-03', 'YYYY-MM-DD'));
INSERT INTO transactions (transaction_id, customer_id, amount, transaction_date) VALUES (4, 'CUST002', 50.00, TO_DATE('2024-01-01', 'YYYY-MM-DD'));
INSERT INTO transactions (transaction_id, customer_id, amount, transaction_date) VALUES (5, 'CUST002', 60.25, TO_DATE('2024-01-02', 'YYYY-MM-DD'));
INSERT INTO transactions (transaction_id, customer_id, amount, transaction_date) VALUES (6, 'CUST001', 1500.00, TO_DATE('2024-01-04', 'YYYY-MM-DD')); -- Transação suspeita
INSERT INTO transactions (transaction_id, customer_id, amount, transaction_date) VALUES (7, 'CUST003', 200.00, TO_DATE('2024-01-01', 'YYYY-MM-DD'));
INSERT INTO transactions (transaction_id, customer_id, amount, transaction_date) VALUES (8, 'CUST003', 210.00, TO_DATE('2024-01-02', 'YYYY-MM-DD'));
INSERT INTO transactions (transaction_id, customer_id, amount, transaction_date) VALUES (9, 'CUST001', 110.00, TO_DATE('2024-01-05', 'YYYY-MM-DD'));
INSERT INTO transactions (transaction_id, customer_id, amount, transaction_date) VALUES (10, 'CUST002', 75.00, TO_DATE('2024-01-03', 'YYYY-MM-DD'));
INSERT INTO transactions (transaction_id, customer_id, amount, transaction_date) VALUES (11, 'CUST004', 5000.00, TO_DATE('2024-01-01', 'YYYY-MM-DD')); -- Transação muito suspeita
COMMIT;

