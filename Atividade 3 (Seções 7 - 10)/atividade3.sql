/* ==========================================================
   SEÇÃO 7 – JUNÇÕES E PRODUTO CARTESIANO
========================================================== */

/* 1. Usando a sintaxe proprietária da Oracle, exiba o nome de cada cliente junto com o número de sua conta. */
SELECT c.cliente_nome, ct.conta_numero
FROM cliente c, conta ct
WHERE c.cliente_cod = ct.cliente_cliente_cod;

/* 2. Mostre todas as combinações possíveis de clientes e agências (produto cartesiano). */
SELECT c.cliente_nome, a.agencia_nome
FROM cliente c, agencia a;

/* 3. Usando aliases de tabela, exiba o nome dos clientes e a cidade da agência onde mantêm conta. */
SELECT c.cliente_nome, a.agencia_cidade
FROM cliente c
JOIN conta ct ON c.cliente_cod = ct.cliente_cliente_cod
JOIN agencia a ON ct.agencia_agencia_cod = a.agencia_cod;


/* ==========================================================
   SEÇÃO 8 – FUNÇÕES DE GRUPO, COUNT, DISTINCT E NVL
========================================================== */

/* 4. Exiba o saldo total de todas as contas cadastradas. */
SELECT SUM(saldo) AS saldo_total
FROM conta;

/* 5. Mostre o maior saldo e a média de saldo entre todas as contas. */
SELECT MAX(saldo) AS maior_saldo, AVG(saldo) AS media_saldo
FROM conta;

/* 6. Apresente a quantidade total de contas cadastradas. */
SELECT COUNT(*) AS qtd_contas
FROM conta;

/* 7. Liste o número de cidades distintas onde os clientes residem. */
SELECT COUNT(DISTINCT cidade) AS qtd_cidades
FROM cliente;

/* 8. Exiba o número da conta e o saldo, substituindo valores nulos por zero. */
SELECT conta_numero, NVL(saldo, 0) AS saldo_corrigido
FROM conta;


/* ==========================================================
   SEÇÃO 9 – GROUP BY, HAVING, ROLLUP E OPERADORES DE CONJUNTO
========================================================== */

/* 9. Exiba a média de saldo por cidade dos clientes. */
SELECT c.cidade, AVG(ct.saldo) AS media_saldo
FROM cliente c
JOIN conta ct ON c.cliente_cod = ct.cliente_cliente_cod
GROUP BY c.cidade;

/* 10. Liste apenas as cidades com mais de 3 contas associadas a seus moradores. */
SELECT c.cidade, COUNT(ct.conta_numero) AS qtd_contas
FROM cliente c
JOIN conta ct ON c.cliente_cod = ct.cliente_cliente_cod
GROUP BY c.cidade
HAVING COUNT(ct.conta_numero) > 3;

/* 11. Utilize a cláusula ROLLUP para exibir o total de saldos por cidade da agência e o total geral. */
SELECT a.agencia_cidade, SUM(ct.saldo) AS total_saldo
FROM agencia a
JOIN conta ct ON a.agencia_cod = ct.agencia_agencia_cod
GROUP BY ROLLUP(a.agencia_cidade);

/* 12. Faça uma consulta com UNION que combine os nomes de cidades dos clientes e das agências, sem repetições. */
SELECT cidade FROM cliente
UNION
SELECT agencia_cidade FROM agencia;


/* ==========================================================
   SEÇÃO 10 – SUBCONSULTAS
========================================================== */

/* 1. Liste os nomes dos clientes cujas contas possuem saldo acima da média geral de todas as contas registradas. */
SELECT c.cliente_nome, ct.saldo
FROM cliente c
JOIN conta ct ON c.cliente_cod = ct.cliente_cliente_cod
WHERE ct.saldo > (SELECT AVG(saldo) FROM conta);

/* 2. Exiba os nomes dos clientes cujos saldos são iguais ao maior saldo encontrado no banco. */
SELECT c.cliente_nome, ct.saldo
FROM cliente c
JOIN conta ct ON c.cliente_cod = ct.cliente_cliente_cod
WHERE ct.saldo = (SELECT MAX(saldo) FROM conta);

