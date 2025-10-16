#!/bin/bash
# Script para executar testes dos procedimentos PL/SQL
# Author: Gabriel Demetrios Lafis
# Year: 2025

set -e

echo "================================================"
echo "PL/SQL Advanced Analytics - Test Runner"
echo "================================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Create temporary output file
TEST_OUTPUT=$(mktemp)

echo -e "${YELLOW}[INFO]${NC} Conectando ao banco de dados..."
echo -e "${BLUE}[INFO]${NC} Executando testes unitários..."

# Run unit tests
sqlplus -s ${DB_USER}/${DB_PASS}@${DB_CONN} @tests/test_analytics_procedures.sql > $TEST_OUTPUT 2>&1

if [ $? -eq 0 ]; then
    echo -e "${GREEN}[SUCESSO]${NC} Testes unitários executados."
    
    # Check for errors in output
    if grep -q "\\[ERRO\\]\\|\\[FALHA\\]" $TEST_OUTPUT; then
        echo -e "${YELLOW}[AVISO]${NC} Alguns testes podem ter falhado. Verifique a saída:"
        cat $TEST_OUTPUT
        exit 1
    else
        echo -e "${GREEN}[SUCESSO]${NC} Todos os testes unitários passaram!"
    fi
else
    echo -e "${RED}[ERRO]${NC} Falha ao executar testes unitários."
    cat $TEST_OUTPUT
    rm $TEST_OUTPUT
    exit 1
fi

echo ""
echo -e "${BLUE}[INFO]${NC} Executando testes de integração..."

# Run integration tests
sqlplus -s ${DB_USER}/${DB_PASS}@${DB_CONN} @tests/test_integration_analytics_procedures.sql > $TEST_OUTPUT 2>&1

if [ $? -eq 0 ]; then
    echo -e "${GREEN}[SUCESSO]${NC} Testes de integração executados."
    
    # Check for errors in output
    if grep -q "\\[ERRO\\]\\|\\[FALHA\\]" $TEST_OUTPUT; then
        echo -e "${YELLOW}[AVISO]${NC} Alguns testes podem ter falhado. Verifique a saída:"
        cat $TEST_OUTPUT
        rm $TEST_OUTPUT
        exit 1
    else
        echo -e "${GREEN}[SUCESSO]${NC} Todos os testes de integração passaram!"
    fi
else
    echo -e "${RED}[ERRO]${NC} Falha ao executar testes de integração."
    cat $TEST_OUTPUT
    rm $TEST_OUTPUT
    exit 1
fi

# Cleanup
rm $TEST_OUTPUT

echo ""
echo "================================================"
echo -e "${GREEN}[SUCESSO]${NC} Todos os testes foram executados com sucesso!"
echo "================================================"

exit 0
