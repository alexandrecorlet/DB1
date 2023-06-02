-- @author Alexandre Corlet
-- @matricula 119210883

-- Q1. Quais clientes foram indicados por outros clientes com o mesmo sobrenome que o seu? OK

SELECT cliente_indicado.* FROM Cliente cliente, Cliente cliente_indicado
WHERE cliente.sobrenome = cliente_indicado.sobrenome

-- Q3. Recupere o nome dos fornecedores cujo preço médio de compra dos seus
-- produtos não é maior que R$ 163,00.

SELECT fornecedor.nome FROM Fornecedor fornecedor
WHERE (
    SELECT AVG(preco_compra) FROM Produto produto, Fornecimento fornecimento
    WHERE produto.codprod = fornecimento.codigo_produto
        AND fornecedor.codforn = fornecimento.codigo_fornecedor) < 163

-- Q4. Qual o nome dos produtos que foram fabricados em 2019, possuem valor de pelo menos 2000 reais
-- e data de vencimento para o ano de 2022 em diante

SELECT nome FROM Produto
WHERE EXTRACT(YEAR FROM data_fabricacao) = 2019
    AND preco_venda >= 2000
    AND EXTRACT(YEAR FROM data_validade) >= 2022
