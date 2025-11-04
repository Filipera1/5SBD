/* ==========================================================
   SEÇÃO 12 – CONVERSÕES IMPLÍCITAS E EXPLÍCITAS
========================================================== */

/* 1. Exiba o número da conta e o saldo formatado com separador de milhar e vírgula como separador decimal. */
SELECT conta_numero, TO_CHAR(saldo, '999G999G999D99') AS saldo_formatado
FROM conta;

/* 2. Mostre a data atual no formato 'DD/MM/YYYY'. */
SELECT TO_CHAR(SYSDATE, 'DD/MM/YYYY') AS data_atual_formatada
FROM dual;

/* 3. Exiba o nome do cliente concatenado com a cidade onde ele reside. */
SELECT cliente_nome || ' - ' || cidade AS cliente_e_cidade
FROM cliente;

/* 4. Liste os empréstimos com valor superior a R$ 5000, formatando o valor com símbolo monetário. */
SELECT emprestimo_numero, 
       TO_CHAR(quantia, 'L999G999D99') AS valor_formatado
FROM emprestimo
WHERE quantia > 5000;


/* ==========================================================
   SEÇÃO 13 – TIPOS DE DADOS AVANÇADOS
========================================================== */

/* 5. Adicione uma coluna do tipo TIMESTAMP na tabela cliente chamada data_cadastro. */
ALTER TABLE cliente ADD (data_cadastro TIMESTAMP);

/* (Exemplo opcional de preenchimento com a data atual) */
UPDATE cliente SET data_cadastro = SYSTIMESTAMP;

/* 6. Mostre quantos dias se passaram desde o cadastro de cada cliente. */
SELECT cliente_nome, 
       ROUND(SYSDATE - data_cadastro) AS dias_desde_cadastro
FROM cliente;

/* 7. Adicione uma coluna do tipo INTERVAL YEAR TO MONTH na tabela cliente chamada tempo_fidelidade. */
ALTER TABLE cliente ADD (tempo_fidelidade INTERVAL YEAR TO MONTH);

/* (Exemplo de atualização do tempo de fidelidade) */
UPDATE cliente SET tempo_fidelidade = INTERVAL '2' YEAR; -- exemplo genérico

/* 8. Exiba para cada cliente a data de cadastro e uma previsão de renovação de cadastro adicionando 3 meses. */
SELECT cliente_nome, 
       data_cadastro, 
       ADD_MONTHS(data_cadastro, 3) AS renovacao_prevista
FROM cliente;


/* ==========================================================
   SEÇÃO 14 – CONSTRAINTS
========================================================== */

/* 9. Crie uma tabela chamada cartao_credito com as seguintes restrições:
   - cartao_numero (PK)
   - cliente_cod (FK)
   - limite_credito (NOT NULL)
   - status (CHECK: 'ATIVO', 'BLOQUEADO', 'CANCELADO')
*/
CREATE TABLE cartao_credito (
    cartao_numero     NUMBER PRIMARY KEY,
    cliente_cod       NUMBER REFERENCES cliente(cliente_cod),
    limite_credito    NUMBER(10,2) NOT NULL,
    status            VARCHAR2(15) CHECK (status IN ('ATIVO', 'BLOQUEADO', 'CANCELADO'))
);

/* 10. Tente inserir um cartão de crédito com campo limite_credito nulo (explique o erro). */
INSERT INTO cartao_credito (cartao_numero, cliente_cod, limite_credito, status)
VALUES (1, 1, NULL, 'ATIVO');

/*
   ❌ ERRO: ORA-01400: cannot insert NULL into ("LIMITE_CREDITO")
   → Ocorre porque a coluna possui a restrição NOT NULL, que impede valores nulos.
*/

/* 11. Insira ao menos três registros válidos na tabela cartao_credito. */
INSERT INTO cartao_credito (cartao_numero, cliente_cod, limite_credito, status)
VALUES (2, 1, 5000, 'ATIVO');

INSERT INTO cartao_credito (cartao_numero, cliente_cod, limite_credito, status)
VALUES (3, 2, 8000, 'BLOQUEADO');

INSERT INTO cartao_credito (cartao_numero, cliente_cod, limite_credito, status)
VALUES (4, 3, 12000, 'ATIVO');

/* 12. Crie uma tabela transacao com restrição CHECK para valores positivos. */
CREATE TABLE transacao (
    transacao_id NUMBER PRIMARY KEY,
    valor        NUMBER(10,2) CHECK (valor > 0),
    data_transacao DATE DEFAULT SYSDATE
);

/* 13. Tente inserir uma transação com valor negativo (explique o erro). */
INSERT INTO transacao (transacao_id, valor)
VALUES (1, -500);

/*
   ❌ ERRO: ORA-02290: check constraint violated
   → A restrição CHECK impede valores negativos na coluna "valor".
*/

/* 14. Crie uma consulta que relacione clientes ativos com seus respectivos limites de crédito acima de 3000. */
SELECT c.cliente_nome, c.cidade, cc.limite_credito
FROM cliente c
JOIN cartao_credito cc ON c.cliente_cod = cc.cliente_cod
WHERE cc.status = 'ATIVO' AND cc.limite_credito > 3000;

/* 15. Crie uma VIEW chamada vw_clientes_com_cartao que exiba nome, cidade e status do cartão. */
CREATE OR REPLACE VIEW vw_clientes_com_cartao AS
SELECT c.cliente_nome, c.cidade, cc.status
FROM cliente c
JOIN cartao_credito cc ON c.cliente_cod = cc.cliente_cod;

/* (Visualizando o conteúdo da VIEW) */
SELECT * FROM vw_clientes_com_cartao;
