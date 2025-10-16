# Contributing to PL/SQL Advanced Analytics Procedures

Obrigado pelo interesse em contribuir! Este guia ajudará você a começar.

## 🎯 Tipos de Contribuição

Aceitamos diversos tipos de contribuição:

- 🐛 **Bug reports**: Reporte erros ou comportamentos inesperados
- ✨ **Feature requests**: Sugira novas funcionalidades
- 📝 **Documentation**: Melhore ou corrija documentação
- 🔧 **Code contributions**: Contribua com código
- 🧪 **Tests**: Adicione ou melhore testes
- 💡 **Ideas**: Compartilhe ideias e discussões

## 🚀 Como Começar

### 1. Fork e Clone

```bash
# Fork o repositório no GitHub, depois:
git clone https://github.com/SEU-USUARIO/plsql-advanced-analytics-procedures.git
cd plsql-advanced-analytics-procedures
```

### 2. Configure o Ambiente

```bash
# Verificar pré-requisitos
./scripts/check_environment.sh

# Validar código existente
python3 validate_plsql.py
```

### 3. Crie uma Branch

```bash
git checkout -b feature/nome-da-sua-feature
# ou
git checkout -b fix/nome-do-bug
```

## 📝 Padrões de Código

### PL/SQL

```sql
-- Boas práticas:
-- 1. Use UPPER_CASE para objetos de banco de dados
-- 2. Use v_ para variáveis locais
-- 3. Use p_ para parâmetros
-- 4. Sempre inclua tratamento de erros
-- 5. Documente procedimentos complexos

CREATE OR REPLACE PROCEDURE example_procedure(
    p_table_name IN VARCHAR2,  -- Parâmetro de entrada
    p_column_name IN VARCHAR2
) AS
    v_result NUMBER;  -- Variável local
BEGIN
    -- Validação de entrada
    IF p_table_name IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'Nome da tabela é obrigatório');
    END IF;
    
    -- Lógica principal
    -- ...
    
    -- Logging
    DBMS_OUTPUT.PUT_LINE(
        TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || 
        ' [INFO] Operação concluída'
    );
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(
            TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || 
            ' [ERRO] ' || SQLERRM
        );
        RAISE;
END;
/
```

### Python

```python
# Use type hints
def validate_file(file_path: str) -> bool:
    """Valida um arquivo SQL."""
    pass

# Docstrings são obrigatórias
def my_function(param: str) -> int:
    """
    Breve descrição.
    
    Args:
        param: Descrição do parâmetro
        
    Returns:
        Descrição do retorno
    """
    pass
```

### Bash

```bash
#!/bin/bash
# Sempre inclua shebang
# Use set -e para falhar em erros
set -e

# Use cores para melhor legibilidade
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# Valide inputs
if [ -z "$1" ]; then
    echo -e "${RED}[ERRO]${NC} Parâmetro obrigatório"
    exit 1
fi
```

## 🧪 Testes

### Adicione Testes

Toda nova funcionalidade deve incluir testes:

```sql
-- Em tests/test_analytics_procedures.sql ou novo arquivo

-- Teste: nome_da_funcionalidade
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- Teste: Nome da Funcionalidade ---');
    
    -- Setup
    EXECUTE IMMEDIATE 'CREATE TABLE test_data (...)';
    
    -- Execute
    BEGIN
        -- Sua funcionalidade aqui
        ANALYTICS_PKG.nova_funcao('TEST_DATA', 'COLUMN');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('[FALHA] ' || SQLERRM);
            RAISE;
    END;
    
    -- Cleanup
    EXECUTE IMMEDIATE 'DROP TABLE test_data';
    
    DBMS_OUTPUT.PUT_LINE('[SUCESSO] Teste passou!');
END;
/
```

### Execute os Testes

```bash
# Validação de sintaxe
python3 validate_plsql.py

# Testes funcionais (se tiver acesso a Oracle DB)
./scripts/run_tests.sh usuario senha connection
```

## 📚 Documentação

### README.md

Atualize o README se:
- Adicionar nova funcionalidade importante
- Mudar comportamento existente
- Adicionar novos pré-requisitos

### docs/DOCUMENTATION.md

Documente procedimentos novos:

```markdown
#### nome_do_procedimento

Breve descrição do que faz.

**Parâmetros:**
- `p_param1` (VARCHAR2): Descrição
- `p_param2` (NUMBER): Descrição

**Exemplo:**
​```sql
BEGIN
    ANALYTICS_PKG.nome_do_procedimento('TABLE', 'COLUMN');
END;
/
​```
```