/* 3. Liste as cidades onde a quantidade de clientes é maior que a quantidade média de clientes por cidade. */
SELECT cidade
FROM cliente
GROUP BY cidade
HAVING COUNT(*) > (
    SELECT AVG(qtd) 
    FROM (SELECT COUNT(*) AS qtd FROM cliente GROUP BY cidade)
);

/* 4. Liste os nomes dos clientes com saldo igual a qualquer um dos dez maiores saldos registrados. */
SELECT c.cliente_nome, ct.saldo
FROM cliente c
JOIN conta ct ON c.cliente_cod = ct.cliente_cliente_cod
WHERE ct.saldo IN (
    SELECT saldo FROM (
        SELECT saldo FROM conta ORDER BY saldo DESC
    ) WHERE ROWNUM <= 10
);

/* 5. Liste os clientes que possuem saldo menor que todos os saldos dos clientes da cidade de Niterói. */
SELECT c.cliente_nome, ct.saldo
FROM cliente c
JOIN conta ct ON c.cliente_cod = ct.cliente_cliente_cod
WHERE ct.saldo < ALL (
    SELECT ct2.saldo
    FROM conta ct2
    JOIN cliente c2 ON ct2.cliente_cliente_cod = c2.cliente_cod
    WHERE c2.cidade = 'Niterói'
);

/* 6. Liste os clientes cujos saldos estão entre os saldos de clientes de Volta Redonda. */
SELECT c.cliente_nome, ct.saldo
FROM cliente c
JOIN conta ct ON c.cliente_cod = ct.cliente_cliente_cod
WHERE ct.saldo BETWEEN (
    SELECT MIN(ct2.saldo)
    FROM conta ct2
    JOIN cliente c2 ON ct2.cliente_cliente_cod = c2.cliente_cod
    WHERE c2.cidade = 'Volta Redonda'
) AND (
    SELECT MAX(ct2.saldo)
    FROM conta ct2
    JOIN cliente c2 ON ct2.cliente_cliente_cod = c2.cliente_cod
    WHERE c2.cidade = 'Volta Redonda'
);

/* 7. Exiba os nomes dos clientes cujos saldos são maiores que a média de saldo das contas da mesma agência. */
SELECT c.cliente_nome, ct.saldo
FROM cliente c
JOIN conta ct ON c.cliente_cod = ct.cliente_cliente_cod
WHERE ct.saldo > (
    SELECT AVG(ct2.saldo)
    FROM conta ct2
    WHERE ct2.agencia_agencia_cod = ct.agencia_agencia_cod
);

/* 8. Liste os nomes e cidades dos clientes que têm saldo inferior à média de sua própria cidade. */
SELECT c.cliente_nome, c.cidade, ct.saldo
FROM cliente c
JOIN conta ct ON c.cliente_cod = ct.cliente_cliente_cod
WHERE ct.saldo < (
    SELECT AVG(ct2.saldo)
    FROM conta ct2
    JOIN cliente c2 ON ct2.cliente_cliente_cod = c2.cliente_cod
    WHERE c2.cidade = c.cidade
);

/* 9. Liste os nomes dos clientes que possuem pelo menos uma conta registrada no banco. */
SELECT c.cliente_nome
FROM cliente c
WHERE EXISTS (
    SELECT 1 FROM conta ct WHERE ct.cliente_cliente_cod = c.cliente_cod
);

/* 10. Liste os nomes dos clientes que ainda não possuem conta registrada no banco. */
SELECT c.cliente_nome
FROM cliente c
WHERE NOT EXISTS (
    SELECT 1 FROM conta ct WHERE ct.cliente_cliente_cod = c.cliente_cod
);

/* 11. Usando a cláusula WITH, calcule a média de saldo por cidade e exiba os clientes que possuem saldo acima da média de sua cidade. */
WITH media_cidade AS (
    SELECT c.cidade, AVG(ct.saldo) AS media_saldo
    FROM cliente c
    JOIN conta ct ON c.cliente_cod = ct.cliente_cliente_cod
    GROUP BY c.cidade
)
SELECT c.cliente_nome, c.cidade, ct.saldo
FROM cliente c
JOIN conta ct ON c.cliente_cod = ct.cliente_cliente_cod
JOIN media_cidade mc ON c.cidade = mc.cidade
WHERE ct.saldo > mc.media_saldo;
