/*
Este script pretender responder à uma série de perguntas de negócio (indicadas abaixo)
efetuando consultas em SQL ao banco de dados 'olist'.

As perguntas são:
1) Qual o número total de vendas realizadas?
2) Quantos produtos foram vendidos?
3) Qual a receita total?
4) Qual é o preço médio dos produtos vendidos?
5) Qual a nota média das vendas?
6) Qual é o tempo médio de entrega de produtos?
7) Quantas vendas tiveram entregas dentro do prazo e quantas atrasaram?
8) Quais as dez lojas com maior tempo médio de envio? E as 10 lojas com menor tempo médio de envio? Indicar tempo médio.
9) Como as vendas se distribuem ao longo do ano? Há sazonalidade? Há tendências de aumento ou diminuição?
10) Quantas lojas realizaram vendas?
11) Vendas, receita, produtos vendidos e preço médio de produto por loja? (Somente as 10 lojas com mais vendas)
12) Qual a nota média das vendas por loja? (Somente as 10 lojas com mais vendas)
13) Quais foram as 5 categorias de produtos com maior receita, e qual foi a receita de cada uma?
14) Quais foram os métodos de pagamento mais utilizados para compras à vista e para compras parceladas?
15) Quantas vezes cada número de parcelas foi utlizado? 
*/

/*
1) Qual o número total de vendas realizadas?
*/
SELECT COUNT(DISTINCT VENDA_ID) AS total_vendas FROM vendas;

/*
2) Quantos produtos foram vendidos?
3) Qual a receita total?
4) Qual é o preço médio dos produtos vendidos?
*/
SELECT total_produtos, receita, ROUND((receita / total_produtos), 2) AS preco_medio
FROM (SELECT COUNT(PRODUTO_ID) AS total_produtos, ROUND(SUM(PRECO), 2) AS receita
FROM vendas_itens) R2a4;
/* Número de produtos vendidos foi menor que o número total de vendas. Investigar... */

/*
5) Qual a nota média das vendas?
*/
SELECT ROUND(AVG(VENDA_NOTA), 1) AS nota_media FROM vendas_avaliacoes;

/*
6) Qual é o tempo médio de entrega de produtos?
*/
SELECT CONVERT(AVG(TEMPO_ENTREGA), UNSIGNED) AS TEMPO_MEDIO_ENTREGA_dias
FROM (SELECT datediff(MOMENTO_ENTREGA, MOMENTO_ENVIO) AS TEMPO_ENTREGA FROM vendas) R6;

/*
7) Quantas vendas tiveram entregas dentro do prazo e quantas atrasaram?
*/
SELECT
	CASE
		WHEN MOMENTO_ENTREGA > ESTIMATIVA_ENTREGA THEN 'Atrasada'
        ELSE 'No prazo'
	END AS status_entrega,
    COUNT(VENDA_ID) AS n_vendas
    FROM vendas
    GROUP BY status_entrega;
    
/*
8) Quais são as dez lojas com maior tempo médio de envio? E as 10 lojas com maior tempo médio de envio? Indicar o tempo
médio de envio de cada loja.
*/
SELECT * FROM (SELECT
	LOJA_ID,
    ROUND(AVG(TEMPO_ENVIO), 1) AS TEMPO_ENVIO_MEDIO
FROM
	(SELECT
		LOJA_ID,
		TEMPO_ENVIO
	FROM
		(SELECT
			V.VENDA_ID,
			VI.LOJA_ID,
			DATEDIFF(V.MOMENTO_ENVIO, V.MOMENTO_APROVAÇAO) AS TEMPO_ENVIO
		FROM vendas V
		LEFT JOIN vendas_itens VI
		ON V.VENDA_ID = VI.VENDA_ID) R8a
	WHERE TEMPO_ENVIO > 0) R8b
GROUP BY LOJA_ID
ORDER BY TEMPO_ENVIO_MEDIO ASC
LIMIT 10) R8c
UNION
SELECT * FROM (SELECT
	LOJA_ID,
    ROUND(AVG(TEMPO_ENVIO), 1) AS TEMPO_ENVIO_MEDIO
FROM
	(SELECT
		LOJA_ID,
		TEMPO_ENVIO
	FROM
		(SELECT
			V.VENDA_ID,
			VI.LOJA_ID,
			DATEDIFF(V.MOMENTO_ENVIO, V.MOMENTO_APROVAÇAO) AS TEMPO_ENVIO
		FROM vendas V
		LEFT JOIN vendas_itens VI
		ON V.VENDA_ID = VI.VENDA_ID) R8a
	WHERE TEMPO_ENVIO > 0) R8b
GROUP BY LOJA_ID
ORDER BY TEMPO_ENVIO_MEDIO DESC
LIMIT 10) R8d
ORDER BY TEMPO_ENVIO_MEDIO DESC;
    

