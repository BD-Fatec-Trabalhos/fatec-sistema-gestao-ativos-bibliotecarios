-- ============================================================
--  SISTEMA DE BIBLIOTECA  |  3ª ETAPA
--  Oracle SQL  –  Criação, Views, Procedures, Triggers,
--                 Backup e Segurança
-- ============================================================


-- ============================================================
-- 1. CRIAÇÃO DAS TABELAS (base já fornecida + complementos)
-- ============================================================

CREATE TABLE autores (
    id_autor   NUMBER PRIMARY KEY,
    nome_autor VARCHAR2(100) NOT NULL
);

CREATE TABLE editoras (
    id_editora   VARCHAR2(50) PRIMARY KEY,
    nome_editora VARCHAR2(100) NOT NULL
);

CREATE TABLE generos (
    id_genero   NUMBER PRIMARY KEY,
    nome_genero VARCHAR2(50) NOT NULL
);

CREATE TABLE idiomas (
    id_idioma   NUMBER PRIMARY KEY,
    nome_idioma VARCHAR2(50) NOT NULL
);

CREATE TABLE tipo_ativos (
    id_tipo   NUMBER PRIMARY KEY,
    nome_tipo VARCHAR2(50) NOT NULL
);

CREATE TABLE enderecos (
    cep    NUMBER(8) PRIMARY KEY,
    rua    VARCHAR2(150) NOT NULL,
    bairro VARCHAR2(100) NOT NULL,
    numero VARCHAR2(10)
);

CREATE TABLE usuarios (
    cpf           NUMBER(11) PRIMARY KEY,
    nome_usuario  VARCHAR2(100) NOT NULL,
    email         VARCHAR2(100) UNIQUE,
    senha         VARCHAR2(50)  NOT NULL,
    telefone      VARCHAR2(20)
);

CREATE TABLE funcionarios (
    id_funcionario   NUMBER PRIMARY KEY,
    nome_funcionario VARCHAR2(100) NOT NULL,
    email            VARCHAR2(100) UNIQUE,
    senha            VARCHAR2(50)  NOT NULL,
    telefone         VARCHAR2(20)
);

CREATE TABLE unidades_bibliotecarias (
    id_biblioteca   NUMBER PRIMARY KEY,
    nome_biblioteca VARCHAR2(100) NOT NULL,
    cep             NUMBER(8) NOT NULL,
    CONSTRAINT fk_biblioteca_cep FOREIGN KEY (cep) REFERENCES enderecos(cep)
);

CREATE TABLE ativos (
    id_ativos              NUMBER PRIMARY KEY,
    nome_ativos            VARCHAR2(200) NOT NULL,
    id_tipo                NUMBER NOT NULL,
    fk_generos_id_genero   NUMBER NOT NULL,
    status_disponibilidade NUMBER(1) NOT NULL,
    ano_publicacao         NUMBER(4),
    isbn                   VARCHAR2(20) UNIQUE,
    CONSTRAINT fk_ativos_tipo   FOREIGN KEY (id_tipo)              REFERENCES tipo_ativos(id_tipo),
    CONSTRAINT fk_ativos_genero FOREIGN KEY (fk_generos_id_genero) REFERENCES generos(id_genero)
);

CREATE TABLE locacoes (
    id_locacao              NUMBER PRIMARY KEY,
    id_ativo                NUMBER NOT NULL,
    nome_locacao            VARCHAR2(100),
    id_usuario              NUMBER(11) NOT NULL,
    data_locacao            DATE NOT NULL,
    data_devolucao_prevista DATE NOT NULL,
    data_devolucao_real     DATE,
    CONSTRAINT fk_locacao_ativo   FOREIGN KEY (id_ativo)    REFERENCES ativos(id_ativos),
    CONSTRAINT fk_locacao_usuario FOREIGN KEY (id_usuario)  REFERENCES usuarios(cpf)
);

CREATE TABLE multas (
    id_multa        NUMBER PRIMARY KEY,
    valor_multa     NUMBER(10,2) NOT NULL,
    status_pagamento NUMBER(1)   NOT NULL,
    data_geracao    DATE         NOT NULL,
    id_locacao      NUMBER       NOT NULL,
    CONSTRAINT fk_multa_locacao FOREIGN KEY (id_locacao) REFERENCES locacoes(id_locacao)
);

