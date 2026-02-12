# Quick Start Guide

## 🚀 Começando em 5 Minutos

### Pré-requisitos Rápidos

```bash
# Você precisa ter:
- Oracle Database 12c ou superior
- SQL*Plus, SQL Developer ou SQLcl
- Python 3.x (para validação)
```

### Passo 1: Clone o Repositório

```bash
git clone https://github.com/galafis/plsql-advanced-analytics-procedures.git
cd plsql-advanced-analytics-procedures
```

### Passo 2: Valide a Sintaxe (Opcional mas Recomendado)

```bash
python3 validate_plsql.py
```

### Passo 3: Deploy dos Pacotes

#### Opção A: Deploy Automatizado (Linux/Mac)

```bash
./scripts/deploy.sh usuario senha connection_string

# Exemplo:
./scripts/deploy.sh scott tiger localhost:1521/XEPDB1
```

#### Opção B: Deploy Manual

```sql
-- Conecte ao banco
sqlplus usuario/senha@connection_string

-- Deploy dos pacotes
@src/core_analytics/analytics_package.sql
@src/financial_analytics/advanced_financial_analysis.sql

-- (Opcional) Dados de exemplo
@data/financial_data_setup.sql
```

### Passo 4: Teste Rápido

```sql
SET SERVEROUTPUT ON;

-- Criar uma tabela de teste simples
CREATE TABLE test_sales (
    id NUMBER PRIMARY KEY,
    amount NUMBER(10,2),
    sale_date DATE
);

-- Inserir alguns dados
INSERT INTO test_sales VALUES (1, 1000, SYSDATE);
INSERT INTO test_sales VALUES (2, 1500, SYSDATE-1);
INSERT INTO test_sales VALUES (3, 1200, SYSDATE-2);
INSERT INTO test_sales VALUES (4, 5000, SYSDATE-3); -- outlier
COMMIT;

-- Testar o pacote
BEGIN
    ANALYTICS_PKG.calculate_advanced_statistics('TEST_SALES', 'AMOUNT');
END;
/

-- Limpar
DROP TABLE test_sales;
```

Se você ver estatísticas (média, mediana, etc.) na saída, está funcionando! 🎉

### Passo 5: Explorar

Agora você pode:

1. **Ler a documentação completa**: [docs/DOCUMENTATION.md](docs/DOCUMENTATION.md)
2. **Executar os testes**: `./scripts/run_tests.sh usuario senha connection`
3. **Ver exemplos de uso**: Seção "Exemplo de Uso Avançado" no README.md

---

## 📚 Exemplos Rápidos por Caso de Uso

### Análise de Vendas

```sql
-- Calcular estatísticas de vendas
BEGIN
    ANALYTICS_PKG.calculate_advanced_statistics('SALES_DATA', 'AMOUNT');
END;
/

-- Detectar vendas atípicas
BEGIN
    ANALYTICS_PKG.find_outliers_iqr('SALES_DATA', 'AMOUNT');
END;
/
```

### Análise de Séries Temporais

```sql
-- Criar resumo mensal
BEGIN
    ANALYTICS_PKG.create_time_series_summary(
        'SALES_DATA', 
        'SALE_DATE', 
        'AMOUNT',
        'MONTHLY_SUMMARY',
        'MONTH'
    );
END;
/

-- Ver resultados
SELECT * FROM MONTHLY_SUMMARY ORDER BY period_start_date;
```

### Análise Financeira

```sql
-- Análise de risco
BEGIN
    FINANCIAL_ANALYSIS_PKG.portfolio_risk_analysis(
        'PORTFOLIO_RETURNS',
        'RETURN_VALUE',
        'RETURN_DATE'
    );
END;
/

-- Detecção de fraude
BEGIN
    FINANCIAL_ANALYSIS_PKG.transaction_fraud_detection(
        'TRANSACTIONS',
        'AMOUNT',
        'CUSTOMER_ID'
    );
END;
/
```

---

## 🆘 Problemas Comuns

### "Command not found: sqlplus"

**Solução**: Instale o Oracle Instant Client:
- [Download Oracle Instant Client](https://www.oracle.com/database/technologies/instant-client/downloads.html)

### "Package não encontrado"

**Solução**: Execute o deploy novamente:
```bash
./scripts/deploy.sh usuario senha connection_string
```

### "Table or view does not exist"

**Solução**: Crie seus dados ou use os exemplos:
```sql
@data/financial_data_setup.sql
```

---

## 🎯 Próximos Passos

1. **Customize para seus dados**: Adapte as queries para suas tabelas
2. **Crie índices**: Para melhor performance em tabelas grandes
3. **Automatize relatórios**: Use os procedimentos em jobs agendados
4. **Integre com BI**: Conecte as tabelas de resumo a ferramentas de BI

---

## 📞 Precisa de Ajuda?

- 📖 [Documentação Completa](docs/DOCUMENTATION.md)
- 🐛 [Reportar Issues](https://github.com/galafis/plsql-advanced-analytics-procedures/issues)
- 💬 [Discussões](https://github.com/galafis/plsql-advanced-analytics-procedures/discussions)
