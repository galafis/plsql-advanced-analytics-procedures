#!/usr/bin/env python3
"""
PL/SQL Syntax Validator
Valida a sintaxe básica de arquivos PL/SQL
Author: Gabriel Demetrios Lafis
Year: 2025
"""

import os
import sys
import re
from pathlib import Path

def validate_plsql_syntax(file_path):
    """
    Valida sintaxe básica de PL/SQL sem dependências externas
    """
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        if not content.strip():
            print(f"[FALHA] O arquivo {file_path} está vazio.")
            return False

        # Basic syntax checks
        errors = []
        warnings = []
        
        # Check for common PL/SQL keywords and structure
        has_create = bool(re.search(r'\b(CREATE|REPLACE)\b', content, re.IGNORECASE))
        has_plsql = bool(re.search(r'\b(PROCEDURE|FUNCTION|PACKAGE|TRIGGER|BEGIN|END)\b', content, re.IGNORECASE))
        
        if not (has_create or has_plsql):
            warnings.append("O arquivo pode não conter objetos PL/SQL válidos")
        
        # Check for balanced BEGIN/END pairs (excluding package/procedure ends)
        begin_count = len(re.findall(r'\bBEGIN\b', content, re.IGNORECASE))
        # Don't count END followed by package/procedure names or semicolons at package level
        end_statements = re.findall(r'\bEND\b\s*(\w+)?[;/]', content, re.IGNORECASE)
        end_count = len([e for e in end_statements if not e or e.upper() in ['IF', 'LOOP', 'CASE']])
        
        # Only warn if there's a significant imbalance (more than 2 difference)
        if abs(begin_count - end_count) > 2:
            warnings.append(f"Possível desbalanceamento BEGIN/END: {begin_count} BEGIN, ~{end_count} END (pode ser falso positivo em packages)")
        
        # Check for basic statement terminators
        lines = content.split('\n')
        for i, line in enumerate(lines, 1):
            # Skip comments and empty lines
            clean_line = re.sub(r'--.*$', '', line).strip()
            if not clean_line:
                continue
            
            # Check for common syntax errors
            if re.search(r'CREATE\s+OR\s+REPLACE\s+TABLE', clean_line, re.IGNORECASE):
                errors.append(f"Linha {i}: 'CREATE OR REPLACE TABLE' é sintaxe inválida. Use apenas 'CREATE TABLE'")
        
        # Report results
        if errors:
            print(f"[FALHA] Erros encontrados em {file_path}:")
            for error in errors:
                print(f"  - {error}")
            return False
        
        if warnings:
            print(f"[AVISO] {file_path}:")
            for warning in warnings:
                print(f"  - {warning}")
        
        print(f"[SUCESSO] A sintaxe básica do arquivo {file_path} parece válida.")
        return True

    except FileNotFoundError:
        print(f"[FALHA] Arquivo não encontrado: {file_path}")
        return False
    except Exception as e:
        print(f"[FALHA] Erro ao validar {file_path}: {e}")
        return False

def validate_directory(directory):
    """
    Valida todos os arquivos .sql em um diretório
    """
    sql_files = list(Path(directory).rglob('*.sql'))
    
    if not sql_files:
        print(f"[AVISO] Nenhum arquivo .sql encontrado em {directory}")
        return True
    
    print(f"Validando {len(sql_files)} arquivo(s) SQL...\n")
    
    all_valid = True
    for sql_file in sql_files:
        if not validate_plsql_syntax(str(sql_file)):
            all_valid = False
        print()  # Empty line between files
    
    return all_valid

if __name__ == '__main__':
    # Get the script directory
    script_dir = Path(__file__).parent
    repo_root = script_dir
    
    # If running from repo root, use current directory
    if not (repo_root / 'src').exists():
        repo_root = Path.cwd()
    
    # Validate all SQL files
    print("=" * 60)
    print("PL/SQL Syntax Validator")
    print("=" * 60)
    print()
    
    directories_to_check = ['src', 'data', 'tests']
    overall_success = True
    
    for dir_name in directories_to_check:
        dir_path = repo_root / dir_name
        if dir_path.exists():
            print(f"\nValidando diretório: {dir_name}/")
            print("-" * 60)
            if not validate_directory(dir_path):
                overall_success = False
        else:
            print(f"[AVISO] Diretório {dir_name}/ não encontrado")
    
    print("\n" + "=" * 60)
    if overall_success:
        print("[SUCESSO] Todos os arquivos foram validados com sucesso!")
        sys.exit(0)
    else:
        print("[FALHA] Alguns arquivos contêm erros.")
        sys.exit(1)