CREATE TABLE reservas (
    id_reservas NUMBER PRIMARY KEY,
    cpf         NUMBER(11) NOT NULL,
    id_ativo    NUMBER     NOT NULL,
    data_reserva DATE      NOT NULL,
    status_reserva NUMBER(1) DEFAULT 1 NOT NULL,   -- 1=ativa, 0=cancelada
    CONSTRAINT fk_reserva_usuario FOREIGN KEY (cpf)      REFERENCES usuarios(cpf),
    CONSTRAINT fk_reserva_ativo   FOREIGN KEY (id_ativo) REFERENCES ativos(id_ativos)
);

CREATE TABLE log_sistema (
    id_log           NUMBER PRIMARY KEY,
    data_hora        TIMESTAMP NOT NULL,
    descricao_acao   VARCHAR2(500) NOT NULL,
    id_funcionario   NUMBER NOT NULL,
    CONSTRAINT fk_log_funcionario FOREIGN KEY (id_funcionario) REFERENCES funcionarios(id_funcionario)
);

-- ============================================================
-- 2. SEQUENCES
-- ============================================================

CREATE SEQUENCE seq_multa    START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_locacao  START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_reserva  START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_log      START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_ativo    START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_usuario  START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;


-- ============================================================
-- 3. INSERÇÃO DE DADOS DE TESTE (população das tabelas)
-- ============================================================

-- Tipos de ativo
INSERT INTO tipo_ativos VALUES (1, 'Livro');
INSERT INTO tipo_ativos VALUES (2, 'Revista');
INSERT INTO tipo_ativos VALUES (3, 'DVD');
INSERT INTO tipo_ativos VALUES (4, 'HQ / Quadrinhos');

-- Gêneros
INSERT INTO generos VALUES (1, 'Suspense');
INSERT INTO generos VALUES (2, 'Romance');
INSERT INTO generos VALUES (3, 'Ficção Científica');
INSERT INTO generos VALUES (4, 'Terror');
INSERT INTO generos VALUES (5, 'Biografia');
INSERT INTO generos VALUES (6, 'Infantil');

-- Idiomas
INSERT INTO idiomas VALUES (1, 'Português');
INSERT INTO idiomas VALUES (2, 'Inglês');
INSERT INTO idiomas VALUES (3, 'Espanhol');

-- Autores
INSERT INTO autores VALUES (1, 'Machado de Assis');
INSERT INTO autores VALUES (2, 'Clarice Lispector');
INSERT INTO autores VALUES (3, 'Jorge Amado');
INSERT INTO autores VALUES (4, 'Agatha Christie');
INSERT INTO autores VALUES (5, 'Isaac Asimov');

-- Editoras
INSERT INTO editoras VALUES ('ED001', 'Companhia das Letras');
INSERT INTO editoras VALUES ('ED002', 'Record');
INSERT INTO editoras VALUES ('ED003', 'Rocco');
INSERT INTO editoras VALUES ('ED004', 'Intrínseca');

-- Endereços
INSERT INTO enderecos VALUES (17010000, 'Rua Primeiro de Agosto', 'Centro',       '100');
INSERT INTO enderecos VALUES (17020000, 'Av. Nações Unidas',      'Jardim Brasil', '200');
INSERT INTO enderecos VALUES (17030000, 'Rua das Flores',          'Bela Vista',   '50');

-- Unidades bibliotecárias
INSERT INTO unidades_bibliotecarias VALUES (1, 'Biblioteca Central',   17010000);
INSERT INTO unidades_bibliotecarias VALUES (2, 'Biblioteca do Bairro', 17020000);

-- Funcionários
INSERT INTO funcionarios VALUES (1, 'Carlos Silva',    'carlos@biblioteca.com',  'senha123', '14988880001');
INSERT INTO funcionarios VALUES (2, 'Ana Pereira',     'ana@biblioteca.com',     'senha456', '14988880002');
INSERT INTO funcionarios VALUES (3, 'Roberto Santos',  'roberto@biblioteca.com', 'senha789', '14988880003');

-- Usuários
INSERT INTO usuarios VALUES (12345678901, 'Eduardo Cimino',   'edu@email.com',    '123456', '11999999999');
INSERT INTO usuarios VALUES (98765432100, 'Maria Oliveira',   'maria@email.com',  'abcdef', '11988888888');
INSERT INTO usuarios VALUES (11122233344, 'João Costa',       'joao@email.com',   'pass99', '11977777777');
INSERT INTO usuarios VALUES (55566677788, 'Fernanda Lima',    'fer@email.com',    'fern01', '11966666666');
INSERT INTO usuarios VALUES (33344455566, 'Lucas Mendes',     'lucas@email.com',  'luc123', '11955555555');

