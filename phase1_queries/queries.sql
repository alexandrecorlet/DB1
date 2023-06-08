-- @author Alexandre Corlet
-- @matricula 119210883

-- Q1. Quais clientes foram indicados por outros clientes com o mesmo sobrenome que o seu? OK

SELECT cliente_indicado.* FROM CLIENTE cliente, CLIENTE cliente_indicado
WHERE cliente_indicado.cliente_indica = cliente.codcli
    AND cliente.sobrenome = cliente_indicado.sobrenome

/* 
 * Q2. Qual o nome e a descrição dos produtos que estão presentes em compras que o
 * valor total dos produtos (valor atual x quantidade, de cada um) é menor que o valor
 * do frete? OK
 */

SELECT produto.nome, produto.descricao
FROM PRODUTO produto, 
    ORDEM_DE_COMPRA ordem_compra, 
    COMPRA_PRODUTO compra_produto
WHERE produto.codprod = compra_produto.codigo_produto
    AND compra_produto.codigo_compra = ordem_compra.codordem
    AND compra_produto.quantidade * compra_produto.valor_atual < ordem_compra.valor_frete

-- Q3. Recupere o nome dos fornecedores cujo preço médio de compra dos seus
-- produtos não é maior que R$ 163,00. OK

SELECT fornecedor.nome FROM FORNECEDOR fornecedor
WHERE (
    SELECT AVG(produto.preco_compra) FROM PRODUTO produto, FORNECIMENTO fornecimento
    WHERE produto.codprod = fornecimento.codigo_produto
        AND fornecedor.codforn = fornecimento.codigo_fornecedor) <= 163


-- Q4. Qual o nome dos produtos que foram fabricados em 2019, possuem valor de pelo menos 2000 reais
-- e data de vencimento para o ano de 2022 em diante OK

SELECT nome FROM PRODUTO
WHERE EXTRACT(YEAR FROM data_fabricacao) = 2019
    AND preco_venda >= 2000
    AND EXTRACT(YEAR FROM data_validade) >= 2022

-- Q5. Qual cliente indicou a maior quantidade de clientes? OK

-- SOLUCAO 01
WITH INDICACAO AS (
    SELECT cliente_indica, COUNT(*) AS numero_indicacoes
    FROM CLIENTE
    WHERE cliente_indica IS NOT NULL
    GROUP BY cliente_indica
)
SELECT cliente.*, indicacao.numero_indicacoes
FROM CLIENTE cliente, INDICACAO indicacao
WHERE cliente.codcli = indicacao.cliente_indica
    AND indicacao.numero_indicacoes = (
        SELECT MAX(numero_indicacoes) FROM Indicacao
    )

-- SOLUCAO 02
SELECT cliente.codcli, cliente.nome
FROM CLIENTE cliente, CLIENTE indicado
WHERE cliente.codcli = indicado.cliente_indica
GROUP BY cliente.nome, cliente.codcli
HAVING COUNT(*) = (
    SELECT MAX(quantidade_indicacoes)
    FROM (
        SELECT COUNT(*) as quantidade_indicacoes
        FROM CLIENTE
        WHERE cliente_indica IS NOT NULL
        GROUP BY cliente_indica
    )
)

/*
 * Q6. Liste, para cada cidade, quantas ordens de compras foram efetuadas no mês de
 * dezembro de 2021. Caso nenhuma compra tenha sido efetuada nesse mês, exiba 0
 * para aquela cidade.
 */

SELECT ordem_compra.end_cidade, COUNT(*) AS compras_efetuadas
FROM Ordem_De_Compra ordem_compra
WHERE EXTRACT(MONTH FROM ordem_compra.data_compra) = 12
    AND EXTRACT(YEAR FROM ordem_compra.data_compra) = 2021
GROUP BY ordem_compra.end_cidade

-- Q7. Quais transportadoras nunca transportaram compras de produtos da categoria ‘Laticínios’?

SELECT *
FROM TRANSPORTADORA transportadora
WHERE codtrans NOT IN (
    SELECT ordem_de_compra.codigo_transportadora
    FROM ORDEM_DE_COMPRA ordem_de_compra, COMPRA_PRODUTO compra_produto, 
        PRODUTO produto, CATEGORIA categoria
    WHERE compra_produto.codigo_compra = ordem_de_compra.codordem
        AND compra_produto.codigo_produto = produto.codprod
        AND produto.cod_categoria = categoria.codcat
        AND categoria.nome = 'Laticínios'
)

-- Q8. Liste os 5 produtos com melhor média de avaliação

SELECT produto.*
FROM PRODUTO produto, COMPRA_AVALIA_PRODUTO avaliacao
WHERE produto.codprod = avaliacao.codigo_produto
GROUP BY produto.nome, produto.codprod
ORDER BY AVG(avaliacao.nota) DESC
FETCH FIRST 5 ROWS ONLY

/* 10 - Qual categoria possui o produto com maior diferenca percentual entre preço de
 * compra e preço de venda? (Considere que o preço de compra é sempre menor que o
 * preço de venda)
 */

-- SOLUCAO 01:
WITH PRODUTO_DIFERENCA_PERCENTUAL AS (
    SELECT codprod, nome, cod_categoria, (preco_venda - preco_compra) / preco_venda AS diferenca_percentual
    FROM PRODUTO
)
SELECT categoria.*
FROM CATEGORIA categoria, 
    PRODUTO_DIFERENCA_PERCENTUAL produto_diferenca_percentual
WHERE categoria.codcat = produto_diferenca_percentual.cod_categoria
    AND produto_diferenca_percentual.diferenca_percentual = (
        SELECT MAX(diferenca_percentual) FROM PRODUTO_DIFERENCA_PERCENTUAL
    )

-- SOLUCAO 02:
WITH PRODUTO_DIFERENCA_PERCENTUAL AS (
    SELECT codprod, nome, cod_categoria, (preco_venda - preco_compra) / preco_venda AS diferenca_percentual,
        RANK() OVER (ORDER BY (preco_venda - preco_compra) / preco_venda DESC) AS ranking
    FROM PRODUTO
)
SELECT categoria.* 
FROM CATEGORIA categoria, PRODUTO_DIFERENCA_PERCENTUAL produto_diferenca_percentual
WHERE produto_diferenca_percentual.ranking = 1
    AND categoria.codcat = produto_diferenca_percentual.cod_categoria