/*
9) Como as vendas se distribuem ao longo do ano? Há sazonalidade? Há tendências de aumento ou diminuição?
R: calculando vendas mensais para todo o perído - sazonalidade e tendência se observarão graficamente no Power BI
*/
SELECT
	YEAR(MOMENTO_COMPRA) AS ANO,
    MONTH(MOMENTO_COMPRA) AS MES,
    COUNT(VENDA_ID) AS total_vendas
FROM vendas
GROUP BY ANO, MES
ORDER BY ANO, MES ASC;

/*
10) Quantas lojas realizaram vendas?
*/
SELECT COUNT(DISTINCT LOJA_ID) AS total_lojas FROM vendas_itens;

/*
11) Vendas, receita, produtos vendidos e preço médio de produto por loja? (Somente as 10 lojas com mais vendas)
*/
SELECT
	LOJA_ID,
    total_vendas,
    receita,
    total_produtos,
    ROUND((receita / total_produtos), 2) AS preco_medio
    FROM
		(SELECT
			LOJA_ID,
			COUNT(DISTINCT VENDA_ID) AS total_vendas,
			ROUND(SUM(PRECO), 2) AS receita,
			COUNT(PRODUTO_ID) AS total_produtos
		FROM vendas_itens
		GROUP BY LOJA_ID) R9
	ORDER BY total_vendas DESC
	LIMIT 10;
    
/*
12) Qual a nota média das vendas cada loja? (Somente as 10 lojas com mais vendas)
*/
SELECT
	LOJA_ID,
    COUNT(DISTINCT VENDA_ID) AS total_vendas,
    ROUND(AVG(VENDA_NOTA), 1) AS nota_media
FROM
	(SELECT
		VI.LOJA_ID,
        VI.VENDA_ID,
		VA.VENDA_NOTA
	FROM vendas_itens VI
	LEFT JOIN vendas_avaliacoes VA
	ON VI.VENDA_ID = VA.VENDA_ID) R10
GROUP BY LOJA_ID
ORDER BY total_vendas DESC
LIMIT 10;

/*
13) Quais foram as 5 categorias de produtos com maior receita, e qual foi a receita de cada uma?
*/
SELECT
	CATEGORIA,
    ROUND(SUM(PRECO), 2) AS receita
FROM
	(SELECT
		UPPER(P.CATEGORIA) AS CATEGORIA,
		VI.PRECO
	FROM produtos P
	RIGHT JOIN vendas_itens VI
	ON P.PRODUTO_ID = VI.PRODUTO_ID) R12
    GROUP BY CATEGORIA
    ORDER BY receita DESC
    LIMIT 5;
    
/*
14) Quais foram os métodos de pagamento mais utilizados para compras à vista e para compras parceladas?
*/
SELECT
	CASE
		WHEN N_PARCELAS > 1 THEN 'Parcelada'
        ELSE 'À vista'
	END AS tipo_venda, METODO_PAGAMENTO, COUNT(VENDA_ID)
FROM vendas_pagamentos
GROUP BY tipo_venda, METODO_PAGAMENTO
ORDER BY tipo_venda, METODO_PAGAMENTO; 

/*
15) Quantas vezes cada número de parcelas foi utlizado?
*/

SELECT
	N_PARCELAS,
	COUNT(VENDA_ID) AS total_vendas
FROM vendas_pagamentos
GROUP BY N_PARCELAS HAVING N_PARCELAS > 1
ORDER BY total_vendas DESC;