-- Ativos (acervo)
INSERT INTO ativos VALUES (1,  'Dom Casmurro',                  1, 1, 1, 1899, '9788594318602');
INSERT INTO ativos VALUES (2,  'A Hora da Estrela',             1, 2, 1, 1977, '9788535910759');
INSERT INTO ativos VALUES (3,  'Capitães da Areia',             1, 2, 1, 1937, '9788535908756');
INSERT INTO ativos VALUES (4,  'O Assassinato no Expresso Oriente', 1, 1, 1, 1934, '9788525423528');
INSERT INTO ativos VALUES (5,  'Eu, Robô',                      1, 3, 0, 1950, '9788576572794');
INSERT INTO ativos VALUES (6,  'Revista Ciência Hoje',          2, 3, 1, 2023, NULL);
INSERT INTO ativos VALUES (7,  '2001: Uma Odisseia no Espaço',  3, 3, 1, 1968, NULL);
INSERT INTO ativos VALUES (8,  'Turma da Mônica – Vol. 1',      4, 6, 1, 2010, NULL);
INSERT INTO ativos VALUES (9,  'O Senhor dos Anéis',            1, 1, 1, 1954, '9788533613379');
INSERT INTO ativos VALUES (10, 'Cem Anos de Solidão',           1, 2, 0, 1967, '9788535902778');

-- Locações
INSERT INTO locacoes VALUES (1, 1, 'Locação Livro', 12345678901, SYSDATE,     SYSDATE + 7,  NULL);
INSERT INTO locacoes VALUES (2, 2, 'Locação Livro', 98765432100, SYSDATE - 5, SYSDATE + 2,  NULL);
INSERT INTO locacoes VALUES (3, 4, 'Locação Livro', 11122233344, SYSDATE - 3, SYSDATE + 4,  NULL);
INSERT INTO locacoes VALUES (4, 3, 'Locação Livro', 55566677788, SYSDATE - 15, SYSDATE - 8, SYSDATE - 5);
INSERT INTO locacoes VALUES (5, 8, 'Locação HQ',    33344455566, SYSDATE - 20, SYSDATE - 13, SYSDATE - 10);

-- Multas (uma em aberto, uma paga)
INSERT INTO multas VALUES (1, 15.00, 0, SYSDATE - 5,  4);
INSERT INTO multas VALUES (2, 30.00, 1, SYSDATE - 10, 5);

-- Reservas
INSERT INTO reservas VALUES (1, 12345678901, 5,  SYSDATE,     1);
INSERT INTO reservas VALUES (2, 98765432100, 10, SYSDATE - 1, 1);

-- Log do sistema
INSERT INTO log_sistema VALUES (1, SYSTIMESTAMP, 'Cadastro do usuário Eduardo Cimino',   1);
INSERT INTO log_sistema VALUES (2, SYSTIMESTAMP, 'Cadastro do usuário Maria Oliveira',   1);
INSERT INTO log_sistema VALUES (3, SYSTIMESTAMP, 'Registro de locação id=1',             2);
INSERT INTO log_sistema VALUES (4, SYSTIMESTAMP, 'Geração de multa id=1 – atraso',       2);
INSERT INTO log_sistema VALUES (5, SYSTIMESTAMP, 'Pagamento de multa id=2 confirmado',   3);

COMMIT;


-- ============================================================
-- 4. VIEWS (mínimo 10)
-- ============================================================

-- VIEW 1 – Acervo completo com tipo e gênero
CREATE OR REPLACE VIEW vw_acervo_completo AS
SELECT
    a.id_ativos,
    a.nome_ativos,
    t.nome_tipo,
    g.nome_genero,
    CASE a.status_disponibilidade
        WHEN 1 THEN 'Disponível'
        ELSE 'Indisponível'
    END AS disponibilidade,
    a.ano_publicacao,
    a.isbn
FROM ativos a
JOIN tipo_ativos t ON t.id_tipo          = a.id_tipo
JOIN generos     g ON g.id_genero        = a.fk_generos_id_genero;

-- VIEW 2 – Locações em andamento (sem devolução real)
CREATE OR REPLACE VIEW vw_locacoes_ativas AS
SELECT
    l.id_locacao,
    a.nome_ativos,
    u.nome_usuario,
    l.data_locacao,
    l.data_devolucao_prevista,
    CASE
        WHEN l.data_devolucao_prevista < SYSDATE THEN 'ATRASADA'
        ELSE 'NO PRAZO'
    END AS situacao
FROM locacoes l
JOIN ativos   a ON a.id_ativos = l.id_ativo
JOIN usuarios u ON u.cpf       = l.id_usuario
WHERE l.data_devolucao_real IS NULL;

