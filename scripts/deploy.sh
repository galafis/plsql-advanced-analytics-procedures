#!/bin/bash
# Script para fazer deploy dos procedimentos PL/SQL no Oracle Database
# Author: Gabriel Demetrios Lafis
# Year: 2025

set -e

echo "================================================"
echo "PL/SQL Advanced Analytics - Deploy Script"
echo "================================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if sqlplus is available
if ! command -v sqlplus &> /dev/null; then
    echo -e "${RED}[ERRO]${NC} SQL*Plus não encontrado. Instale o Oracle Instant Client."
    exit 1
fi

# Get connection string from environment or parameters
DB_USER=${1:-${ORACLE_USER}}
DB_PASS=${2:-${ORACLE_PASSWORD}}
DB_CONN=${3:-${ORACLE_CONN}}

if [ -z "$DB_USER" ] || [ -z "$DB_PASS" ] || [ -z "$DB_CONN" ]; then
    echo -e "${RED}[ERRO]${NC} Parâmetros de conexão não fornecidos."
    echo "Uso: $0 <user> <password> <connection_string>"
    echo "Ou configure as variáveis de ambiente: ORACLE_USER, ORACLE_PASSWORD, ORACLE_CONN"
    exit 1
fi

echo -e "${YELLOW}[INFO]${NC} Conectando ao banco de dados..."

# Deploy core analytics package
echo -e "${YELLOW}[INFO]${NC} Deployando pacote ANALYTICS_PKG..."
sqlplus -s ${DB_USER}/${DB_PASS}@${DB_CONN} @src/core_analytics/analytics_package.sql

if [ $? -eq 0 ]; then
    echo -e "${GREEN}[SUCESSO]${NC} ANALYTICS_PKG deployado com sucesso."
else
    echo -e "${RED}[ERRO]${NC} Falha ao deployar ANALYTICS_PKG."
    exit 1
fi

# Deploy financial analytics package
echo -e "${YELLOW}[INFO]${NC} Deployando pacote FINANCIAL_ANALYSIS_PKG..."
sqlplus -s ${DB_USER}/${DB_PASS}@${DB_CONN} @src/financial_analytics/advanced_financial_analysis.sql

if [ $? -eq 0 ]; then
    echo -e "${GREEN}[SUCESSO]${NC} FINANCIAL_ANALYSIS_PKG deployado com sucesso."
else
    echo -e "${RED}[ERRO]${NC} Falha ao deployar FINANCIAL_ANALYSIS_PKG."
    exit 1
fi

# Setup example data (optional)
read -p "Deseja criar os dados de exemplo? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}[INFO]${NC} Criando dados de exemplo..."
    sqlplus -s ${DB_USER}/${DB_PASS}@${DB_CONN} @data/financial_data_setup.sql
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[SUCESSO]${NC} Dados de exemplo criados com sucesso."
    else
        echo -e "${RED}[ERRO]${NC} Falha ao criar dados de exemplo."
    fi
fi

echo -e "${GREEN}[SUCESSO]${NC} Deploy completo!"
echo "================================================"
