CREATE OR REPLACE PROCEDURE public.updates_2_0_0()\n
    LANGUAGE plpgsql\n
AS $BODY$\n
DECLARE\n
existenciaTabelaImp_IcmsProduto boolean;\n
existenciaTabelaImp_Produto boolean;\n
existenciaTabelaImp_Cliente boolean;\n
existenciaTabelaImp_Crediario boolean;\n
existenciaTabelaImp_DependenteCliente boolean;\n
existenciaTabelaImp_Fornecedor boolean;\n
existenciaTabelaImp_Fabricante boolean;\n
existenciaTabelaImp_TabDescontosClassificacao boolean;\n
existenciaTabelaImp_TabDescontosProduto boolean;\n
existenciaTabelaImp_TabDescontos boolean;\n
existenciaTabelaImp_ItemCadernoOferta boolean;\n
existenciaTabelaImp_CadernoOferta boolean;\n
existenciaTabelaImp_Classificacao boolean;\n
existenciaTabelaImp_GrupoRemarcacao boolean;\n
existenciaTabelaImp_Versao boolean;\n
existenciaTabelaImp_Cest boolean;\n
\n
BEGIN\n
\n
SELECT\n
  (CASE\n
    WHEN COUNT(table_name) <= 0 THEN FALSE\n
    ELSE TRUE\n
  END) INTO existenciaTabelaImp_IcmsProduto\n
FROM information_schema.tables\n
WHERE table_catalog = '$nomedatabase_clean_chinchila_imp'\n
  AND table_schema = 'public'\n
  AND table_name = 'imp_icmsproduto';\n
\n
IF (existenciaTabelaImp_IcmsProduto = TRUE) then\n
raise exception 'Não é possível continuar, a tabela imp_icmsproduto já existe!';\n
end IF;\n
\n
SELECT\n
  (CASE\n
    WHEN COUNT(table_name) <= 0 THEN FALSE\n
    ELSE TRUE\n
  END) INTO existenciaTabelaImp_Produto\n
FROM information_schema.tables\n
WHERE table_catalog = '$nomedatabase_clean_chinchila_imp'\n
  AND table_schema = 'public'\n
  AND table_name = 'imp_produto';\n
\n
IF (existenciaTabelaImp_Produto = FALSE) then\n
raise exception 'Não é possível continuar, a tabela imp_produto não existe!';\n
end IF;\n
\n
SELECT\n
  (CASE\n
    WHEN COUNT(table_name) <= 0 THEN FALSE\n
    ELSE TRUE\n
  END) INTO existenciaTabelaImp_Cliente\n
FROM information_schema.tables\n
WHERE table_catalog = '$nomedatabase_clean_chinchila_imp'\n
  AND table_schema = 'public'\n
  AND table_name = 'imp_cliente';\n
\n
IF (existenciaTabelaImp_Cliente = FALSE) then\n
raise exception 'Não é possível continuar, a tabela imp_cliente não existe!';\n
end IF;\n
\n
SELECT\n
  (CASE\n
    WHEN COUNT(table_name) <= 0 THEN FALSE\n
    ELSE TRUE\n
  END) INTO existenciaTabelaImp_Crediario\n
FROM information_schema.tables\n
WHERE table_catalog = '$nomedatabase_clean_chinchila_imp'\n
  AND table_schema = 'public'\n
  AND table_name = 'imp_crediario';\n
\n
IF (existenciaTabelaImp_Crediario = FALSE) then\n
raise exception 'Não é possível continuar, a tabela imp_crediario não existe!';\n
end IF;\n
\n
SELECT\n
  (CASE\n
    WHEN COUNT(table_name) <= 0 THEN FALSE\n
    ELSE TRUE\n
  END) INTO existenciaTabelaImp_DependenteCliente\n
FROM information_schema.tables\n
WHERE table_catalog = '$nomedatabase_clean_chinchila_imp'\n
  AND table_schema = 'public'\n
  AND table_name = 'imp_dependentecliente';\n
\n
IF (existenciaTabelaImp_DependenteCliente = FALSE) then\n
raise exception 'Não é possível continuar, a tabela imp_crediario não existe!';\n
end IF;\n
\n
SELECT\n
  (CASE\n
    WHEN COUNT(table_name) <= 0 THEN FALSE\n
    ELSE TRUE\n
  END) INTO existenciaTabelaImp_Fornecedor\n