-- VIEW 3 – Histórico completo de locações
CREATE OR REPLACE VIEW vw_historico_locacoes AS
SELECT
    l.id_locacao,
    u.nome_usuario,
    a.nome_ativos,
    l.data_locacao,
    l.data_devolucao_prevista,
    l.data_devolucao_real,
    CASE
        WHEN l.data_devolucao_real IS NULL THEN 'Em curso'
        WHEN l.data_devolucao_real > l.data_devolucao_prevista THEN 'Devolvido com atraso'
        ELSE 'Devolvido no prazo'
    END AS status_devolucao
FROM locacoes l
JOIN ativos   a ON a.id_ativos = l.id_ativo
JOIN usuarios u ON u.cpf       = l.id_usuario;

-- VIEW 4 – Multas em aberto
CREATE OR REPLACE VIEW vw_multas_pendentes AS
SELECT
    m.id_multa,
    u.nome_usuario,
    a.nome_ativos,
    m.valor_multa,
    m.data_geracao,
    l.data_devolucao_prevista,
    l.data_devolucao_real
FROM multas   m
JOIN locacoes l ON l.id_locacao = m.id_locacao
JOIN usuarios u ON u.cpf        = l.id_usuario
JOIN ativos   a ON a.id_ativos  = l.id_ativo
WHERE m.status_pagamento = 0;

-- VIEW 5 – Resumo financeiro de multas por usuário
CREATE OR REPLACE VIEW vw_multas_por_usuario AS
SELECT
    u.cpf,
    u.nome_usuario,
    COUNT(m.id_multa)  AS total_multas,
    SUM(m.valor_multa) AS valor_total,
    SUM(CASE m.status_pagamento WHEN 0 THEN m.valor_multa ELSE 0 END) AS valor_pendente
FROM usuarios u
LEFT JOIN locacoes l ON l.id_usuario = u.cpf
LEFT JOIN multas   m ON m.id_locacao = l.id_locacao
GROUP BY u.cpf, u.nome_usuario;

-- VIEW 6 – Itens indisponíveis (emprestados ou reservados)
CREATE OR REPLACE VIEW vw_itens_indisponiveis AS
SELECT
    a.id_ativos,
    a.nome_ativos,
    t.nome_tipo,
    g.nome_genero
FROM ativos      a
JOIN tipo_ativos t ON t.id_tipo    = a.id_tipo
JOIN generos     g ON g.id_genero  = a.fk_generos_id_genero
WHERE a.status_disponibilidade = 0;

-- VIEW 7 – Usuários com locações atrasadas
CREATE OR REPLACE VIEW vw_usuarios_inadimplentes AS
SELECT DISTINCT
    u.cpf,
    u.nome_usuario,
    u.email,
    u.telefone
FROM usuarios u
JOIN locacoes l ON l.id_usuario = u.cpf
WHERE l.data_devolucao_real IS NULL
  AND l.data_devolucao_prevista < SYSDATE;

-- VIEW 8 – Reservas ativas com status do item
CREATE OR REPLACE VIEW vw_reservas_ativas AS
SELECT
    r.id_reservas,
    u.nome_usuario,
    a.nome_ativos,
    t.nome_tipo,
    r.data_reserva,
    CASE a.status_disponibilidade
        WHEN 1 THEN 'Disponível para retirada'
        ELSE 'Aguardando devolução'
    END AS status_item
FROM reservas    r
JOIN usuarios    u ON u.cpf       = r.cpf
JOIN ativos      a ON a.id_ativos = r.id_ativo
JOIN tipo_ativos t ON t.id_tipo   = a.id_tipo
WHERE r.status_reserva = 1;

-- VIEW 9 – Log de ações por funcionário
CREATE OR REPLACE VIEW vw_log_por_funcionario AS
SELECT
    f.id_funcionario,
    f.nome_funcionario,
    COUNT(lg.id_log)       AS total_acoes,
    MAX(lg.data_hora)      AS ultima_acao,
    MIN(lg.data_hora)      AS primeira_acao
FROM funcionarios f
LEFT JOIN log_sistema lg ON lg.id_funcionario = f.id_funcionario
GROUP BY f.id_funcionario, f.nome_funcionario;

-- VIEW 10 – Acervo disponível por gênero (painel de busca)
CREATE OR REPLACE VIEW vw_acervo_disponivel_por_genero AS
SELECT
    g.nome_genero,
    COUNT(a.id_ativos) AS qtd_disponivel
FROM generos g
LEFT JOIN ativos a ON a.fk_generos_id_genero = g.id_genero
                   AND a.status_disponibilidade = 1
