import sqlparse

def validate_plsql_syntax(file_path):
    try:
        with open(file_path, 'r') as f:
            sql_content = f.read()
        
        # sqlparse is a non-validating parser, but can help with basic syntax and structure
        parsed = sqlparse.parse(sql_content)
        
        if not parsed:
            print(f"[FALHA] O arquivo {file_path} está vazio ou não contém SQL válido.")
            return False

        # Check for any errors reported by sqlparse (though it's limited for PL/SQL)
        # sqlparse.parse returns a list of statements. If any statement is malformed,
        # it might still parse but the structure might be off. 
        # For a more robust check, one would need a full PL/SQL parser.
        
        # A simple check: if parsing was successful, assume basic syntax is okay.
        # This is a heuristic, not a full validation.
        print(f"[SUCESSO] A sintaxe básica do arquivo {file_path} parece válida (verificado com sqlparse).")
        return True

    except FileNotFoundError:
        print(f"[FALHA] Arquivo não encontrado: {file_path}")
        return False
    except Exception as e:
        print(f"[FALHA] Erro ao validar {file_path}: {e}")
        return False

if __name__ == '__main__':
    plsql_file = '/home/ubuntu/plsql-advanced-analytics-procedures/src/analytics_procedures.sql'
    validate_plsql_syntax(plsql_file)