FROM information_schema.tables\n
WHERE table_catalog = '$nomedatabase_clean_chinchila_imp'\n
  AND table_schema = 'public'\n
  AND table_name = 'imp_fornecedor';\n
\n
IF (existenciaTabelaImp_Fornecedor = FALSE) then\n
raise exception 'Não é possível continuar, a tabela imp_fornecedor não existe!';\n
end IF;\n
\n
SELECT\n
  (CASE\n
    WHEN COUNT(table_name) <= 0 THEN FALSE\n
    ELSE TRUE\n
  END) INTO existenciaTabelaImp_Fabricante\n
FROM information_schema.tables\n
WHERE table_catalog = '$nomedatabase_clean_chinchila_imp'\n
  AND table_schema = 'public'\n
  AND table_name = 'imp_fabricante';\n
\n
IF (existenciaTabelaImp_Fabricante = FALSE) then\n
raise exception 'Não é possível continuar, a tabela imp_fabricante não existe!';\n
end IF;\n
\n
SELECT\n
  (CASE\n
    WHEN COUNT(table_name) <= 0 THEN FALSE\n
    ELSE TRUE\n
  END) INTO existenciaTabelaImp_TabDescontosClassificacao\n
FROM information_schema.tables\n
WHERE table_catalog = '$nomedatabase_clean_chinchila_imp'\n
  AND table_schema = 'public'\n
  AND table_name = 'imp_tabdescontosclassificacao';\n
\n
IF (existenciaTabelaImp_TabDescontosClassificacao = FALSE) then\n
raise exception 'Não é possível continuar, a tabela imp_tabdescontosclassificacao não existe!';\n
end IF;\n
\n
SELECT\n
  (CASE\n
    WHEN COUNT(table_name) <= 0 THEN FALSE\n
    ELSE TRUE\n
  END) INTO existenciaTabelaImp_TabDescontosProduto\n
FROM information_schema.tables\n
WHERE table_catalog = '$nomedatabase_clean_chinchila_imp'\n
  AND table_schema = 'public'\n
  AND table_name = 'imp_tabdescontosproduto';\n
\n
IF (existenciaTabelaImp_TabDescontosProduto = FALSE) then\n
raise exception 'Não é possível continuar, a tabela imp_tabdescontosproduto não existe!';\n
end IF;\n
\n
SELECT\n
  (CASE\n
    WHEN COUNT(table_name) <= 0 THEN FALSE\n
    ELSE TRUE\n
  END) INTO existenciaTabelaImp_TabDescontos\n
FROM information_schema.tables\n
WHERE table_catalog = '$nomedatabase_clean_chinchila_imp'\n
  AND table_schema = 'public'\n
  AND table_name = 'imp_tabdescontos';\n
\n
IF (existenciaTabelaImp_TabDescontos = FALSE) then\n
raise exception 'Não é possível continuar, a tabela imp_tabdescontos não existe!';\n
end IF;\n
\n
SELECT\n
  (CASE\n
    WHEN COUNT(table_name) <= 0 THEN FALSE\n
    ELSE TRUE\n
  END) INTO existenciaTabelaImp_ItemCadernoOferta\n
FROM information_schema.tables\n
WHERE table_catalog = '$nomedatabase_clean_chinchila_imp'\n
  AND table_schema = 'public'\n
  AND table_name = 'imp_itemcadernooferta';\n
\n
IF (existenciaTabelaImp_ItemCadernoOferta = FALSE) then\n
raise exception 'Não é possível continuar, a tabela imp_itemcadernooferta não existe!';\n
end IF;\n
\n
SELECT\n
  (CASE\n
    WHEN COUNT(table_name) <= 0 THEN FALSE\n
    ELSE TRUE\n
  END) INTO existenciaTabelaImp_CadernoOferta\n
FROM information_schema.tables\n
WHERE table_catalog = '$nomedatabase_clean_chinchila_imp'\n
  AND table_schema = 'public'\n
  AND table_name = 'imp_cadernooferta';\n