GROUP BY g.nome_genero
ORDER BY qtd_disponivel DESC;

-- VIEW 11 – Ranking de itens mais locados
CREATE OR REPLACE VIEW vw_itens_mais_locados AS
SELECT
    a.id_ativos,
    a.nome_ativos,
    t.nome_tipo,
    COUNT(l.id_locacao) AS total_locacoes
FROM ativos      a
JOIN tipo_ativos t ON t.id_tipo    = a.id_tipo
LEFT JOIN locacoes l ON l.id_ativo = a.id_ativos
GROUP BY a.id_ativos, a.nome_ativos, t.nome_tipo
ORDER BY total_locacoes DESC;

-- VIEW 12 – Devoluções previstas para os próximos 7 dias
CREATE OR REPLACE VIEW vw_devolucoes_proximos7dias AS
SELECT
    l.id_locacao,
    u.nome_usuario,
    u.telefone,
    a.nome_ativos,
    l.data_devolucao_prevista
FROM locacoes l
JOIN usuarios u ON u.cpf       = l.id_usuario
JOIN ativos   a ON a.id_ativos = l.id_ativo
WHERE l.data_devolucao_real IS NULL
  AND l.data_devolucao_prevista BETWEEN SYSDATE AND SYSDATE + 7
ORDER BY l.data_devolucao_prevista;


-- ============================================================
-- 5. STORED PROCEDURES
-- ============================================================

-- PROCEDURE 1 – Registrar nova locação
CREATE OR REPLACE PROCEDURE sp_registrar_locacao (
    p_id_locacao  IN locacoes.id_locacao%TYPE,
    p_id_ativo    IN locacoes.id_ativo%TYPE,
    p_cpf         IN locacoes.id_usuario%TYPE,
    p_dias_prazo  IN NUMBER DEFAULT 7
) AS
BEGIN
    INSERT INTO locacoes (
        id_locacao, id_ativo, id_usuario,
        data_locacao, data_devolucao_prevista, data_devolucao_real
    ) VALUES (
        p_id_locacao, p_id_ativo, p_cpf,
        SYSDATE, SYSDATE + p_dias_prazo, NULL
    );
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Locação ' || p_id_locacao || ' registrada com sucesso.');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Erro ao registrar locação: ' || SQLERRM);
END sp_registrar_locacao;
/

-- PROCEDURE 2 – Registrar devolução e quitar reservas pendentes
CREATE OR REPLACE PROCEDURE sp_registrar_devolucao (
    p_id_locacao IN locacoes.id_locacao%TYPE
) AS
    v_id_ativo locacoes.id_ativo%TYPE;
BEGIN
    -- Atualiza data real de devolução
    UPDATE locacoes
    SET data_devolucao_real = SYSDATE
    WHERE id_locacao = p_id_locacao
      AND data_devolucao_real IS NULL;

    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Locação não encontrada ou já devolvida.');
        RETURN;
    END IF;

    -- Recupera o ativo para liberar status
    SELECT id_ativo INTO v_id_ativo
    FROM locacoes WHERE id_locacao = p_id_locacao;

    UPDATE ativos
    SET status_disponibilidade = 1
    WHERE id_ativos = v_id_ativo;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Devolução da locação ' || p_id_locacao || ' registrada.');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Erro na devolução: ' || SQLERRM);
END sp_registrar_devolucao;
/

-- PROCEDURE 3 – Quitar multa
CREATE OR REPLACE PROCEDURE sp_quitar_multa (
    p_id_multa IN multas.id_multa%TYPE
) AS
BEGIN
    UPDATE multas
    SET status_pagamento = 1
    WHERE id_multa = p_id_multa
      AND status_pagamento = 0;

    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Multa não encontrada ou já quitada.');
    ELSE
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Multa ' || p_id_multa || ' quitada com sucesso.');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Erro ao quitar multa: ' || SQLERRM);
END sp_quitar_multa;
/

-- PROCEDURE 4 – Cadastrar usuário
CREATE OR REPLACE PROCEDURE sp_cadastrar_usuario (
    p_cpf    IN usuarios.cpf%TYPE,
    p_nome   IN usuarios.nome_usuario%TYPE,
    p_email  IN usuarios.email%TYPE,
    p_senha  IN usuarios.senha%TYPE,
    p_tel    IN usuarios.telefone%TYPE DEFAULT NULL
) AS
BEGIN
    INSERT INTO usuarios (cpf, nome_usuario, email, senha, telefone)
    VALUES (p_cpf, p_nome, p_email, p_senha, p_tel);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Usuário ' || p_nome || ' cadastrado.');
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('CPF ou e-mail já cadastrado.');
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Erro: ' || SQLERRM);
END sp_cadastrar_usuario;
/