### Comentários no Código

```sql
-- ============================================================================
-- Título do Procedimento
-- Descrição detalhada do que faz, quando usar, limitações.
-- ============================================================================
```

## 🔄 Processo de Pull Request

### 1. Antes de Submeter

```bash
# Validar sintaxe
python3 validate_plsql.py

# Verificar que não quebrou nada
./scripts/check_environment.sh

# Commit com mensagem descritiva
git add .
git commit -m "feat: adiciona funcionalidade X"
# ou
git commit -m "fix: corrige bug Y"
# ou
git commit -m "docs: atualiza documentação Z"
```

### 2. Padrão de Commits

Use [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` Nova funcionalidade
- `fix:` Correção de bug
- `docs:` Mudanças na documentação
- `test:` Adiciona ou modifica testes
- `refactor:` Refatoração de código
- `style:` Mudanças de formatação
- `chore:` Tarefas de manutenção

Exemplos:
```
feat: adiciona procedimento para análise de tendências
fix: corrige bug em find_outliers_iqr quando dados são NULL
docs: atualiza guia de instalação com novos requisitos
test: adiciona testes de integração para financial_analysis
```

### 3. Submeter PR

1. Push para seu fork:
   ```bash
   git push origin feature/nome-da-sua-feature
   ```

2. Abra PR no GitHub

3. Preencha o template:
   - Descrição clara do que foi feito
   - Por que a mudança é necessária
   - Como foi testado
   - Screenshots (se aplicável)

### 4. Review Process

- ✅ CI/CD deve passar (GitHub Actions)
- ✅ Code review por mantenedor
- ✅ Testes devem estar incluídos
- ✅ Documentação deve estar atualizada

## 🐛 Reportando Bugs

Use o [GitHub Issues](https://github.com/galafis/plsql-advanced-analytics-procedures/issues) com:

### Template de Bug Report

```markdown
**Descrição do Bug**
Descrição clara e concisa do bug.

**Como Reproduzir**
1. Execute '...'
2. Com dados '...'
3. Veja erro '...'

**Comportamento Esperado**
O que deveria acontecer.

**Comportamento Atual**
O que realmente acontece.

**Ambiente**
- Oracle Database: [ex: 19c]
- SO: [ex: Ubuntu 22.04]
- Versão do projeto: [ex: 1.0.0]

**Logs/Screenshots**
Cole logs relevantes ou screenshots.

**Informações Adicionais**
Qualquer contexto adicional.
```

## ✨ Sugerindo Funcionalidades

Use [GitHub Issues](https://github.com/galafis/plsql-advanced-analytics-procedures/issues) com:

### Template de Feature Request

```markdown
**Descrição da Funcionalidade**
Descrição clara do que você quer.

**Problema que Resolve**
Que problema essa funcionalidade resolveria?

**Solução Proposta**
Como você imagina que isso funcionaria?

**Alternativas Consideradas**
Outras abordagens que você considerou.

**Exemplo de Uso**
​```sql
-- Como seria usar essa funcionalidade
BEGIN
    ANALYTICS_PKG.nova_funcao(...);
END;
/
​```

**Impacto**
- Complexidade: [baixa/média/alta]
- Prioridade: [baixa/média/alta]
```

## 📋 Checklist de PR

Antes de submeter, verifique:

- [ ] Código segue os padrões do projeto
- [ ] Comentários foram adicionados onde necessário
- [ ] Documentação foi atualizada
- [ ] Testes foram adicionados/atualizados
- [ ] Todos os testes passam localmente
- [ ] Validação de sintaxe passa (`python3 validate_plsql.py`)
- [ ] Commit messages seguem Conventional Commits
- [ ] PR tem descrição clara
- [ ] Mudanças são focadas (uma funcionalidade/fix por PR)

## 🎓 Recursos

- [Oracle PL/SQL Documentation](https://docs.oracle.com/en/database/oracle/oracle-database/19/lnpls/)
- [PL/SQL Best Practices](https://oracle-base.com/articles/misc/plsql-best-practices)
- [Git Basics](https://git-scm.com/book/en/v2/Getting-Started-Git-Basics)
- [GitHub Flow](https://guides.github.com/introduction/flow/)

## 📞 Dúvidas?

- Abra uma [Discussion](https://github.com/galafis/plsql-advanced-analytics-procedures/discussions)
- Comente em uma Issue existente
- Entre em contato com os mantenedores

## 🙏 Agradecimentos

Obrigado por contribuir para tornar este projeto melhor! Toda contribuição é valiosa.

---

**Happy Coding! 🚀**