\n
IF (existenciaTabelaImp_CadernoOferta = FALSE) then\n
raise exception 'Não é possível continuar, a tabela imp_cadernooferta não existe!';\n
end IF;\n
\n
SELECT\n
  (CASE\n
    WHEN COUNT(table_name) <= 0 THEN FALSE\n
    ELSE TRUE\n
  END) INTO existenciaTabelaImp_Classificacao\n
FROM information_schema.tables\n
WHERE table_catalog = '$nomedatabase_clean_chinchila_imp'\n
  AND table_schema = 'public'\n
  AND table_name = 'imp_classificacao';\n
\n
IF (existenciaTabelaImp_Classificacao = FALSE) then\n
raise exception 'Não é possível continuar, a tabela imp_classificacao não existe!';\n
end IF;\n
\n
SELECT\n
  (CASE\n
    WHEN COUNT(table_name) <= 0 THEN FALSE\n
    ELSE TRUE\n
  END) INTO existenciaTabelaImp_GrupoRemarcacao\n
FROM information_schema.tables\n
WHERE table_catalog = '$nomedatabase_clean_chinchila_imp'\n
  AND table_schema = 'public'\n
  AND table_name = 'imp_gruporemarcacao';\n
\n
IF (existenciaTabelaImp_GrupoRemarcacao = FALSE) then\n
raise exception 'Não é possível continuar, a tabela imp_gruporemarcacao não existe!';\n
end IF;\n
\n
SELECT\n
  (CASE\n
    WHEN COUNT(table_name) <= 0 THEN FALSE\n
    ELSE TRUE\n
  END) INTO existenciaTabelaImp_Versao\n
FROM information_schema.tables\n
WHERE table_catalog = '$nomedatabase_clean_chinchila_imp'\n
  AND table_schema = 'public'\n
  AND table_name = 'imp_versao';\n
\n
IF (existenciaTabelaImp_Versao = TRUE) then\n
raise exception 'Não é possível continuar, a tabela imp_versao já existe!';\n
end IF;\n
\n
SELECT\n
  (CASE\n
    WHEN COUNT(table_name) <= 0 THEN FALSE\n
    ELSE TRUE\n
  END) INTO existenciaTabelaImp_Cest\n
FROM information_schema.tables\n
WHERE table_catalog = '$nomedatabase_clean_chinchila_imp'\n
  AND table_schema = 'public'\n
  AND table_name = 'imp_cest';\n