-- PROCEDURE 5 – Gerar relatório de inadimplentes (saída via DBMS_OUTPUT)
CREATE OR REPLACE PROCEDURE sp_relatorio_inadimplentes AS
    CURSOR c_inad IS
        SELECT u.nome_usuario, u.email, l.data_devolucao_prevista,
               TRUNC(SYSDATE - l.data_devolucao_prevista) AS dias_atraso
        FROM locacoes l
        JOIN usuarios u ON u.cpf = l.id_usuario
        WHERE l.data_devolucao_real IS NULL
          AND l.data_devolucao_prevista < SYSDATE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== RELATÓRIO DE INADIMPLENTES ===');
    FOR reg IN c_inad LOOP
        DBMS_OUTPUT.PUT_LINE(
            reg.nome_usuario || ' | ' ||
            reg.email        || ' | Atraso: ' ||
            reg.dias_atraso  || ' dia(s)'
        );
    END LOOP;
END sp_relatorio_inadimplentes;
/


-- ============================================================
-- 6. TRIGGERS (mínimo 5 – aqui temos 7)
-- ============================================================

-- TRIGGER 1 – Impedir locação de item indisponível
CREATE OR REPLACE TRIGGER trg_verifica_disponibilidade
BEFORE INSERT ON locacoes
FOR EACH ROW
DECLARE
    v_status NUMBER;
BEGIN
    SELECT status_disponibilidade INTO v_status
    FROM ativos WHERE id_ativos = :NEW.id_ativo;

    IF v_status = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Item indisponível para locação.');
    END IF;
END;
/

-- TRIGGER 2 – Marcar item como indisponível ao locar
CREATE OR REPLACE TRIGGER trg_atualiza_status_locacao
AFTER INSERT ON locacoes
FOR EACH ROW
BEGIN
    UPDATE ativos
    SET status_disponibilidade = 0
    WHERE id_ativos = :NEW.id_ativo;
END;
/

-- TRIGGER 3 – Gerar multa automática por atraso na devolução
CREATE OR REPLACE TRIGGER trg_gera_multa
AFTER UPDATE OF data_devolucao_real ON locacoes
FOR EACH ROW
BEGIN
    IF :NEW.data_devolucao_real > :NEW.data_devolucao_prevista THEN
        INSERT INTO multas (id_multa, valor_multa, status_pagamento, data_geracao, id_locacao)
        VALUES (seq_multa.NEXTVAL, 15.00, 0, SYSDATE, :NEW.id_locacao);
    END IF;
END;
/

-- TRIGGER 4 – Restaurar disponibilidade ao devolver
CREATE OR REPLACE TRIGGER trg_libera_ativo_devolucao
AFTER UPDATE OF data_devolucao_real ON locacoes
FOR EACH ROW
BEGIN
    IF :NEW.data_devolucao_real IS NOT NULL
       AND :OLD.data_devolucao_real IS NULL THEN
        UPDATE ativos
        SET status_disponibilidade = 1
        WHERE id_ativos = :NEW.id_ativo;
    END IF;
END;
/

-- TRIGGER 5 – Impedir exclusão de locação com multa em aberto
CREATE OR REPLACE TRIGGER trg_bloqueia_del_locacao_com_multa
BEFORE DELETE ON locacoes
FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM multas
    WHERE id_locacao = :OLD.id_locacao
      AND status_pagamento = 0;

    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20002,
            'Não é possível excluir uma locação com multa pendente.');
    END IF;
END;
/

-- TRIGGER 6 – Registrar automaticamente no log ao inserir locação
CREATE OR REPLACE TRIGGER trg_log_nova_locacao
AFTER INSERT ON locacoes
FOR EACH ROW
DECLARE
    v_func NUMBER := 1;   -- funcionário padrão do sistema; ajuste conforme necessário
BEGIN
    INSERT INTO log_sistema (id_log, data_hora, descricao_acao, id_funcionario)
    VALUES (seq_log.NEXTVAL,
            SYSTIMESTAMP,
            'Nova locação registrada. ID=' || :NEW.id_locacao ||
            ' | Ativo=' || :NEW.id_ativo ||
            ' | Usuário=' || :NEW.id_usuario,
            v_func);
END;
/

-- TRIGGER 7 – Cancelar reserva automaticamente quando item é locado
CREATE OR REPLACE TRIGGER trg_cancela_reserva_ao_locar
AFTER INSERT ON locacoes
FOR EACH ROW
BEGIN
    UPDATE reservas
    SET status_reserva = 0
    WHERE id_ativo = :NEW.id_ativo
      AND cpf = :NEW.id_usuario
      AND status_reserva = 1;
