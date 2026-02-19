# TRABALHO2 — DVWA + Experimentos (ZAP, Nikto, sqlmap) + Explorações (SQLi e Command Injection)

Este repositório contém:
- **Implantação do DVWA (Damn Vulnerable Web App)** via Docker Compose (o alvo vulnerável);
- **Experimentos automatizados** com **OWASP ZAP** e **Nikto** (levantamento inicial de achados);
- **Exploração (prova de impacto)** de **SQL Injection** com **sqlmap** (confirmação/exploração da falha);
- **Exploração (prova de impacto)** de **Command Injection** diretamente no DVWA.

## Documentação Detalhada
Para instruções passo a passo, versões de ferramentas e explicações detalhadas dos comandos, consulte os arquivos específicos:
- **Instalação e Configuração**: [configuration_steps.md](./configuration_steps.md)
- **Scans com Nikto e ZAP**: [nikto_zap_steps.md](./nikto_zap_steps.md)
- **SQL Injection com sqlmap**: [sql_injection_steps.md](./sql_injection_steps.md)
- **Command Injection**: [command_injection_steps.md](./command_injection_steps.md)
- **Slides de Resumo do Trabalho**: https://docs.google.com/presentation/d/1j090U7X1ZJyrD9MvSZSMCB3zV8My5ETrxjJWCaTVg_U/edit?usp=sharing
- **Videos para Edição**: https://www.canva.com/design/DAHBsPbYaNQ/q4kJGLhNxtCVHKxC2CWOYw/edit?utm_content=DAHBsPbYaNQ&utm_campaign=designshare&utm_medium=link2&utm_source=sharebutton
> ⚠️ Execute **apenas em ambiente controlado** e com consentimento (DVWA é propositalmente vulnerável).

---

## 1) Pré-requisitos (por que isso é necessário)

### Software
- **Windows 10/11**  
  *Por quê:* os passos e os scripts foram testados nesse ambiente.
- **Docker Desktop** instalado e **em execução**  
  *Por quê:* o DVWA e as ferramentas (ZAP/Nikto/sqlmap) rodam em containers Docker.
- **Git Bash** (recomendado)  
  *Por quê:* os scripts são `.sh` (Bash). No CMD “puro”, eles não rodam diretamente (a menos que use WSL).

---

## 2) Estrutura esperada do projeto (onde cada coisa fica)

Os scripts assumem que você executa os comandos **a partir da pasta raiz** do projeto (a “raiz” é a pasta que contém o `docker-compose.yml`).

```
TRABALHO2/
  docker-compose.yml
  scripts/
    start.sh
    stop.sh
    zap_baseline.sh
    nikto.sh
    sqlmap_sqli_dump.sh
  evidencias/
```

---

## 3) Abrir o terminal no lugar certo (onde executar os comandos)

Abra o **Git Bash** e entre na pasta do projeto :

```bash
cd ~/PASTA_RAIZ/Trabalho2
```

você precisa estar na pasta raiz para que:
- o Compose ache o `docker-compose.yml`;
- os scripts encontrem o caminho correto para a pasta `evidencias/`.

---

## 4) Preparar os scripts (uma vez)

```bash
chmod +x scripts/*.sh
```

isso dá permissão de execução para os arquivos `.sh` no Git Bash.

---

## 5) Implantar o DVWA (subir o alvo vulnerável)

> **Nota:** Para um guia completo de instalação e configuração, veja [configuration_steps.md](./configuration_steps.md).

### 5.1 Subir o ambiente (Docker Compose)
Na **pasta raiz** do projeto:

```bash
./scripts/start.sh
```

este script executa o `docker compose up -d` e inicia o DVWA em background (sem travar o terminal).

O DVWA ficará disponível em:

- `http://localhost:8080`

---

### 5.2 Configuração obrigatória no DVWA (passos no navegador)
1) Acesse `http://localhost:8080`  
2) Login: **admin / password**  
3) Menu **DVWA Security** → selecione **Low** → Submit/Save  
4) Menu **DVWA Setup** → clique em **Create / Reset Database**


- **Security = Low** deixa as vulnerabilidades “bem abertas”, facilitando a demonstração.  
- **Create/Reset Database** garante um estado inicial consistente (reprodutível) para os experimentos.

---

## 6) Experimentos automatizados (ZAP e Nikto)

> **Nota:** Detalhes dos comandos e análise dos resultados estão em [nikto_zap_steps.md](./nikto_zap_steps.md).


### 6.1 OWASP ZAP Baseline (gera relatórios)
Na **pasta raiz**:

```bash
MSYS_NO_PATHCONV=1 MSYS2_ARG_CONV_EXCL="*" ./scripts/zap_baseline.sh
```

o ZAP Baseline realiza um scan **principalmente passivo**, gerando alertas e achados iniciais (ex.: headers ausentes, cookies sem flags etc.).

Arquivos gerados em `evidencias/`:
- `zap_report.html`
- `zap_report.json`
- `zap_report.md`
- (opcional) `zap.yaml`


### 6.2 Nikto (gera relatório TXT)
Na **pasta raiz**:

```bash
MSYS_NO_PATHCONV=1 MSYS2_ARG_CONV_EXCL="*" ./scripts/nikto.sh
```

o Nikto realiza um scan focado em **configurações e superfícies conhecidas** (headers, paths comuns, exposições e fingerprints).

Arquivo gerado em `evidencias/`:
- `nikto.txt`

---

## 7) Exploração 1 — SQL Injection (SQLi) com sqlmap

