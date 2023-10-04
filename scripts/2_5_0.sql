CREATE OR REPLACE PROCEDURE public.updates_2_5_0()\n
    LANGUAGE plpgsql\n
AS $BODY$\n
DECLARE\n
existenciaTabelaImp_Versao boolean;\n
\n
BEGIN\n
\n
SELECT\n
  (CASE\n
    WHEN COUNT(table_name) <= 0 THEN FALSE\n
    ELSE TRUE\n
  END) INTO existenciaTabelaImp_Versao\n
FROM information_schema.tables\n
WHERE table_catalog = 'clean_chinchila_imp'\n
  AND table_schema = 'public'\n
  AND table_name = 'imp_versao';\n
\n
IF (existenciaTabelaImp_Versao = FALSE) then\n
raise exception 'Não é possível continuar, a tabela imp_versao não existe!';\n
end IF;\n
\n
-- ADICIONA A COLUNA\n
ALTER TABLE imp_ ADD origem_importacao char(1) DEFAULT 'I' NOT NULL; COMMENT ON COLUMN imp_.origem_importacao IS 'Origem_Importacao|Origem do registro a ser importado, ou seja, se ele já existia em algum momento em alguma base de dados no caso de merge ou se o registro é novo e será importado';\n
ALTER TABLE imp_cadernooferta ADD origem_importacao char(1) DEFAULT 'I' NOT NULL; COMMENT ON COLUMN imp_cadernooferta.origem_importacao IS 'Origem_Importacao|Origem do registro a ser importado, ou seja, se ele já existia em algum momento em alguma base de dados no caso de merge ou se o registro é novo e será importado';\n
ALTER TABLE imp_chequereceber ADD origem_importacao char(1) DEFAULT 'I' NOT NULL; COMMENT ON COLUMN imp_chequereceber.origem_importacao IS 'Origem_Importacao|Origem do registro a ser importado, ou seja, se ele já existia em algum momento em alguma base de dados no caso de merge ou se o registro é novo e será importado';\n
ALTER TABLE imp_classificacao ADD origem_importacao char(1) DEFAULT 'I' NOT NULL; COMMENT ON COLUMN imp_classificacao.origem_importacao IS 'Origem_Importacao|Origem do registro a ser importado, ou seja, se ele já existia em algum momento em alguma base de dados no caso de merge ou se o registro é novo e será importado';\n
ALTER TABLE imp_cliente ADD origem_importacao char(1) DEFAULT 'I' NOT NULL; COMMENT ON COLUMN imp_cliente.origem_importacao IS 'Origem_Importacao|Origem do registro a ser importado, ou seja, se ele já existia em algum momento em alguma base de dados no caso de merge ou se o registro é novo e será importado';\n
ALTER TABLE imp_cliente_endereco ADD origem_importacao char(1) DEFAULT 'I' NOT NULL; COMMENT ON COLUMN imp_cliente_endereco.origem_importacao IS 'Origem_Importacao|Origem do registro a ser importado, ou seja, se ele já existia em algum momento em alguma base de dados no caso de merge ou se o registro é novo e será importado';\n
ALTER TABLE imp_codigobarras ADD origem_importacao char(1) DEFAULT 'I' NOT NULL; COMMENT ON COLUMN imp_codigobarras.origem_importacao IS 'Origem_Importacao|Origem do registro a ser importado, ou seja, se ele já existia em algum momento em alguma base de dados no caso de merge ou se o registro é novo e será importado';\n
ALTER TABLE imp_contapagar ADD origem_importacao char(1) DEFAULT 'I' NOT NULL; COMMENT ON COLUMN imp_contapagar.origem_importacao IS 'Origem_Importacao|Origem do registro a ser importado, ou seja, se ele já existia em algum momento em alguma base de dados no caso de merge ou se o registro é novo e será importado';\n
ALTER TABLE imp_crediario ADD origem_importacao char(1) DEFAULT 'I' NOT NULL; COMMENT ON COLUMN imp_crediario.origem_importacao IS 'Origem_Importacao|Origem do registro a ser importado, ou seja, se ele já existia em algum momento em alguma base de dados no caso de merge ou se o registro é novo e será importado';\n
ALTER TABLE imp_crediarioreceber ADD origem_importacao char(1) DEFAULT 'I' NOT NULL; COMMENT ON COLUMN imp_crediarioreceber.origem_importacao IS 'Origem_Importacao|Origem do registro a ser importado, ou seja, se ele já existia em algum momento em alguma base de dados no caso de merge ou se o registro é novo e será importado';\n
ALTER TABLE imp_custo ADD origem_importacao char(1) DEFAULT 'I' NOT NULL; COMMENT ON COLUMN imp_custo.origem_importacao IS 'Origem_Importacao|Origem do registro a ser importado, ou seja, se ele já existia em algum momento em alguma base de dados no caso de merge ou se o registro é novo e será importado';\n
ALTER TABLE imp_dependentecliente ADD origem_importacao char(1) DEFAULT 'I' NOT NULL; COMMENT ON COLUMN imp_dependentecliente.origem_importacao IS 'Origem_Importacao|Origem do registro a ser importado, ou seja, se ele já existia em algum momento em alguma base de dados no caso de merge ou se o registro é novo e será importado';\n
ALTER TABLE imp_estoque ADD origem_importacao char(1) DEFAULT 'I' NOT NULL; COMMENT ON COLUMN imp_estoque.origem_importacao IS 'Origem_Importacao|Origem do registro a ser importado, ou seja, se ele já existia em algum momento em alguma base de dados no caso de merge ou se o registro é novo e será importado';\n
ALTER TABLE imp_fabricante ADD origem_importacao char(1) DEFAULT 'I' NOT NULL; COMMENT ON COLUMN imp_fabricante.origem_importacao IS 'Origem_Importacao|Origem do registro a ser importado, ou seja, se ele já existia em algum momento em alguma base de dados no caso de merge ou se o registro é novo e será importado';\n
ALTER TABLE imp_fabricante_endereco ADD origem_importacao char(1) DEFAULT 'I' NOT NULL; COMMENT ON COLUMN imp_fabricante_endereco.origem_importacao IS 'Origem_Importacao|Origem do registro a ser importado, ou seja, se ele já existia em algum momento em alguma base de dados no caso de merge ou se o registro é novo e será importado';\n
ALTER TABLE imp_fechamentoplanopagamento ADD origem_importacao char(1) DEFAULT 'I' NOT NULL; COMMENT ON COLUMN imp_fechamentoplanopagamento.origem_importacao IS 'Origem_Importacao|Origem do registro a ser importado, ou seja, se ele já existia em algum momento em alguma base de dados no caso de merge ou se o registro é novo e será importado';\n
ALTER TABLE imp_fornecedor ADD origem_importacao char(1) DEFAULT 'I' NOT NULL; COMMENT ON COLUMN imp_fornecedor.origem_importacao IS 'Origem_Importacao|Origem do registro a ser importado, ou seja, se ele já existia em algum momento em alguma base de dados no caso de merge ou se o registro é novo e será importado';\n
ALTER TABLE imp_fornecedor_endereco ADD origem_importacao char(1) DEFAULT 'I' NOT NULL; COMMENT ON COLUMN imp_fornecedor_endereco.origem_importacao IS 'Origem_Importacao|Origem do registro a ser importado, ou seja, se ele já existia em algum momento em alguma base de dados no caso de merge ou se o registro é novo e será importado';\n
ALTER TABLE imp_gruporemarcacao ADD origem_importacao char(1) DEFAULT 'I' NOT NULL; COMMENT ON COLUMN imp_gruporemarcacao.origem_importacao IS 'Origem_Importacao|Origem do registro a ser importado, ou seja, se ele já existia em algum momento em alguma base de dados no caso de merge ou se o registro é novo e será importado';\n
ALTER TABLE imp_historicovenda ADD origem_importacao char(1) DEFAULT 'I' NOT NULL; COMMENT ON COLUMN imp_historicovenda.origem_importacao IS 'Origem_Importacao|Origem do registro a ser importado, ou seja, se ele já existia em algum momento em alguma base de dados no caso de merge ou se o registro é novo e será importado';\n
ALTER TABLE imp_icmsproduto ADD origem_importacao char(1) DEFAULT 'I' NOT NULL; COMMENT ON COLUMN imp_icmsproduto.origem_importacao IS 'Origem_Importacao|Origem do registro a ser importado, ou seja, se ele já existia em algum momento em alguma base de dados no caso de merge ou se o registro é novo e será importado';\n
ALTER TABLE imp_itemcadernooferta ADD origem_importacao char(1) DEFAULT 'I' NOT NULL; COMMENT ON COLUMN imp_itemcadernooferta.origem_importacao IS 'Origem_Importacao|Origem do registro a ser importado, ou seja, se ele já existia em algum momento em alguma base de dados no caso de merge ou se o registro é novo e será importado';\n
ALTER TABLE imp_itemcadernoofertaquantidade ADD origem_importacao char(1) DEFAULT 'I' NOT NULL; COMMENT ON COLUMN imp_itemcadernoofertaquantidade.origem_importacao IS 'Origem_Importacao|Origem do registro a ser importado, ou seja, se ele já existia em algum momento em alguma base de dados no caso de merge ou se o registro é novo e será importado';\n
ALTER TABLE imp_pessoa ADD origem_importacao char(1) DEFAULT 'I' NOT NULL; COMMENT ON COLUMN imp_pessoa.origem_importacao IS 'Origem_Importacao|Origem do registro a ser importado, ou seja, se ele já existia em algum momento em alguma base de dados no caso de merge ou se o registro é novo e será importado';\n
ALTER TABLE imp_pessoa_endereco ADD origem_importacao char(1) DEFAULT 'I' NOT NULL; COMMENT ON COLUMN imp_pessoa_endereco.origem_importacao IS 'Origem_Importacao|Origem do registro a ser importado, ou seja, se ele já existia em algum momento em alguma base de dados no caso de merge ou se o registro é novo e será importado';\n
ALTER TABLE imp_planopagamento ADD origem_importacao char(1) DEFAULT 'I' NOT NULL; COMMENT ON COLUMN imp_planopagamento.origem_importacao IS 'Origem_Importacao|Origem do registro a ser importado, ou seja, se ele já existia em algum momento em alguma base de dados no caso de merge ou se o registro é novo e será importado';\n
ALTER TABLE imp_planoremu ADD origem_importacao char(1) DEFAULT 'I' NOT NULL; COMMENT ON COLUMN imp_planoremu.origem_importacao IS 'Origem_Importacao|Origem do registro a ser importado, ou seja, se ele já existia em algum momento em alguma base de dados no caso de merge ou se o registro é novo e será importado';\n
ALTER TABLE imp_planoremubonificacao ADD origem_importacao char(1) DEFAULT 'I' NOT NULL; COMMENT ON COLUMN imp_planoremubonificacao.origem_importacao IS 'Origem_Importacao|Origem do registro a ser importado, ou seja, se ele já existia em algum momento em alguma base de dados no caso de merge ou se o registro é novo e será importado';\n
ALTER TABLE imp_planoremucomissao ADD origem_importacao char(1) DEFAULT 'I' NOT NULL; COMMENT ON COLUMN imp_planoremucomissao.origem_importacao IS 'Origem_Importacao|Origem do registro a ser importado, ou seja, se ele já existia em algum momento em alguma base de dados no caso de merge ou se o registro é novo e será importado';\n
ALTER TABLE imp_precoprodutounidadenegocio ADD origem_importacao char(1) DEFAULT 'I' NOT NULL; COMMENT ON COLUMN imp_precoprodutounidadenegocio.origem_importacao IS 'Origem_Importacao|Origem do registro a ser importado, ou seja, se ele já existia em algum momento em alguma base de dados no caso de merge ou se o registro é novo e será importado';\n
ALTER TABLE imp_prescritor ADD origem_importacao char(1) DEFAULT 'I' NOT NULL; COMMENT ON COLUMN imp_prescritor.origem_importacao IS 'Origem_Importacao|Origem do registro a ser importado, ou seja, se ele já existia em algum momento em alguma base de dados no caso de merge ou se o registro é novo e será importado';\n
ALTER TABLE imp_principioativo ADD origem_importacao char(1) DEFAULT 'I' NOT NULL; COMMENT ON COLUMN imp_principioativo.origem_importacao IS 'Origem_Importacao|Origem do registro a ser importado, ou seja, se ele já existia em algum momento em alguma base de dados no caso de merge ou se o registro é novo e será importado';\n
ALTER TABLE imp_produto ADD origem_importacao char(1) DEFAULT 'I' NOT NULL; COMMENT ON COLUMN imp_produto.origem_importacao IS 'Origem_Importacao|Origem do registro a ser importado, ou seja, se ele já existia em algum momento em alguma base de dados no caso de merge ou se o registro é novo e será importado';\n
ALTER TABLE imp_tabrestricoes ADD origem_importacao char(1) DEFAULT 'I' NOT NULL; COMMENT ON COLUMN imp_tabrestricoes.origem_importacao IS 'Origem_Importacao|Origem do registro a ser importado, ou seja, se ele já existia em algum momento em alguma base de dados no caso de merge ou se o registro é novo e será importado';\n
ALTER TABLE imp_tabrestricoesclassificacao ADD origem_importacao char(1) DEFAULT 'I' NOT NULL; COMMENT ON COLUMN imp_tabrestricoesclassificacao.origem_importacao IS 'Origem_Importacao|Origem do registro a ser importado, ou seja, se ele já existia em algum momento em alguma base de dados no caso de merge ou se o registro é novo e será importado';\n
ALTER TABLE imp_tabrestricoesproduto ADD origem_importacao char(1) DEFAULT 'I' NOT NULL; COMMENT ON COLUMN imp_tabrestricoesproduto.origem_importacao IS 'Origem_Importacao|Origem do registro a ser importado, ou seja, se ele já existia em algum momento em alguma base de dados no caso de merge ou se o registro é novo e será importado';\n
ALTER TABLE imp_uncadernooferta ADD origem_importacao char(1) DEFAULT 'I' NOT NULL; COMMENT ON COLUMN imp_uncadernooferta.origem_importacao IS 'Origem_Importacao|Origem do registro a ser importado, ou seja, se ele já existia em algum momento em alguma base de dados no caso de merge ou se o registro é novo e será importado';\n
ALTER TABLE imp_unidadenegocio ADD origem_importacao char(1) DEFAULT 'I' NOT NULL; COMMENT ON COLUMN imp_unidadenegocio.origem_importacao IS 'Origem_Importacao|Origem do registro a ser importado, ou seja, se ele já existia em algum momento em alguma base de dados no caso de merge ou se o registro é novo e será importado';\n
ALTER TABLE imp_usuario ADD origem_importacao char(1) DEFAULT 'I' NOT NULL; COMMENT ON COLUMN imp_usuario.origem_importacao IS 'Origem_Importacao|Origem do registro a ser importado, ou seja, se ele já existia em algum momento em alguma base de dados no caso de merge ou se o registro é novo e será importado';\n
\n
-- INSERE A VERSÃO ATUAL\n
INSERT INTO Imp_Versao (Versao) VALUES ('2.5.0');\n
\n
-- DÁ AS PERMISSÕES AO CHINCHILA PARA MANUSEAR AS TABELAS\n
GRANT SELECT,INSERT, UPDATE, DELETE  ON ALL TABLES IN SCHEMA public TO chinchila;\n
\n
-- A FUNÇÃO SE AUTO DROPA AUTOMATICAMENTE\n
DROP PROCEDURE IF EXISTS public.updates_2_5_0();\n
\n
END; $BODY$;\n
\n
ALTER PROCEDURE public.updates_2_5_0() OWNER TO chinchila;\n