END;
/


-- ============================================================
-- 7. BACKUP DE TABELAS (espelhamento / cópia e restauração)
-- ============================================================

-- ── 7.1  Tabelas de backup (espelhos) ────────────────────────

CREATE TABLE bkp_usuarios AS SELECT * FROM usuarios WHERE 1=0;
CREATE TABLE bkp_ativos   AS SELECT * FROM ativos   WHERE 1=0;
CREATE TABLE bkp_locacoes AS SELECT * FROM locacoes  WHERE 1=0;
CREATE TABLE bkp_multas   AS SELECT * FROM multas    WHERE 1=0;
CREATE TABLE bkp_reservas AS SELECT * FROM reservas  WHERE 1=0;

-- ── 7.2  Procedure de backup completo ────────────────────────

CREATE OR REPLACE PROCEDURE sp_executar_backup AS
BEGIN
    -- Limpa espelhos e reinsere tudo
    DELETE FROM bkp_usuarios; INSERT INTO bkp_usuarios SELECT * FROM usuarios;
    DELETE FROM bkp_ativos;   INSERT INTO bkp_ativos   SELECT * FROM ativos;
    DELETE FROM bkp_locacoes; INSERT INTO bkp_locacoes SELECT * FROM locacoes;
    DELETE FROM bkp_multas;   INSERT INTO bkp_multas   SELECT * FROM multas;
    DELETE FROM bkp_reservas; INSERT INTO bkp_reservas SELECT * FROM reservas;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Backup realizado em ' || TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI'));
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Falha no backup: ' || SQLERRM);
END sp_executar_backup;
/

-- ── 7.3  Procedure de restauração (backup → tabela principal) ─

CREATE OR REPLACE PROCEDURE sp_restaurar_backup AS
BEGIN
    -- ATENÇÃO: substitui os dados atuais pelos dados do backup
    DELETE FROM multas;   INSERT INTO multas   SELECT * FROM bkp_multas;
    DELETE FROM locacoes; INSERT INTO locacoes  SELECT * FROM bkp_locacoes;
    DELETE FROM reservas; INSERT INTO reservas  SELECT * FROM bkp_reservas;
    DELETE FROM ativos;   INSERT INTO ativos    SELECT * FROM bkp_ativos;
    DELETE FROM usuarios; INSERT INTO usuarios  SELECT * FROM bkp_usuarios;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Restauração concluída em ' || TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI'));
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Falha na restauração: ' || SQLERRM);
END sp_restaurar_backup;
/

-- ── 7.4  Trigger de espelhamento contínuo (locações) ─────────

CREATE OR REPLACE TRIGGER trg_espelha_locacao
AFTER INSERT OR UPDATE OR DELETE ON locacoes
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        INSERT INTO bkp_locacoes VALUES (
            :NEW.id_locacao, :NEW.id_ativo, :NEW.nome_locacao,
            :NEW.id_usuario, :NEW.data_locacao,
            :NEW.data_devolucao_prevista, :NEW.data_devolucao_real
        );
    ELSIF UPDATING THEN
        UPDATE bkp_locacoes
        SET id_ativo                = :NEW.id_ativo,
            nome_locacao            = :NEW.nome_locacao,
            id_usuario              = :NEW.id_usuario,
            data_locacao            = :NEW.data_locacao,
            data_devolucao_prevista = :NEW.data_devolucao_prevista,
            data_devolucao_real     = :NEW.data_devolucao_real
        WHERE id_locacao = :OLD.id_locacao;
    ELSIF DELETING THEN
        DELETE FROM bkp_locacoes WHERE id_locacao = :OLD.id_locacao;
    END IF;
END;
/

-- ── 7.5  Como executar backup e restauração ──────────────────
-- EXEC sp_executar_backup;
-- EXEC sp_restaurar_backup;


-- ============================================================
-- 8. CONTROLE DE SEGURANÇA DO BANCO DE DADOS
-- ============================================================

-- ── 8.1  Criação de roles ────────────────────────────────────

CREATE ROLE role_bibliotecario;
CREATE ROLE role_atendente;
CREATE ROLE role_consulta;

-- ── 8.2  Permissões por role ─────────────────────────────────

