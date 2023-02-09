/* Criando o banco de dados "olist" */
CREATE SCHEMA olist;

/* Selecionando o banco de dados "olist" para ser utilizado */
USE olist;

/* Criando todas as tableas do banco de dados com chave primária */
CREATE TABLE vendas
(VENDA_ID VARCHAR (100) PRIMARY KEY NOT NULL,
CLIENTE_ID VARCHAR (100) NOT NULL,
VENDA_STATUS VARCHAR (50),
MOMENTO_COMPRA TIMESTAMP,
MOMENTO_APROVAÇAO TIMESTAMP,
MOMENTO_ENVIO TIMESTAMP,
MOMENTO_ENTREGA TIMESTAMP,
ESTIMATIVA_ENTREGA TIMESTAMP);

CREATE TABLE clientes
(CLIENTE_ID VARCHAR (100) PRIMARY KEY NOT NULL,
CLIENTE_UNIQ_ID VARCHAR (100) NOT NULL,
CLIENTE_PREFIXO_CEP VARCHAR (10),
CLIENTE_CIDADE VARCHAR (30),
CLIENTE_ESTADO CHAR (2));

CREATE TABLE lojas
(LOJA_ID VARCHAR (100) PRIMARY KEY NOT NULL,
LOJA_PREFIXO_CEP VARCHAR (10),
LOJA_CIDADE VARCHAR (70),
LOJA_ESTADO CHAR (2));

CREATE TABLE produtos
(PRODUTO_ID VARCHAR (100) PRIMARY KEY NOT NULL,
CATEGORIA VARCHAR (100),
NOME_COMP INT,
DESCRICAO_COMP INT,
N_FOTOS INT,
PESO_G INT,
COMPRIMENTO_CM INT,
ALTURA_CM INT,
LARGURA_CM INT);

CREATE TABLE vendas_itens
(VENDA_ID VARCHAR (100) PRIMARY KEY NOT NULL,
N_ITEM_NA_COMPRA INT,
PRODUTO_ID VARCHAR (100) NOT NULL,
LOJA_ID VARCHAR (100) NOT NULL,
DATA_LIMITE_ENVIO TIMESTAMP,
PRECO FLOAT,
FRETE FLOAT);

CREATE TABLE vendas_pagamentos
(VENDA_ID VARCHAR (100) PRIMARY KEY NOT NULL,
SEQUENCIA_PAGAMENTO INT,
METODO_PAGAMENTO VARCHAR (25),
N_PARCELAS INT,
VALOR_PAGO FLOAT);

CREATE TABLE vendas_avaliacoes
(AVALIACAO_ID VARCHAR (100) PRIMARY KEY,
VENDA_ID VARCHAR(100),
VENDA_NOTA INT,
COMENT_TITULO VARCHAR (100),
COMENTARIO VARCHAR (500),
DATA_AVALIACAO TIMESTAMP,
DATA_RESPOSTA TIMESTAMP);

/* Alterando as tabelas para adição de chaves estrangeiras */
ALTER TABLE vendas
ADD FOREIGN KEY (CLIENTE_ID) REFERENCES clientes(CLIENTE_ID);

ALTER TABLE vendas_itens
ADD FOREIGN KEY (VENDA_ID) REFERENCES vendas(VENDA_ID);

ALTER TABLE vendas_itens
ADD FOREIGN KEY (PRODUTO_ID) REFERENCES produtos(PRODUTO_ID);

ALTER TABLE vendas_itens
ADD FOREIGN KEY (LOJA_ID) REFERENCES lojas(LOJA_ID);

ALTER TABLE vendas_pagamentos
ADD FOREIGN KEY (VENDA_ID) REFERENCES vendas(VENDA_ID);

ALTER TABLE vendas_avaliacoes
ADD FOREIGN KEY (VENDA_ID) REFERENCES vendas(VENDA_ID);

/* Comandos para permitir carregamento de arquivo .csv usando LOAD DATA LOCA */
SHOW GLOBAL VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile=true;
/* Depois o termo 'OPT_LOCAL_INFILE=1' foi addicionado em 'Edit connection/Advanced/Others' */

/* Carregando arquivo .csv para tabelas */
LOAD DATA LOCAL INFILE '/Users/Gabriel Garcia/OneDrive/Documents/Portfolio/E-commerce-SQL-POWER_BI/Olist-public-data-transactions/Orders-data/upload/dados_lojas.CSV'
INTO TABLE lojas
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(LOJA_ID, LOJA_PREFIXO_CEP, LOJA_CIDADE, LOJA_ESTADO);

/* Comandos para visualizar e confirmar sucesso do carregamento */
SELECT COUNT(*) FROM lojas;
SELECT * FROM lojas LIMIT 5;
DELETE from lojas;

