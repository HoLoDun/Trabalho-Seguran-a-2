# Documentação de Experimentos: Análise de Vulnerabilidades com Nikto e OWASP ZAP

Esta documentação descreve os procedimentos para reproduzir a análise de vulnerabilidades realizada em um ambiente controlado e deliberadamente vulnerável (DVWA - Damn Vulnerable Web App).

## Ambiente de Teste
- **Alvo**: DVWA (Damn Vulnerable Web App) rodando localmente via Docker Compose.
- **Configuração do Alvo**:
    - **Login**: `admin` / `password`
    - **Nível de Segurança**: `Low` (Baixo)
    - **Estado do Banco**: Resetado (`Create / Reset Database`)

---

## 1. OWASP ZAP (Zed Attack Proxy)

O OWASP ZAP foi utilizado para identificar vulnerabilidades de aplicação web, como headers de segurança ausentes, configurações incorretas de cookies e vazamento de informações.

### Ferramenta Utilizada
- **Nome**: OWASP ZAP
- **Versão/Imagem Docker**: `ghcr.io/zaproxy/zaproxy:stable`
- **Tipo de Scan**: Baseline Scan (`zap-baseline.py`)

### Procedimento de Execução
O comando abaixo executa o scan do ZAP via container Docker, montando um volume local para salvar os relatórios.

**Comando:**
```bash
docker run --rm -t \
  -v "$OUTDIR:/zap/wrk" \
  ghcr.io/zaproxy/zaproxy:stable \
  zap-baseline.py \
    -t "$TARGET_URL" \
    -r zap_report.html \
    -J zap_report.json \
    -w zap_report.md \
    -m 2
```

**Explicação dos Parâmetros:**
- `docker run --rm -t`: Cria e inicia um container temporário (`--rm` remove o container após a execução, `-t` aloca um pseudo-TTY).
- `-v "$OUTDIR:/zap/wrk"`: Monta o diretório local `$OUTDIR` no diretório de trabalho do container (`/zap/wrk`) para persistir os relatórios gerados.
- `ghcr.io/zaproxy/zaproxy:stable`: A imagem Docker oficial estável do ZAP.
- `zap-baseline.py`: Script do ZAP para realizar um scan rápido (passivo/Spider) em busca de problemas comuns.
- `-t "$TARGET_URL"`: Define a URL alvo do scan (neste caso, o endereço do DVWA).
- `-r zap_report.html`: Nome do arquivo de relatório em formato HTML.
- `-J zap_report.json`: Nome do arquivo de relatório em formato JSON.
- `-w zap_report.md`: Nome do arquivo de relatório em formato Markdown.
- `-m 2`: Define o tempo máximo (em minutos) para o spidering (navegação automática) do site.

### Resultados Obtidos
O relatório `zap_report.html` indicou **2 alertas de risco médio** e **7 alertas de risco baixo**.

![Resumo dos Alertas](./evidencias/alerts_summary.png)

#### Alertas de Risco Médio:
1.  **Content Security Policy (CSP) Header Not Set**:
    -   **Descrição**: O servidor não define a política de segurança de conteúdo, permitindo que o navegador carregue recursos de qualquer origem.
    -   **Impacto**: Aumenta o risco de ataques como Cross-Site Scripting (XSS).
2.  **Missing Anti-clickjacking Header**:
    -   **Descrição**: Ausência de headers como `X-Frame-Options` ou `Content-Security-Policy` com diretiva `frame-ancestors`.
    -   **Impacto**: Permite que a aplicação seja carregada em um `iframe` por sites maliciosos, facilitando ataques de Clickjacking.

#### Alertas de Risco Baixo:
Incluem problemas como cookies sem flag `HttpOnly` ou `SameSite`, vazamento de versão do servidor e ausência de headers como `X-Content-Type-Options`.

![Lista de Alertas Detalhada](./evidencias/alerts.png)

---

## 2. Nikto

O Nikto foi utilizado para varrer o servidor web em busca de arquivos perigosos, CGIs desatualizados e problemas de configuração do servidor.

### Ferramenta Utilizada
- **Nome**: Nikto
- **Versão/Imagem Docker**: `alpine/nikto:2.1.6`

### Procedimento de Execução
O comando abaixo executa o Nikto contra o alvo especificado e salva a saída em um arquivo de texto.

**Comando:**
```bash
docker run --rm -t \
  -v "$OUTDIR:/out" \
  alpine/nikto:2.1.6 \
  -h "$TARGET_URL" \
  -Format txt \
  -output /out/nikto.txt
```

**Explicação dos Parâmetros:**
- `-v "$OUTDIR:/out"`: Monta o diretório local para salvar o relatório.
- `alpine/nikto:2.1.6`: Imagem Docker leve contendo o Nikto versão 2.1.6.
- `-h "$TARGET_URL"`: Define o host (alvo) a ser escaneado.
- `-Format txt`: Especifica o formato de saída do relatório como texto simples.
- `-output /out/nikto.txt`: Define o caminho e nome do arquivo de saída dentro do container (que é mapeado para o host).

### Resultados Obtidos
A análise do arquivo `nikto.txt` revelou falhas semelhantes e complementares às do ZAP:

1.  **Segurança de Cookies**:
    -   `Cookie PHPSESSID created without the httponly flag`
    -   `Cookie security created without the httponly flag`
2.  **Headers de Segurança Ausentes**:
    -   `X-Frame-Options header is not present`
    -   `X-XSS-Protection header is not defined`
    -   `X-Content-Type-Options header is not set`
3.  **Vazamento de Informações**:
    -   `Server leaks inodes via ETags`
    -   `Apache default file found (/icons/README)`
4.  **Exposição de Diretórios e Arquivos**:
    -   Indexação de diretórios ativada em `/config/` e `/docs/`.
    -   Página de login administrativa encontrada em `/login.php`.

Ambas as ferramentas confirmaram que a configuração padrão do ambiente DVWA (nível `Low`) possui diversas falhas de configuração de segurança básicas.
