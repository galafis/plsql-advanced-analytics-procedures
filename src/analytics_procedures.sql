-- PL/SQL Advanced Analytics Procedures
-- Author: Gabriel Demetrios Lafis
-- Year: 2025

-- Procedure para calcular estatísticas descritivas
CREATE OR REPLACE PROCEDURE calculate_statistics(
    p_table_name IN VARCHAR2,
    p_column_name IN VARCHAR2
) AS
    v_mean NUMBER;
    v_median NUMBER;
    v_stddev NUMBER;
    v_min NUMBER;
    v_max NUMBER;
BEGIN
    EXECUTE IMMEDIATE 
        'SELECT AVG(' || p_column_name || '), 
                MEDIAN(' || p_column_name || '),
                STDDEV(' || p_column_name || '),
                MIN(' || p_column_name || '),
                MAX(' || p_column_name || ')
         FROM ' || p_table_name
    INTO v_mean, v_median, v_stddev, v_min, v_max;
    
    DBMS_OUTPUT.PUT_LINE('Statistics for ' || p_table_name || '.' || p_column_name);
    DBMS_OUTPUT.PUT_LINE('Mean: ' || v_mean);
    DBMS_OUTPUT.PUT_LINE('Median: ' || v_median);
    DBMS_OUTPUT.PUT_LINE('Std Dev: ' || v_stddev);
    DBMS_OUTPUT.PUT_LINE('Min: ' || v_min);
    DBMS_OUTPUT.PUT_LINE('Max: ' || v_max);
END;
/