\n
IF (existenciaTabelaImp_Cest = FALSE) then\n
raise exception 'Não é possível continuar, a tabela imp_cest não existe!';\n
end IF;\n
\n
-- ALTERA A IMP_CLIENTE\n
ALTER TABLE imp_cliente\n
ADD Ret_ContatoCelular2ID int8,\n
ADD Celular2 varchar(16);\n
COMMENT ON COLUMN Imp_Cliente.Ret_ContatoCelular2ID IS 'ID Entidade|ID da entidade salva no Chinchila';\n
\n
-- ALTERA A IMP_CREDIARIO\n
ALTER TABLE imp_crediario\n
ADD Ret_ContatoCelular2ID int8,\n
ADD Celular2 varchar(16);\n
COMMENT ON COLUMN Imp_Crediario.Ret_ContatoCelular2ID IS 'ID Entidade|ID da entidade salva no Chinchila';\n
\n
-- ALTERA A IMP_DEPENDENTECLIENTE\n
ALTER TABLE imp_dependentecliente\n
ADD Ret_ContatoCelular2ID int8,\n
ADD Celular2 varchar(16);\n
COMMENT ON COLUMN Imp_DependenteCliente.Ret_ContatoCelular2ID IS 'ID Entidade|ID da entidade salva no Chinchila';\n
\n
-- ALTERA A IMP_FORNECEDOR\n
ALTER TABLE imp_fornecedor\n
ADD Ret_ContatoCelular2ID int8,\n
ADD Celular2 varchar(16);\n
COMMENT ON COLUMN Imp_Fornecedor.Ret_ContatoCelular2ID IS 'ID Entidade|ID da entidade salva no Chinchila';\n
\n
-- ALTERA A IMP_FABRICANTE\n
ALTER TABLE imp_fabricante\n
ADD Ret_ContatoCelular2ID int8,\n
ADD Celular2 varchar(16);\n
COMMENT ON COLUMN Imp_Fabricante.Ret_ContatoCelular2ID IS 'ID Entidade|ID da entidade salva no Chinchila';\n
\n
-- ALTERA A IMP_PRODUTO\n
ALTER TABLE imp_produto\n
ADD Status char(1) DEFAULT 'A' NOT NULL,\n
ADD ListaDcb char(1);\n
COMMENT ON COLUMN Imp_Produto.Status IS 'Status|Status do Produto';\n
COMMENT ON COLUMN Imp_Produto.ListaDcb IS 'Lista Dcb|Lista Dbc do produto que informa os fármacos ou princípios ativos utilizados no produto';\n
\n
-- CRIA A IMP_ICMSPRODUTO\n
CREATE TABLE Imp_IcmsProduto (\n
Ret_Status char(1) DEFAULT 'N' NOT NULL,\n
Ret_Erro text,\n
Ret_IcmsProdutoID int8,\n
Ret_TotalizadorFiscalID int8,\n
Imp_ProdutoID varchar(100) NOT NULL,\n
PerfilIcmsSnID int8,\n
PerfilIcmsID int8,\n
Estado varchar(2) NOT NULL,\n
PRIMARY KEY (Imp_ProdutoID, Estado));\n
COMMENT ON COLUMN Imp_IcmsProduto.Ret_Status IS 'Status|Status da importação (N=Não Importado, S=Sucesso, E=Erro, I=Ignorado)';\n
COMMENT ON COLUMN Imp_IcmsProduto.Ret_Erro IS 'Erro|Mensagem de erro que ocorreu na importação';\n
COMMENT ON COLUMN Imp_IcmsProduto.Ret_IcmsProdutoID IS 'ID Entidade|ID da entidade salva no Chinchila';\n
COMMENT ON COLUMN Imp_IcmsProduto.Ret_TotalizadorFiscalID IS 'ID Entidade|ID da entidade salva no Chinchila';\n
COMMENT ON COLUMN Imp_IcmsProduto.PerfilIcmsSnID IS 'PerfilIcmsSnID|ID do registro referente ao regime simples nacional correspondente na Entidade PerfilIcms do Chinchila';\n
COMMENT ON COLUMN Imp_IcmsProduto.PerfilIcmsID IS 'PerfilIcmsID|ID do registro referente ao regime normal correspondente na Entidade PerfilIcms do Chinchila';\n
COMMENT ON COLUMN Imp_IcmsProduto.Estado IS 'Estado|Sigla do estado referente as unidades federativas do Brasil';\n
ALTER TABLE Imp_IcmsProduto ADD CONSTRAINT FK_Imp_Produto_Imp_PerfilIcms FOREIGN KEY (Imp_ProdutoID) REFERENCES Imp_Produto (ID);\n
\n
--ALTERA A IMP_PRODUTO\n
ALTER TABLE Imp_Produto\n
ADD CestID int8,\n
ADD PerfilPISSnID int8,\n
ADD PerfilCofinsSnID int8,\n
ADD PerfilPISID int8,\n
ADD PerfilCofinsID int8;\n
COMMENT ON COLUMN Imp_Produto.CestID IS 'CestID|ID do registro correspondente na Entidade Cest do Chinchila';\n
COMMENT ON COLUMN Imp_Produto.PerfilPISSnID IS 'PerfilPISSnID|ID do registro referente ao regime simples nacional correspondente na Entidade PerfilPIS do Chinchila';\n
COMMENT ON COLUMN Imp_Produto.PerfilCofinsSnID IS 'PerfilCofinsSnID|ID do registro referente ao regime simples nacional correspondente na Entidade PerfilCofins do Chinchila';\n
COMMENT ON COLUMN Imp_Produto.PerfilPISID IS 'PerfilPISID|ID do registro referente ao regime normal correspondente na Entidade PerfilPIS do Chinchila';\n
COMMENT ON COLUMN Imp_Produto.PerfilCofinsID IS 'PerfilCofinsID|ID do registro referente ao regime normal correspondente na Entidade PerfilCofins do Chinchila';\n
\n
ALTER TABLE Imp_Produto DROP COLUMN Ret_TotalizadorFiscalID;\n
\n
-- ALTERA A IMP_CREDIARIO RETIRANDO A IMP_TABDESCONTOSID E COLOCA IMP_CADERNOOFERTAID\n
ALTER TABLE Imp_Crediario DROP COLUMN Imp_TabDescontosID;\n
\n
-- DELETA IMP_TABDESCONTOSCLASSIFICACAO\n
ALTER TABLE Imp_TabDescontosClassificacao DROP CONSTRAINT IF EXISTS FKImp_TabDes522579;\n
ALTER TABLE Imp_TabDescontosClassificacao DROP CONSTRAINT IF EXISTS FKImp_TabDes28787;\n
DROP TABLE IF EXISTS Imp_TabDescontosClassificacao CASCADE;\n
\n
-- DELETA IMP_TABDESCONTOSPRODUTO\n
ALTER TABLE Imp_TabDescontosProduto DROP CONSTRAINT IF EXISTS FKImp_TabDes906779;\n
ALTER TABLE Imp_TabDescontosProduto DROP CONSTRAINT IF EXISTS FKImp_TabDes587276;\n
DROP TABLE IF EXISTS Imp_TabDescontosProduto CASCADE;\n
\n
-- DELETA IMP_TABDESCONTOS\n
DROP TABLE IF EXISTS Imp_TabDescontos CASCADE;\n
\n
-- DELETA A IMP_ITEMCADERNOOFERTA\n
ALTER TABLE Imp_ItemCadernoOferta DROP CONSTRAINT IF EXISTS FKImp_ItemCa108948;\n
ALTER TABLE Imp_ItemCadernoOferta DROP CONSTRAINT IF EXISTS fkimp_itemca113214;\n
DROP TABLE IF EXISTS Imp_ItemCadernoOferta CASCADE;\n
\n
-- DELETA AS TABELAS QUE NÃO EXISTEM NO DIAGRAMA REFERENTE A CADERNOS DE OFERTAS\n
DROP TABLE IF EXISTS imp_itemcadernooferta_class;\n
DROP TABLE IF EXISTS imp_itemcadernooferta_fabric;\n
DROP TABLE IF EXISTS imp_itemcadernooferta_gruporem;\n
\n
-- RECRIA IMP_ITEMCADERNOOFERTA\n
CREATE TABLE Imp_ItemCadernoOferta (\n
  Ret_Status                  char(1) DEFAULT 'N' NOT NULL, \n
  Ret_Erro                    text, \n
  Ret_ItemCadernoOfertaID     int8, \n
  Imp_CadernoOfertaID         varchar(100), \n
  Imp_ProdutoID               varchar(100), \n
  Imp_FabricanteID            varchar(100), \n
  Imp_ClassificacaoID         varchar(100), \n
  Imp_GrupoRemarcacaoID       varchar(100), \n
  TipoOferta                  char(1) DEFAULT 'P' NOT NULL, \n
  PrecoOferta                 numeric(15, 4), \n
  DescontoOferta              numeric(15, 4), \n
  Leve                        int4, \n
  Pague                       int4, \n
  DescontoLevePague           numeric(15, 4),\n
  Markup                      numeric(15, 4), \n
  DescontoPorQtdTipo          char(1) default 'A' not null, \n
  DescontoPorQtdVendaAcimaQtd char(1) default 'A' not null,\n
CONSTRAINT UQ_Imp_CadernoOferta_Imp_Produto UNIQUE (Imp_CadernoOfertaID, Imp_ProdutoID),\n
CONSTRAINT UQ_Imp_ItemCadernoOferta_Imp_Fabricante UNIQUE (Imp_CadernoOfertaID, Imp_FabricanteID),\n
CONSTRAINT UQ_Imp_ItemCadernoOferta_Imp_Classificacao UNIQUE (Imp_CadernoOfertaID, Imp_ClassificacaoID),\n
CONSTRAINT UQ_Imp_ItemCadernoOferta_Imp_GrupoRemarcacao UNIQUE (Imp_CadernoOfertaID, Imp_GrupoRemarcacaoID));\n
COMMENT ON COLUMN Imp_ItemCadernoOferta.Ret_Status IS 'Status|Status da importação (N=Não Importado, S=Sucesso, E=Erro, I=Ignorado)';\n
COMMENT ON COLUMN Imp_ItemCadernoOferta.Ret_Erro IS 'Erro|Mensagem de erro que ocorreu na importação';\n
COMMENT ON COLUMN Imp_ItemCadernoOferta.Ret_ItemCadernoOfertaID IS 'ID Entidade|ID da entidade salva no Chinchila';\n
COMMENT ON COLUMN Imp_ItemCadernoOferta.TipoOferta IS 'Tipo de Oferta|Tipo de Oferta a ser aplicado no item do Caderno de Oferta';\n
COMMENT ON COLUMN Imp_ItemCadernoOferta.PrecoOferta IS 'Preço Oferta|Preço de Oferta do item';\n
COMMENT ON COLUMN Imp_ItemCadernoOferta.DescontoOferta IS '% Desconto|Porcentagem de Desconto a ser aplicado no item em Oferta';\n
COMMENT ON COLUMN Imp_ItemCadernoOferta.Leve IS 'Leve|Quantidade de Embalagens a ser levada';\n
COMMENT ON COLUMN Imp_ItemCadernoOferta.Pague IS 'Pague|Quantidade de Embalagens a ser paga';\n
COMMENT ON COLUMN Imp_ItemCadernoOferta.DescontoLevePague IS 'Desconto Leve Pague|Desconto em porcentagem a ser aplicado no item';\n
COMMENT ON COLUMN Imp_ItemCadernoOferta.Markup IS 'Markup|Markup a ser aplicado no item do Caderno de Oferta';\n
COMMENT ON COLUMN Imp_ItemCadernoOferta.DescontoPorQtdTipo IS 'DescontoPorQtdTipo|DescontoPorQtdTipo a ser aplicado no item do Caderno de Oferta';\n
COMMENT ON COLUMN Imp_ItemCadernoOferta.DescontoPorQtdVendaAcimaQtd IS 'DescontoPorQtdVendaAcimaQtd|DescontoPorQtdVendaAcimaQtd a ser aplicado no item do Caderno de Oferta';\n
ALTER TABLE Imp_ItemCadernoOferta ADD CONSTRAINT FK_Imp_CadernoOferta_Imp_ItemCadernoOferta FOREIGN KEY (Imp_CadernoOfertaID) REFERENCES Imp_CadernoOferta (ID);\n
ALTER TABLE Imp_ItemCadernoOferta ADD CONSTRAINT FK_Imp_Classificacao_Imp_ItemCadernoOferta FOREIGN KEY (Imp_ClassificacaoID) REFERENCES Imp_Classificacao (ID);\n
ALTER TABLE Imp_ItemCadernoOferta ADD CONSTRAINT FK_Imp_Fabricante_Imp_ItemCadernoOferta FOREIGN KEY (Imp_FabricanteID) REFERENCES Imp_Fabricante (ID);\n
ALTER TABLE Imp_ItemCadernoOferta ADD CONSTRAINT FK_Imp_GrupoRemarcacao_Imp_ItemCadernoOferta FOREIGN KEY (Imp_GrupoRemarcacaoID) REFERENCES Imp_GrupoRemarcacao (ID);\n
ALTER TABLE Imp_ItemCadernoOferta ADD CONSTRAINT FK_Imp_Produto_Imp_ItemCadernoOferta FOREIGN KEY (Imp_ProdutoID) REFERENCES Imp_Produto (ID);\n
\n
-- ALTERA O TIPO DA COLUNA ID DA TABELA IMP_CEST\n
ALTER TABLE imp_cest ALTER COLUMN id TYPE bigint USING (trim(id)::bigint);\n
\n
-- CRIA A IMP_VERSAO\n
CREATE TABLE Imp_Versao (\n
  Versao varchar(30) not null,\n
  DataHoraAtualizacao timestamp default current_timestamp not null);\n
\n
-- INSERE A VERSÃO ATUAL\n
INSERT INTO Imp_Versao (Versao) VALUES ('2.0.0');\n
\n
-- DÁ AS PERMISSÕES AO CHINCHILA PARA MANUSEAR AS TABELAS\n
GRANT SELECT,INSERT, UPDATE, DELETE  ON ALL TABLES IN SCHEMA public TO chinchila;\n
\n
-- A FUNÇÃO SE AUTO DROPA AUTOMATICAMENTE\n
DROP PROCEDURE IF EXISTS public.updates_2_0_0();\n
\n
END;\n
$BODY$;\n
\n
ALTER PROCEDURE public.updates_2_0_0()\n
    OWNER TO chinchila;\n