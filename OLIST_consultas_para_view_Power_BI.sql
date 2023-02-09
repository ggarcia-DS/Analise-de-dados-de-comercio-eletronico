/*
Este script pretender gerar views adequadas para análises e visualizações em Power BI.
As perguntas que se pretende responder são:

1) Quantos produtos foram vendidos?
2) Qual a receita total?
3) Qual é o preço médio dos produtos vendidos?
4) Qual é o tempo médio de entrega de produtos?
5) Qual a nota média das vendas?
6) Como as vendas se distribuem ao longo do ano? Há sazonalidade? Há tendências de aumento ou diminuição?
*/
CREATE VIEW vw1 AS 
SELECT
	V.VENDA_ID,
    VI.LOJA_ID,
    VI.PRODUTO_ID,
	VA.AVALIACAO_ID,
	P.CATEGORIA AS CATEGORIA_PRODUTO,
	VI.PRECO AS PRECO_PRODUTO,
    VA.VENDA_NOTA,
    V.MOMENTO_COMPRA,
    V.MOMENTO_APROVAÇAO,
    V.MOMENTO_ENVIO,
    V.MOMENTO_ENTREGA,
    DATEDIFF(V.MOMENTO_ENTREGA, V.MOMENTO_ENVIO) AS TEMPO_ENVIO,
    V.ESTIMATIVA_ENTREGA
FROM vendas V
LEFT JOIN vendas_itens VI
ON V.VENDA_ID = VI.VENDA_ID
LEFT JOIN vendas_avaliacoes VA
ON V.VENDA_ID = VA.VENDA_ID
LEFT JOIN produtos P
ON VI.PRODUTO_ID = P.PRODUTO_ID;

/*
Exportando vw1 como arquivo .csv
*/
SELECT @@secure_file_priv;

SELECT * FROM vw1
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_vw1.CSV'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';



/*
7) Quantas vendas tiveram entregas dentro do prazo e quantas atrasaram?
9) Quantas lojas realizaram vendas?
10) Vendas, receita, produtos vendidos e preço médio de produto por loja? (Somente as 10 lojas com mais vendas)
11) Qual a nota média das vendas por loja? (Somente as 10 lojas com mais vendas)
12) Quais foram as 5 categorias de produtos com maior receita, e qual foi a receita de cada uma?
13) Quais foram os métodos de pagamento mais utilizados para compras à vista e para compras parceladas?
14) Quantas vezes cada número de parcelas foi utlizado? 
*/

SELECT * from vw1;
    