> **Nota:** O passo a passo detalhado da exploração com sqlmap está em [sql_injection_steps.md](./sql_injection_steps.md).

### 7.1 Obter cookie de sessão (PHPSESSID) no Brave/Chromium
No Brave:
1) Logado no DVWA (**admin/password**)  
2) **F12** → aba **Application**  
3) **Storage → Cookies → http://localhost:8080**  
4) Copie o valor de `PHPSESSID` e confirme `security=low`

o DVWA protege a página de SQLi com login. O `PHPSESSID` comprova para o servidor que você está autenticado (sessão ativa). Sem isso, o sqlmap é redirecionado para `login.php`.

Monte a string:
```
PHPSESSID=SEU_VALOR; security=low
```

---

### 7.2 Rodar sqlmap (robusto + salva evidência)
Na **pasta raiz**, execute:

```bash
MSYS_NO_PATHCONV=1 MSYS2_ARG_CONV_EXCL="*" docker run --rm -t   -v "$PWD/evidencias/sqlmap:/root/.local/share/sqlmap"   parrotsec/sqlmap   -u "http://host.docker.internal:8080/vulnerabilities/sqli/?id=1&Submit=Submit"   --cookie="PHPSESSID=SEU_VALOR; security=low"   --batch --flush-session --fresh-queries   --technique=BEU --time-sec=2 --random-agent   --dbs | tee evidencias/sqlmap_run.txt
```

este comando:
- roda o sqlmap em um container (`parrotsec/sqlmap`);
- aponta para a página vulnerável do DVWA (`/vulnerabilities/sqli/`);
- usa o cookie real para evitar redirecionamento para login;
- testa técnicas comuns (`BEU`) e lista as bases (`--dbs`);
- salva a saída do terminal em `evidencias/sqlmap_run.txt` (prova do experimento).

Resultados/artefatos em:
- `evidencias/sqlmap_run.txt`
- `evidencias/sqlmap/output/host.docker.internal/` (ex.: `log`, `target.txt`, `session.sqlite`)
- `evidencias/sqlmap/history/` (histórico do sqlmap, quando aplicável)


## 8) Exploração 2 — XSS (Cross-Site Scripting)

Escolha **uma** (Reflected é mais rápida; Stored é mais “forte” por ser persistente).

### 8.1 XSS Reflected (rápido)
1) DVWA → **Vulnerabilities → XSS (Reflected)**
2) Envie o payload:
```html
<script>alert('XSS')</script>
```
3) Submit

Esperado: aparece um **alert**.

o valor digitado é “refletido” na resposta sem escape, então o navegador interpreta a tag `<script>` e executa o JavaScript.


### 8.2 XSS Stored (persistente)
1) DVWA → **Vulnerabilities → XSS (Stored)**
2) Preencha:
- Name: `teste`
- Message:
```html
<script>alert('Stored XSS')</script>
```
3) Submit e recarregue a página

Esperado: o alert dispara ao exibir o conteúdo (persistente).

o payload é salvo (armazenado) e executa sempre que a página exibe aquela entrada.


## 9) Entendendo os arquivos de output (o que cada um significa)

### 9.1 Outputs do ZAP
- `evidencias/zap_report.html`  
  Relatório **para leitura humana** (visual). Bom para tirar screenshot e citar achados.
- `evidencias/zap_report.json`  
  Relatório em **formato estruturado** (máquina). Útil se você quiser extrair alertas automaticamente.
- `evidencias/zap_report.md`  
  Versão em **Markdown** do relatório (boa para colar em documentação).
- `evidencias/zap.yaml` (quando gerado)  
  Arquivo da automação/configuração usada pelo framework de automação do ZAP.

### 9.2 Output do Nikto
- `evidencias/nikto.txt`  
  Saída do Nikto em texto: fingerprints, headers, paths/testes, e alertas encontrados.

### 9.3 Outputs do sqlmap
- `evidencias/sqlmap_run.txt`  
  Cópia da saída do terminal (o que você viu durante a execução). Ótimo para anexar como evidência.
- `evidencias/sqlmap/output/host.docker.internal/log`  
  Log detalhado do sqlmap (inclui técnicas encontradas e resultados).
- `evidencias/sqlmap/output/host.docker.internal/target.txt`  
  Registro do alvo e do que foi testado (URL e parâmetros).
- `evidencias/sqlmap/output/host.docker.internal/session.sqlite`  
  Cache/estado da sessão (evita repetir testes). Se quiser “do zero”, use `--flush-session`.
- `evidencias/sqlmap/history/`  
  Arquivos de histórico da execução (varia por versão/config).

### 9.4 Screenshots (evidência visual)
- `evidencias/screenshots/`  
  Pasta sugerida para colocar prints do DVWA (Security=Low, reset DB) e das explorações (SQLi/XSS).

---

## 10) Onde ficam as evidências (exemplo final)

```
evidencias/
  nikto.txt
  zap_report.html
  zap_report.json
  zap_report.md
  zap.yaml
  sqlmap_run.txt
  sqlmap/
    output/
      host.docker.internal/
        log
        target.txt
        session.sqlite
    history/
  screenshots/
    dvwa_home.png
    dvwa_security_low.png
    dvwa_setup_reset.png
    sqli_sqlmap_injectable.png
    xss_alert.png
```

---

## 11) Encerrar o ambiente (parar o DVWA)

Na **pasta raiz**:

```bash
./scripts/stop.sh
```

isso encerra os containers do DVWA e limpa a rede criada pelo Compose.

---




