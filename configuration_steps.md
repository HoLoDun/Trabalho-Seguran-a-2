# Instruções de Instalação e Configuração do Ambiente

Este documento fornece o passo a passo completo para configurar o ambiente vulnerável utilizado nos experimentos de segurança.

## 1. Requisitos de Software

Para reproduzir este ambiente, são necessários os seguintes softwares instalados no sistema operacional (Windows, Linux ou macOS):

-   **Docker Desktop** (ou Docker Engine + Docker Compose em Linux)
    -   Versão recomendada: Docker 20.10+ / Docker Compose v2+
-   **Sistema Operacional Testado**: Windows 10/11 (com WSL 2 backend para Docker)

## 2. Instalação e Execução do Servidor Vulnerável

O ambiente utiliza a imagem Docker oficial do DVWA (`vulnerables/web-dvwa`).

### Arquivo de Configuração (`docker-compose.yml`)
Crie um arquivo chamado `docker-compose.yml` com o seguinte conteúdo:

```yaml
services:
  dvwa:
    image: vulnerables/web-dvwa:latest
    container_name: dvwa
    ports:
      - "8080:80"
    restart: unless-stopped
```

### Comandos de Execução

1.  **Iniciar o Ambiente**:
    Abra o terminal na pasta onde o arquivo `docker-compose.yml` foi salvo e execute:
    ```bash
    docker-compose up -d
    ```
    *O comando `up` sobe os containers definidos no arquivo. A flag `-d` executa em modo "detached" (em segundo plano).*

2.  **Verificar Status**:
    Para confirmar se o container está rodando:
    ```bash
    docker ps
    ```
    *Deverá aparecer um container chamado `dvwa` com status `Up`.*

3.  **Parar o Ambiente**:
    Para desligar e remover os containers:
    ```bash
    docker-compose down
    ```

## 3. Configuração Inicial da Aplicação

Após iniciar o container, siga os passos abaixo para preparar o DVWA para os testes:

1.  **Acesso à Aplicação**:
    -   Abra o navegador e acesse: [http://localhost:8080](http://localhost:8080)
    -   *Nota: Se estiver usando Docker Toolbox ou uma VM remota, substitua `localhost` pelo IP correspondente.*

2.  **Login Inicial**:
     Utilize as credenciais padrão do DVWA:
    -   **Usuário**: `admin`
    -   **Senha**: `password`

3.  **Setup do Banco de Dados**:
    -   Ao logar pela primeira vez, você será redirecionado para a página de configuração.
    -   Role até o final da página e clique no botão **"Create / Reset Database"**.
    -   Aguarde a mensagem de confirmação e você será redirecionado para a tela de login novamente.

4.  **Ajuste do Nível de Segurança**:
    -   No menu lateral esquerdo, clique em **"DVWA Security"**.
    -   Altere o "Security Level" para **"Low"** (Baixo).
    -   Clique em **"Submit"**.

O ambiente agora está pronto e configurado para a execução dos experimentos de segurança (Nikto, ZAP, SQL Injection, etc.).