/* Comandos para visualizar dados errôneos de cidade (contendo barra e estado)
Dados foram tratados com Power Query em excel e depois recarregados na tabela */
SELECT DISTINCT LOJA_CIDADE FROM lojas
WHERE LOJA_CIDADE LIKE '%/%'
ORDER BY LOJA_CIDADE ASC;


LOAD DATA LOCAL INFILE '/Users/Gabriel Garcia/OneDrive/Documents/Portfolio/E-commerce-SQL-POWER_BI/Olist-public-data-transactions/Orders-data/olist_products_dataset.CSV'
INTO TABLE produtos
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(PRODUTO_ID, CATEGORIA, NOME_COMP, DESCRICAO_COMP, N_FOTOS, PESO_G, COMPRIMENTO_CM, ALTURA_CM, LARGURA_CM);

/* Comandos para visualizar e confirmar sucesso do carregamento */
SELECT COUNT(*) FROM produtos;
SELECT * FROM produtos LIMIT 5;
SELECT DISTINCT CATEGORIA FROM PRODUTOS WHERE CATEGORIA LIKE '%FERRAMENTAS%' ORDER BY CATEGORIA ASC; /* Possível redundância de categorias */
SELECT sum(peso_g) FROM produtos;

LOAD DATA LOCAL INFILE '/Users/Gabriel Garcia/OneDrive/Documents/Portfolio/E-commerce-SQL-POWER_BI/Olist-public-data-transactions/Orders-data/UPLOAD/dados_clientes.CSV'
INTO TABLE clientes
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(CLIENTE_ID, CLIENTE_UNIQ_ID, CLIENTE_PREFIXO_CEP, CLIENTE_CIDADE, CLIENTE_ESTADO);
/* Mensagem de que um nome de cidade foi truncado */

/* Comandos para alterar número de caracteres de CLIENTE_CIDADE
e recarregar dados na tabela clientes */
ALTER TABLE clientes MODIFY COLUMN CLIENTE_CIDADE VARCHAR(50);
DELETE from clientes;

LOAD DATA LOCAL INFILE '/Users/Gabriel Garcia/OneDrive/Documents/Portfolio/E-commerce-SQL-POWER_BI/Olist-public-data-transactions/Orders-data/olist_products_dataset.CSV'
INTO TABLE produtos
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(PRODUTO_ID, CATEGORIA, NOME_COMP, DESCRICAO_COMP, N_FOTOS, PESO_G, COMPRIMENTO_CM, ALTURA_CM, LARGURA_CM);

LOAD DATA LOCAL INFILE '/Users/Gabriel Garcia/OneDrive/Documents/Portfolio/E-commerce-SQL-POWER_BI/Olist-public-data-transactions/Orders-data/olist_orders_dataset.CSV'
INTO TABLE vendas
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(VENDA_ID, CLIENTE_ID, VENDA_STATUS, MOMENTO_COMPRA, MOMENTO_APROVAÇAO, MOMENTO_ENVIO, MOMENTO_ENTREGA, ESTIMATIVA_ENTREGA);

LOAD DATA LOCAL INFILE '/Users/Gabriel Garcia/OneDrive/Documents/Portfolio/E-commerce-SQL-POWER_BI/Olist-public-data-transactions/Orders-data/olist_order_payments_dataset.CSV'
INTO TABLE vendas_pagamentos
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(VENDA_ID, SEQUENCIA_PAGAMENTO, METODO_PAGAMENTO, N_PARCELAS, VALOR_PAGO);

/* ConfirmandO ausência de valores duplicados em VENDA_ID */
SELECT VENDA_ID, COUNT(*) C FROM vendas_pagamentos
GROUP BY VENDA_ID HAVING C > 1;

LOAD DATA LOCAL INFILE '/Users/Gabriel Garcia/OneDrive/Documents/Portfolio/E-commerce-SQL-POWER_BI/Olist-public-data-transactions/Orders-data/olist_order_reviews_dataset.CSV'
INTO TABLE vendas_avaliacoes
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(AVALIACAO_ID, VENDA_ID, VENDA_NOTA, COMENT_TITULO, COMENTARIO, DATA_AVALIACAO, DATA_RESPOSTA);

SELECT * FROM vendas_avaliacoes LIMIT 100, 10;

LOAD DATA LOCAL INFILE '/Users/Gabriel Garcia/OneDrive/Documents/Portfolio/E-commerce-SQL-POWER_BI/Olist-public-data-transactions/Orders-data/olist_order_items_dataset.CSV'
INTO TABLE vendas_itens
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(VENDA_ID, N_ITEM_NA_COMPRA, PRODUTO_ID, LOJA_ID, DATA_LIMITE_ENVIO, PRECO, FRETE);

/* Confirmando ausência de valores duplicados em VENDA_ID */
SELECT VENDA_ID, COUNT(*) C FROM vendas_itens
GROUP BY VENDA_ID HAVING C > 1;