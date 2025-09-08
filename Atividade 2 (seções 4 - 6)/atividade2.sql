/* 5SBD - ATIVIDADE 2*/

/* 
1. Exiba os nomes dos clientes com todas as letras em maiúsculas. 
*/
SELECT UPPER(cliente_nome) AS nome_maiusculo
FROM cliente;

/* 
2. Exiba os nomes dos clientes formatados com apenas a primeira letra maiúscula. 
*/
SELECT INITCAP(cliente_nome) AS nome_formatado
FROM cliente;

/* 
3. Mostre as três primeiras letras do nome de cada cliente. 
*/
SELECT SUBSTR(cliente_nome, 1, 3) AS iniciais
FROM cliente;

/* 
4. Exiba o número de caracteres do nome de cada cliente. 
*/
SELECT cliente_nome, LENGTH(cliente_nome) AS qtd_caracteres
FROM cliente;

/* 
5. Apresente o saldo de todas as contas, arredondado para o inteiro mais próximo. 
*/
SELECT conta_numero, ROUND(saldo) AS saldo_arredondado
FROM conta;

/* 
6. Exiba o saldo truncado, sem casas decimais. 
*/
SELECT conta_numero, TRUNC(saldo) AS saldo_truncado
FROM conta;

/* 
7. Mostre o resto da divisão do saldo da conta por 1000. 
*/
SELECT conta_numero, MOD(saldo, 1000) AS resto_divisao
FROM conta;

/* 
8. Exiba a data atual do servidor do banco. 
*/
SELECT SYSDATE AS data_atual
FROM dual;

/* 
9. Adicione 30 dias à data atual e exiba como "Data de vencimento simulada". 
*/
SELECT SYSDATE + 30 AS "Data de vencimento simulada"
FROM dual;

/* 
10. Exiba o número de dias entre a data de abertura da conta e a data atual. 
(Considerando que exista a coluna data_abertura em conta)
*/
SELECT conta_numero, (SYSDATE - data_abertura) AS dias_desde_abertura
FROM conta;

/* 
11. Apresente o saldo de cada conta formatado como moeda local. 
*/
SELECT conta_numero, TO_CHAR(saldo, 'L999G999D99') AS saldo_formatado
FROM conta;

/* 
12. Converta a data de abertura da conta para o formato 'dd/mm/yyyy'. 
(Considerando que exista a coluna data_abertura em conta)
*/
SELECT conta_numero, TO_CHAR(data_abertura, 'dd/mm/yyyy') AS data_formatada
FROM conta;

/* 
13. Exiba o saldo da conta e substitua valores nulos por 0. 
*/
SELECT conta_numero, NVL(saldo, 0) AS saldo_corrigido
FROM conta;

/* 
14. Exiba os nomes dos clientes e substitua valores nulos na cidade por 'Sem cidade'. 
*/
SELECT cliente_nome, NVL(cidade, 'Sem cidade') AS cidade_corrigida
FROM cliente;

/* 
15. Classifique os clientes em grupos com base em sua cidade: 
   - 'Região Metropolitana' se forem de Niterói 
   - 'Interior' se forem de Resende 
   - 'Outra Região' para as demais cidades 
*/
SELECT cliente_nome,
       CASE 
           WHEN cidade = 'Niterói' THEN 'Região Metropolitana'
           WHEN cidade = 'Resende' THEN 'Interior'
           ELSE 'Outra Região'
       END AS classificacao
FROM cliente;

/* 
16. Exiba o nome de cada cliente, o número da conta e o saldo correspondente. 
*/
SELECT c.cliente_nome, ct.conta_numero, ct.saldo
FROM cliente c
JOIN conta ct ON c.cliente_cod = ct.cliente_cliente_cod;

/* 
17. Liste os nomes dos clientes e os nomes das agências onde mantêm conta. 
*/
SELECT c.cliente_nome, a.agencia_nome
FROM cliente c
JOIN conta ct ON c.cliente_cod = ct.cliente_cliente_cod
JOIN agencia a ON ct.agencia_agencia_cod = a.agencia_cod;

/* 
18. Mostre todas as agências, mesmo aquelas que não possuem clientes vinculados 
   (junção externa esquerda). 
*/
SELECT a.agencia_nome, c.cliente_nome
FROM agencia a
LEFT JOIN conta ct ON a.agencia_cod = ct.agencia_agencia_cod
LEFT JOIN cliente c ON c.cliente_cod = ct.cliente_cliente_cod;
