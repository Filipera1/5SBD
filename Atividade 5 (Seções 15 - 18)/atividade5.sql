/* ==========================================================
   SEÇÃO 15 – SEQUÊNCIAS
========================================================== */

/* 1. Crie uma sequência chamada seq_movimento que inicie em 100 e incremente de 10 em 10. */
CREATE SEQUENCE seq_movimento
START WITH 100
INCREMENT BY 10
NOCACHE
NOCYCLE;

/* 2. Crie uma tabela chamada movimento_conta com as colunas:
      movimento_id, conta_numero, tipo (C ou D), valor, data_movimento. */
CREATE TABLE movimento_conta (
    movimento_id   NUMBER PRIMARY KEY,
    conta_numero   NUMBER REFERENCES conta(conta_numero),
    tipo           CHAR(1) CHECK (tipo IN ('C', 'D')),
    valor          NUMBER(10,2) NOT NULL,
    data_movimento DATE DEFAULT SYSDATE
);

/* 3. Insira pelo menos três movimentações diferentes utilizando a sequência seq_movimento. */
INSERT INTO movimento_conta (movimento_id, conta_numero, tipo, valor)
VALUES (seq_movimento.NEXTVAL, 1, 'C', 1500);

INSERT INTO movimento_conta (movimento_id, conta_numero, tipo, valor)
VALUES (seq_movimento.NEXTVAL, 2, 'D', 800);

INSERT INTO movimento_conta (movimento_id, conta_numero, tipo, valor)
VALUES (seq_movimento.NEXTVAL, 3, 'C', 2500);


/* ==========================================================
   SEÇÃO 16 – VIEWS
========================================================== */

/* 4. Crie uma view chamada vw_contas_clientes que exiba o nome do cliente,
      o número da conta, saldo e código da agência. */
CREATE OR REPLACE VIEW vw_contas_clientes AS
SELECT c.cliente_nome, ct.conta_numero, ct.saldo, ct.agencia_agencia_cod
FROM cliente c
JOIN conta ct ON c.cliente_cod = ct.cliente_cliente_cod;

/* 5. Crie uma view chamada vw_emprestimos_grandes que exiba número do empréstimo,
      nome do cliente e valor dos empréstimos acima de R$ 20.000. */
CREATE OR REPLACE VIEW vw_emprestimos_grandes AS
SELECT e.emprestimo_numero, c.cliente_nome, e.quantia
FROM emprestimo e
JOIN cliente c ON e.cliente_cliente_cod = c.cliente_cod
WHERE e.quantia > 20000;

/* 6. Tente fazer um update diretamente na view vw_emprestimos_grandes e observe o que acontece.
   Explique o motivo. */
UPDATE vw_emprestimos_grandes
SET quantia = 1000
WHERE emprestimo_numero = 1;

/*
   ❌ ERRO: ORA-01779: cannot modify a column which maps to a non key-preserved table
   → Isso ocorre porque a view envolve uma junção (JOIN) e filtragem,
     o que a torna não atualizável diretamente.
*/


/* ==========================================================
   SEÇÃO 17 – PRIVILÉGIOS E ROLES
========================================================== */

/* 7. Crie uma role chamada atendente_agencia com privilégios de SELECT em cliente e conta,
      e UPDATE no endereço do cliente. */
CREATE ROLE atendente_agencia;

GRANT SELECT ON cliente TO atendente_agencia;
GRANT SELECT ON conta TO atendente_agencia;
GRANT UPDATE (rua) ON cliente TO atendente_agencia;

/* 8. Conceda essa role ao usuário carla. */
GRANT atendente_agencia TO carla;

/* 9. Revogue da role o privilégio de UPDATE no endereço. */
REVOKE UPDATE ON cliente FROM atendente_agencia;

/* 10. Crie um usuário chamado auditor com privilégios para consultar qualquer view do banco. */
CREATE USER auditor IDENTIFIED BY senha_auditor;

GRANT CREATE SESSION TO auditor;
GRANT SELECT ANY TABLE TO auditor;
GRANT SELECT ANY VIEW TO auditor;


/* ==========================================================
   SEÇÃO 18 – EXPRESSÕES REGULARES
========================================================== */

/* 11. Liste todos os clientes cujo nome começa com 'M' e termina com 'a' (não sensível a maiúsculas/minúsculas). */
SELECT cliente_nome
FROM cliente
WHERE REGEXP_LIKE(cliente_nome, '^M.*a$', 'i');

/* 12. Mascarar os seis primeiros dígitos do CPF, mantendo os últimos três visíveis, para todos os clientes.
   (Considerando que exista a coluna cpf na tabela cliente) */
SELECT cliente_nome,
       REGEXP_REPLACE(cpf, '^[0-9]{6}', 'XXXXXX') AS cpf_mascarado
FROM cliente;

/* 13. Exibir o domínio dos e-mails dos clientes (parte após o @).
   (Considerando que exista a coluna email na tabela cliente) */
SELECT cliente_nome,
       REGEXP_SUBSTR(email, '@.*') AS dominio_email
FROM cliente;

/* 14. Listar clientes com dois ou mais nomes. */
SELECT cliente_nome
FROM cliente
WHERE REGEXP_LIKE(cliente_nome, ' ');

/* 15. Filtrar clientes cujo e-mail termina com '.br'. */
SELECT cliente_nome, email
FROM cliente
WHERE REGEXP_LIKE(email, '\.br$', 'i');
