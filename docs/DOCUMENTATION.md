# Documentação Completa - PL/SQL Advanced Analytics Procedures

## Índice

1. [Visão Geral](#visão-geral)
2. [Arquitetura](#arquitetura)
3. [Instalação e Configuração](#instalação-e-configuração)
4. [Módulos](#módulos)
5. [Exemplos de Uso](#exemplos-de-uso)
6. [Testes](#testes)
7. [Melhores Práticas](#melhores-práticas)
8. [Resolução de Problemas](#resolução-de-problemas)

## Visão Geral

Este repositório contém uma coleção abrangente de procedimentos PL/SQL avançados para análise de dados no Oracle Database. O projeto é organizado em pacotes modulares que fornecem funcionalidades analíticas profissionais e de alto desempenho.

### Principais Funcionalidades

- **Estatísticas Descritivas Avançadas**: Cálculo de média, mediana, desvio padrão, percentis (Q1, Q3, P95) e outras métricas estatísticas
- **Detecção de Outliers**: Identificação de valores atípicos usando o método IQR (Interquartile Range)
- **Análise de Séries Temporais**: Médias móveis (SMA/EMA), agregações temporais por dia/mês/ano
- **Análise Financeira**: Value at Risk (VaR), Expected Shortfall (ES), detecção de fraude com z-score
- **Validação Robusta**: Verificação automática de tabelas, colunas e tipos de dados
- **Tratamento de Erros**: Logging detalhado e mensagens de erro informativas

## Arquitetura

### Estrutura de Pacotes

```
┌─────────────────────────────────────────┐
│     ANALYTICS_PKG (Core Analytics)      │
├─────────────────────────────────────────┤
│ - calculate_advanced_statistics         │
│ - calculate_moving_average_advanced     │
│ - is_outlier_iqr (function)             │
│ - find_outliers_iqr                     │
│ - create_time_series_summary            │
└─────────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────┐
│  FINANCIAL_ANALYSIS_PKG (Financial)     │
├─────────────────────────────────────────┤
│ - portfolio_risk_analysis               │
│ - transaction_fraud_detection           │
└─────────────────────────────────────────┘
```

### Fluxo de Dados

```
Dados Brutos → Validação → Processamento → Análise → Resultados
     │            │             │             │          │
     │         Tabelas       Packages      Funções    DBMS_OUTPUT
     │         Colunas       Procedures    Analíticas  Tabelas
     └─────────┴─────────────┴─────────────┴──────────┘
                     Error Handling & Logging
```

## Instalação e Configuração

### Pré-requisitos

- Oracle Database 12c ou superior
- Privilégios para criar PACKAGE, PROCEDURE, FUNCTION, TABLE
- Cliente SQL (SQL*Plus, SQL Developer, SQLcl)

### Instalação Automática

```bash
# Clone o repositório
git clone https://github.com/galafis/plsql-advanced-analytics-procedures.git
cd plsql-advanced-analytics-procedures

# Execute o script de deploy
./scripts/deploy.sh <usuario> <senha> <connection_string>

# Exemplo:
./scripts/deploy.sh analytics analytics123 localhost:1521/XEPDB1
```

### Instalação Manual

```sql
-- 1. Conecte ao banco de dados
sqlplus usuario/senha@connection_string

-- 2. Deploy do pacote Core Analytics
@src/core_analytics/analytics_package.sql

-- 3. Deploy do pacote Financial Analysis
@src/financial_analytics/advanced_financial_analysis.sql

-- 4. (Opcional) Criar dados de exemplo
@data/financial_data_setup.sql
```

## Módulos

### ANALYTICS_PKG - Análise Core

#### calculate_advanced_statistics

Calcula estatísticas descritivas completas para uma coluna numérica.

**Parâmetros:**
- `p_table_name` (VARCHAR2): Nome da tabela
- `p_column_name` (VARCHAR2): Nome da coluna numérica

**Retorna via DBMS_OUTPUT:**
- Média, Mediana, Desvio Padrão
- Mínimo, Máximo, Soma, Contagem
- Percentil 25 (Q1), Percentil 75 (Q3)

**Exemplo:**
```sql
BEGIN
    ANALYTICS_PKG.calculate_advanced_statistics('SALES_DATA', 'AMOUNT');
END;
/
```

#### calculate_moving_average_advanced

Gera query para calcular médias móveis (SMA ou EMA) com suporte a particionamento.

**Parâmetros:**
- `p_table_name` (VARCHAR2): Nome da tabela
- `p_value_column` (VARCHAR2): Coluna de valores
- `p_order_column` (VARCHAR2): Coluna de ordenação (geralmente data)
- `p_window_size` (NUMBER): Tamanho da janela
- `p_partition_column` (VARCHAR2, opcional): Coluna de particionamento
- `p_ma_type` (VARCHAR2, default 'SMA'): Tipo ('SMA' ou 'EMA')

**Exemplo:**
```sql
BEGIN
    -- Média móvel simples de 7 dias
    ANALYTICS_PKG.calculate_moving_average_advanced(
        'STOCK_PRICES', 'PRICE', 'TRADE_DATE', 7, p_ma_type => 'SMA'
    );
    
    -- Média móvel por categoria
    ANALYTICS_PKG.calculate_moving_average_advanced(
        'SALES_DATA', 'AMOUNT', 'SALE_DATE', 3, 'CATEGORY', 'SMA'
    );
END;
/
```

#### find_outliers_iqr

Identifica outliers usando o método IQR (Interquartile Range).

**Parâmetros:**
- `p_table_name` (VARCHAR2): Nome da tabela
- `p_column_name` (VARCHAR2): Nome da coluna numérica

**Lógica:**
- Calcula Q1 (percentil 25) e Q3 (percentil 75)
- IQR = Q3 - Q1
- Outlier inferior: valor < Q1 - 1.5 * IQR
- Outlier superior: valor > Q3 + 1.5 * IQR

**Exemplo:**
```sql
BEGIN
    ANALYTICS_PKG.find_outliers_iqr('TRANSACTIONS', 'AMOUNT');
END;
/
```

#### create_time_series_summary

Cria tabela de resumo agregado por período temporal.

**Parâmetros:**
- `p_source_table` (VARCHAR2): Tabela de origem
- `p_date_column` (VARCHAR2): Coluna de data
- `p_value_column` (VARCHAR2): Coluna de valores
- `p_summary_table_name` (VARCHAR2): Nome da tabela de resumo
- `p_period` (VARCHAR2, default 'DAY'): Período ('DAY', 'MONTH', 'YEAR')

**Exemplo:**
```sql
BEGIN
    -- Resumo mensal de vendas
    ANALYTICS_PKG.create_time_series_summary(
        'SALES_DATA', 'SALE_DATE', 'AMOUNT', 
        'MONTHLY_SALES', 'MONTH'
    );
END;
/

-- Consultar resultados
SELECT * FROM MONTHLY_SALES ORDER BY period_start_date;
```

### FINANCIAL_ANALYSIS_PKG - Análise Financeira

#### portfolio_risk_analysis

Calcula Value at Risk (VaR) e Expected Shortfall (ES) para análise de risco de portfólio.

**Parâmetros:**
- `p_portfolio_table` (VARCHAR2): Tabela de retornos do portfólio
- `p_value_column` (VARCHAR2): Coluna de valores/retornos
- `p_date_column` (VARCHAR2): Coluna de data

**Métricas Calculadas:**
- VaR 95%: Perda máxima esperada em 95% dos casos
- ES 95%: Perda média nos 5% piores cenários

**Exemplo:**
```sql
BEGIN
    FINANCIAL_ANALYSIS_PKG.portfolio_risk_analysis(
        'PORTFOLIO_RETURNS', 'RETURN_VALUE', 'RETURN_DATE'
    );
END;
/
```

#### transaction_fraud_detection

Detecta transações potencialmente fraudulentas usando z-score.

**Parâmetros:**
- `p_transactions_table` (VARCHAR2): Tabela de transações
- `p_amount_column` (VARCHAR2): Coluna de valores
- `p_customer_id_column` (VARCHAR2): Coluna de identificação do cliente

**Lógica:**
- Calcula média e desvio padrão por cliente
- Z-score = (valor - média) / desvio_padrão
- Transações com z-score > 3 são consideradas suspeitas

**Exemplo:**
```sql
BEGIN
    FINANCIAL_ANALYSIS_PKG.transaction_fraud_detection(
        'TRANSACTIONS', 'AMOUNT', 'CUSTOMER_ID'
    );
END;
/
```

## Exemplos de Uso

### Caso de Uso 1: Análise de Vendas Completa

```sql
SET SERVEROUTPUT ON;

-- Criar e popular tabela de vendas
CREATE TABLE sales_analysis (
    sale_id NUMBER PRIMARY KEY,
    product_id NUMBER,
    amount NUMBER(10,2),
    sale_date DATE,
    region VARCHAR2(50)
);

-- Inserir dados de exemplo (incluindo alguns outliers)
INSERT ALL
    INTO sales_analysis VALUES (1, 101, 1200, DATE '2024-01-01', 'North')
    INTO sales_analysis VALUES (2, 102, 1500, DATE '2024-01-02', 'South')
    INTO sales_analysis VALUES (3, 103, 1300, DATE '2024-01-03', 'East')
    INTO sales_analysis VALUES (4, 104, 15000, DATE '2024-01-04', 'West') -- Outlier
    INTO sales_analysis VALUES (5, 105, 1100, DATE '2024-01-05', 'North')
SELECT * FROM DUAL;
COMMIT;

-- Análise 1: Estatísticas descritivas
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== ESTATÍSTICAS DESCRITIVAS ===');
    ANALYTICS_PKG.calculate_advanced_statistics('SALES_ANALYSIS', 'AMOUNT');
END;
/

-- Análise 2: Detectar outliers
BEGIN
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '=== DETECÇÃO DE OUTLIERS ===');
    ANALYTICS_PKG.find_outliers_iqr('SALES_ANALYSIS', 'AMOUNT');
END;
/

-- Análise 3: Criar resumo mensal
BEGIN
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '=== RESUMO TEMPORAL ===');
    ANALYTICS_PKG.create_time_series_summary(
        'SALES_ANALYSIS', 'SALE_DATE', 'AMOUNT',
        'SALES_MONTHLY', 'MONTH'
    );
END;
/

-- Ver resultados do resumo
SELECT 
    TO_CHAR(period_start_date, 'YYYY-MM') AS periodo,
    total_records AS num_vendas,
    TO_CHAR(sum_value, 'FM999G999D00') AS total,
    TO_CHAR(avg_value, 'FM999G999D00') AS media
FROM SALES_MONTHLY
ORDER BY period_start_date;
```

### Caso de Uso 2: Análise de Risco Financeiro

```sql
-- Análise de carteira de investimentos
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== ANÁLISE DE RISCO DE PORTFÓLIO ===');
    FINANCIAL_ANALYSIS_PKG.portfolio_risk_analysis(
        'PORTFOLIO_RETURNS', 'RETURN_VALUE', 'RETURN_DATE'
    );
END;
/

-- Detecção de fraude em transações
BEGIN
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '=== DETECÇÃO DE FRAUDE ===');
    FINANCIAL_ANALYSIS_PKG.transaction_fraud_detection(
        'TRANSACTIONS', 'AMOUNT', 'CUSTOMER_ID'
    );
END;
/
```

## Testes

### Executar Todos os Testes

```sql
-- Testes unitários básicos
@tests/test_analytics_procedures.sql

-- Testes de integração completos
@tests/test_integration_analytics_procedures.sql
```

### Validação de Sintaxe

```bash
# Validar sintaxe PL/SQL de todos os arquivos
python3 validate_plsql.py
```

## Melhores Práticas

### Performance

1. **Índices**: Crie índices nas colunas usadas em ORDER BY e particionamento
   ```sql
   CREATE INDEX idx_sales_date ON sales_data(sale_date);
   CREATE INDEX idx_sales_category_date ON sales_data(category, sale_date);
   ```

2. **Particionamento**: Para tabelas grandes, use particionamento por data
   ```sql
   CREATE TABLE sales_data (...)
   PARTITION BY RANGE (sale_date) (...);
   ```

3. **Estatísticas**: Mantenha estatísticas atualizadas
   ```sql
   EXEC DBMS_STATS.GATHER_TABLE_STATS(USER, 'SALES_DATA');
   ```

### Segurança

1. **Validação de Entrada**: Todos os procedimentos validam entrada para prevenir SQL Injection
2. **Privilégios Mínimos**: Conceda apenas as permissões necessárias
3. **Auditoria**: Use DBMS_OUTPUT para logging de operações

### Manutenibilidade

1. **Nomenclatura Consistente**: Use nomes descritivos em UPPER_CASE
2. **Documentação**: Comente lógica complexa
3. **Versionamento**: Mantenha histórico de mudanças

## Resolução de Problemas

### Erro: "Tabela não encontrada"

**Causa**: A tabela especificada não existe ou o usuário não tem permissão.

**Solução**:
```sql
-- Verificar se a tabela existe
SELECT table_name FROM user_tables WHERE table_name = 'NOME_TABELA';

-- Verificar permissões
SELECT * FROM user_tab_privs WHERE table_name = 'NOME_TABELA';
```

### Erro: "Coluna não encontrada"

**Causa**: A coluna especificada não existe na tabela.

**Solução**:
```sql
-- Listar colunas da tabela
SELECT column_name, data_type FROM user_tab_columns 
WHERE table_name = 'NOME_TABELA';
```

### Erro: "ORA-00942: table or view does not exist"

**Causa**: Geralmente ocorre ao tentar dropar uma tabela que não existe.

**Solução**: Este erro é tratado internamente nos procedimentos, pode ser ignorado.

### Performance Lenta

**Causas Possíveis**:
- Falta de índices
- Estatísticas desatualizadas
- Volume de dados muito grande

**Soluções**:
```sql
-- Atualizar estatísticas
EXEC DBMS_STATS.GATHER_TABLE_STATS(USER, 'NOME_TABELA');

-- Criar índices apropriados
CREATE INDEX idx_nome ON tabela(coluna);

-- Usar hints para otimização
SELECT /*+ PARALLEL(4) */ ...
```

## Suporte e Contribuição

- **Issues**: https://github.com/galafis/plsql-advanced-analytics-procedures/issues
- **Pull Requests**: Bem-vindos!
- **Documentação**: Mantenha atualizada ao fazer mudanças

## Licença

MIT License - Ver arquivo LICENSE para detalhes.

## Autor

Gabriel Demetrios Lafis - 2025
