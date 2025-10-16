#!/bin/bash
# Script para verificar o ambiente e pré-requisitos
# Author: Gabriel Demetrios Lafis
# Year: 2025

echo "================================================"
echo "Environment Check for PL/SQL Analytics"
echo "================================================"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

all_ok=true

# Check Python
echo -n "Checking Python... "
if command -v python3 &> /dev/null; then
    version=$(python3 --version 2>&1 | cut -d' ' -f2)
    echo -e "${GREEN}✓${NC} Found Python $version"
else
    echo -e "${RED}✗${NC} Python 3 not found"
    all_ok=false
fi

# Check SQL*Plus
echo -n "Checking SQL*Plus... "
if command -v sqlplus &> /dev/null; then
    echo -e "${GREEN}✓${NC} Found SQL*Plus"
else
    echo -e "${YELLOW}⚠${NC} SQL*Plus not found (optional for deployment)"
fi

# Check Git
echo -n "Checking Git... "
if command -v git &> /dev/null; then
    version=$(git --version 2>&1 | cut -d' ' -f3)
    echo -e "${GREEN}✓${NC} Found Git $version"
else
    echo -e "${RED}✗${NC} Git not found"
    all_ok=false
fi

# Check required files
echo ""
echo "Checking repository files..."

required_files=(
    "src/core_analytics/analytics_package.sql"
    "src/financial_analytics/advanced_financial_analysis.sql"
    "data/financial_data_setup.sql"
    "tests/test_analytics_procedures.sql"
    "scripts/deploy.sh"
    "scripts/run_tests.sh"
    "validate_plsql.py"
    "README.md"
    "LICENSE"
)

missing_files=0
for file in "${required_files[@]}"; do
    echo -n "  $file... "
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${RED}✗${NC}"
        missing_files=$((missing_files + 1))
        all_ok=false
    fi
done

# Check scripts are executable
echo ""
echo "Checking script permissions..."
scripts=("scripts/deploy.sh" "scripts/run_tests.sh" "validate_plsql.py")
for script in "${scripts[@]}"; do
    if [ -f "$script" ]; then
        echo -n "  $script... "
        if [ -x "$script" ]; then
            echo -e "${GREEN}✓ executable${NC}"
        else
            echo -e "${YELLOW}⚠ not executable (run: chmod +x $script)${NC}"
        fi
    fi
done

# Test Python validator
echo ""
echo -n "Testing PL/SQL validator... "
if python3 validate_plsql.py > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Working"
else
    echo -e "${YELLOW}⚠${NC} Check validation output"
fi

# Summary
echo ""
echo "================================================"
if [ "$all_ok" = true ] && [ $missing_files -eq 0 ]; then
    echo -e "${GREEN}✓ Environment is ready!${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Run: python3 validate_plsql.py"
    echo "  2. Deploy: ./scripts/deploy.sh <user> <pass> <conn>"
    echo "  3. Test: ./scripts/run_tests.sh <user> <pass> <conn>"
    exit 0
else
    echo -e "${RED}✗ Some issues found${NC}"
    echo ""
    if [ "$all_ok" = false ]; then
        echo "Missing required tools. Please install:"
        command -v python3 &> /dev/null || echo "  - Python 3"
        command -v git &> /dev/null || echo "  - Git"
    fi
    if [ $missing_files -gt 0 ]; then
        echo "Missing $missing_files required file(s)"
        echo "Make sure you're in the repository root directory"
    fi
    exit 1
fi