-- CONSULTA: só leitura nas views
GRANT SELECT ON vw_acervo_completo           TO role_consulta;
GRANT SELECT ON vw_locacoes_ativas           TO role_consulta;
GRANT SELECT ON vw_acervo_disponivel_por_genero TO role_consulta;
GRANT SELECT ON vw_devolucoes_proximos7dias  TO role_consulta;
GRANT SELECT ON vw_itens_indisponiveis       TO role_consulta;

-- ATENDENTE: leitura + operações de locação/devolução/multa
GRANT role_consulta                           TO role_atendente;
GRANT SELECT, INSERT ON locacoes              TO role_atendente;
GRANT SELECT, UPDATE ON locacoes              TO role_atendente;
GRANT SELECT, UPDATE ON multas                TO role_atendente;
GRANT SELECT         ON usuarios              TO role_atendente;
GRANT SELECT         ON ativos                TO role_atendente;
GRANT EXECUTE ON sp_registrar_locacao         TO role_atendente;
GRANT EXECUTE ON sp_registrar_devolucao       TO role_atendente;
GRANT EXECUTE ON sp_quitar_multa              TO role_atendente;

-- BIBLIOTECARIO: acesso total + backup + cadastros
GRANT role_atendente                          TO role_bibliotecario;
GRANT ALL ON usuarios                         TO role_bibliotecario;
GRANT ALL ON ativos                           TO role_bibliotecario;
GRANT ALL ON funcionarios                     TO role_bibliotecario;
GRANT ALL ON reservas                         TO role_bibliotecario;
GRANT ALL ON log_sistema                      TO role_bibliotecario;
GRANT ALL ON generos                          TO role_bibliotecario;
GRANT ALL ON tipo_ativos                      TO role_bibliotecario;
GRANT EXECUTE ON sp_executar_backup           TO role_bibliotecario;
GRANT EXECUTE ON sp_restaurar_backup          TO role_bibliotecario;
GRANT EXECUTE ON sp_relatorio_inadimplentes   TO role_bibliotecario;
GRANT EXECUTE ON sp_cadastrar_usuario         TO role_bibliotecario;

-- ── 8.3  Criação de usuários de banco ───────────────────────
--  (execute como DBA / SYSDBA)

-- Usuário para atendentes de balcão
CREATE USER usr_atendente  IDENTIFIED BY "Atend@2024"
    DEFAULT TABLESPACE users TEMPORARY TABLESPACE temp;
GRANT CONNECT           TO usr_atendente;
GRANT role_atendente    TO usr_atendente;

-- Usuário para bibliotecários
CREATE USER usr_bibliotecario IDENTIFIED BY "Biblio@2024"
    DEFAULT TABLESPACE users TEMPORARY TABLESPACE temp;
GRANT CONNECT               TO usr_bibliotecario;
GRANT role_bibliotecario    TO usr_bibliotecario;

-- Usuário somente leitura (portal web / OPAC)
CREATE USER usr_consulta IDENTIFIED BY "Consul@2024"
    DEFAULT TABLESPACE users TEMPORARY TABLESPACE temp;
GRANT CONNECT       TO usr_consulta;
GRANT role_consulta TO usr_consulta;

-- ── 8.4  Política de senha (Oracle 12c+) ────────────────────

CREATE PROFILE perfil_biblioteca LIMIT
    FAILED_LOGIN_ATTEMPTS  5
    PASSWORD_LOCK_TIME     1/24        -- 1 hora
    PASSWORD_LIFE_TIME     90          -- trocar a cada 90 dias
    PASSWORD_REUSE_TIME    365
    PASSWORD_REUSE_MAX     5
    PASSWORD_GRACE_TIME    7;

ALTER USER usr_atendente      PROFILE perfil_biblioteca;
ALTER USER usr_bibliotecario  PROFILE perfil_biblioteca;
ALTER USER usr_consulta       PROFILE perfil_biblioteca;

-- ── 8.5  Auditoria de operações sensíveis ───────────────────
--  (requer privilégio AUDIT SYSTEM)

AUDIT INSERT, UPDATE, DELETE ON locacoes  BY ACCESS;
AUDIT INSERT, UPDATE, DELETE ON multas    BY ACCESS;
AUDIT INSERT, UPDATE, DELETE ON usuarios  BY ACCESS;
AUDIT INSERT, UPDATE, DELETE ON ativos    BY ACCESS;

-- ── 8.6  Revogação de acesso direto às tabelas para atendente
--  (força o uso das views, evitando acesso a colunas sensíveis como senha)

REVOKE SELECT ON usuarios FROM role_atendente;
-- Concede view segura no lugar da tabela
GRANT SELECT ON vw_acervo_completo TO role_atendente;


-- ============================================================
--  FIM DO SCRIPT
-- ============================================================
