CREATE OR REPLACE FUNCTION public.updates_2_0_0()
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
existenciaTabelaImp_IcmsProduto boolean;
existenciaTabelaImp_Produto boolean;
existenciaTabelaImp_Cliente boolean;
existenciaTabelaImp_Crediario boolean;
existenciaTabelaImp_DependenteCliente boolean;
existenciaTabelaImp_Fornecedor boolean;
existenciaTabelaImp_Fabricante boolean;
existenciaTabelaImp_TabDescontosClassificacao boolean;
existenciaTabelaImp_TabDescontosProduto boolean;
existenciaTabelaImp_TabDescontos boolean;
existenciaTabelaImp_ItemCadernoOferta boolean;
existenciaTabelaImp_CadernoOferta boolean;
existenciaTabelaImp_Classificacao boolean;
existenciaTabelaImp_GrupoRemarcacao boolean;
existenciaTabelaImp_Versao boolean;

BEGIN

SELECT
  (CASE
    WHEN COUNT(table_name) <= 0 THEN FALSE
    ELSE TRUE
  END) INTO existenciaTabelaImp_IcmsProduto
FROM information_schema.tables
WHERE table_catalog = '$nomedatabase_clean_chinchila_imp'
  AND table_schema = 'public'
  AND table_name = 'imp_icmsproduto';

IF (existenciaTabelaImp_IcmsProduto = TRUE) then
raise exception 'Não é possível continuar, a tabela imp_icmsproduto já existe!';
end IF;

SELECT
  (CASE
    WHEN COUNT(table_name) <= 0 THEN FALSE
    ELSE TRUE
  END) INTO existenciaTabelaImp_Produto
FROM information_schema.tables
WHERE table_catalog = '$nomedatabase_clean_chinchila_imp'
  AND table_schema = 'public'
  AND table_name = 'imp_produto';

IF (existenciaTabelaImp_Produto = FALSE) then
raise exception 'Não é possível continuar, a tabela imp_produto não existe!';
end IF;

SELECT
  (CASE
    WHEN COUNT(table_name) <= 0 THEN FALSE
    ELSE TRUE
  END) INTO existenciaTabelaImp_Cliente
FROM information_schema.tables
WHERE table_catalog = '$nomedatabase_clean_chinchila_imp'
  AND table_schema = 'public'
  AND table_name = 'imp_cliente';

IF (existenciaTabelaImp_Cliente = FALSE) then
raise exception 'Não é possível continuar, a tabela imp_cliente não existe!';
end IF;

SELECT
  (CASE
    WHEN COUNT(table_name) <= 0 THEN FALSE
    ELSE TRUE
  END) INTO existenciaTabelaImp_Crediario
FROM information_schema.tables
WHERE table_catalog = '$nomedatabase_clean_chinchila_imp'
  AND table_schema = 'public'
  AND table_name = 'imp_crediario';

IF (existenciaTabelaImp_Crediario = FALSE) then
raise exception 'Não é possível continuar, a tabela imp_crediario não existe!';
end IF;

SELECT
  (CASE
    WHEN COUNT(table_name) <= 0 THEN FALSE
    ELSE TRUE
  END) INTO existenciaTabelaImp_DependenteCliente
FROM information_schema.tables
WHERE table_catalog = '$nomedatabase_clean_chinchila_imp'
  AND table_schema = 'public'
  AND table_name = 'imp_dependentecliente';

IF (existenciaTabelaImp_DependenteCliente = FALSE) then
raise exception 'Não é possível continuar, a tabela imp_crediario não existe!';
end IF;

SELECT
  (CASE
    WHEN COUNT(table_name) <= 0 THEN FALSE
    ELSE TRUE
  END) INTO existenciaTabelaImp_Fornecedor
FROM information_schema.tables
WHERE table_catalog = '$nomedatabase_clean_chinchila_imp'
  AND table_schema = 'public'
  AND table_name = 'imp_fornecedor';

IF (existenciaTabelaImp_Fornecedor = FALSE) then
raise exception 'Não é possível continuar, a tabela imp_fornecedor não existe!';
end IF;

SELECT
  (CASE
    WHEN COUNT(table_name) <= 0 THEN FALSE
    ELSE TRUE
  END) INTO existenciaTabelaImp_Fabricante
FROM information_schema.tables
WHERE table_catalog = '$nomedatabase_clean_chinchila_imp'
  AND table_schema = 'public'
  AND table_name = 'imp_fabricante';

IF (existenciaTabelaImp_Fabricante = FALSE) then
raise exception 'Não é possível continuar, a tabela imp_fabricante não existe!';
end IF;

SELECT
  (CASE
    WHEN COUNT(table_name) <= 0 THEN FALSE
    ELSE TRUE
  END) INTO existenciaTabelaImp_TabDescontosClassificacao
FROM information_schema.tables
WHERE table_catalog = '$nomedatabase_clean_chinchila_imp'
  AND table_schema = 'public'
  AND table_name = 'imp_tabdescontosclassificacao';

IF (existenciaTabelaImp_TabDescontosClassificacao = FALSE) then
raise exception 'Não é possível continuar, a tabela imp_tabdescontosclassificacao não existe!';
end IF;

SELECT
  (CASE
    WHEN COUNT(table_name) <= 0 THEN FALSE
    ELSE TRUE
  END) INTO existenciaTabelaImp_TabDescontosProduto
FROM information_schema.tables
WHERE table_catalog = '$nomedatabase_clean_chinchila_imp'
  AND table_schema = 'public'
  AND table_name = 'imp_tabdescontosproduto';

IF (existenciaTabelaImp_TabDescontosProduto = FALSE) then
raise exception 'Não é possível continuar, a tabela imp_tabdescontosproduto não existe!';
end IF;

SELECT
  (CASE
    WHEN COUNT(table_name) <= 0 THEN FALSE
    ELSE TRUE
  END) INTO existenciaTabelaImp_TabDescontos
FROM information_schema.tables
WHERE table_catalog = '$nomedatabase_clean_chinchila_imp'
  AND table_schema = 'public'
  AND table_name = 'imp_tabdescontos';

IF (existenciaTabelaImp_TabDescontos = FALSE) then
raise exception 'Não é possível continuar, a tabela imp_tabdescontos não existe!';
end IF;

SELECT
  (CASE
    WHEN COUNT(table_name) <= 0 THEN FALSE
    ELSE TRUE
  END) INTO existenciaTabelaImp_ItemCadernoOferta
FROM information_schema.tables
WHERE table_catalog = '$nomedatabase_clean_chinchila_imp'
  AND table_schema = 'public'
  AND table_name = 'imp_itemcadernooferta';

IF (existenciaTabelaImp_ItemCadernoOferta = FALSE) then
raise exception 'Não é possível continuar, a tabela imp_itemcadernooferta não existe!';
end IF;

SELECT
  (CASE
    WHEN COUNT(table_name) <= 0 THEN FALSE
    ELSE TRUE
  END) INTO existenciaTabelaImp_CadernoOferta
FROM information_schema.tables
WHERE table_catalog = '$nomedatabase_clean_chinchila_imp'
  AND table_schema = 'public'
  AND table_name = 'imp_cadernooferta';

IF (existenciaTabelaImp_CadernoOferta = FALSE) then
raise exception 'Não é possível continuar, a tabela imp_cadernooferta não existe!';
end IF;

SELECT
  (CASE
    WHEN COUNT(table_name) <= 0 THEN FALSE
    ELSE TRUE
  END) INTO existenciaTabelaImp_Classificacao
FROM information_schema.tables
WHERE table_catalog = '$nomedatabase_clean_chinchila_imp'
  AND table_schema = 'public'
  AND table_name = 'imp_classificacao';

IF (existenciaTabelaImp_Classificacao = FALSE) then
raise exception 'Não é possível continuar, a tabela imp_classificacao não existe!';
end IF;

SELECT
  (CASE
    WHEN COUNT(table_name) <= 0 THEN FALSE
    ELSE TRUE
  END) INTO existenciaTabelaImp_GrupoRemarcacao
FROM information_schema.tables
WHERE table_catalog = '$nomedatabase_clean_chinchila_imp'
  AND table_schema = 'public'
  AND table_name = 'imp_gruporemarcacao';

IF (existenciaTabelaImp_GrupoRemarcacao = FALSE) then
raise exception 'Não é possível continuar, a tabela imp_gruporemarcacao não existe!';
end IF;

SELECT
  (CASE
    WHEN COUNT(table_name) <= 0 THEN FALSE
    ELSE TRUE
  END) INTO existenciaTabelaImp_Versao
FROM information_schema.tables
WHERE table_catalog = '$nomedatabase_clean_chinchila_imp'
  AND table_schema = 'public'
  AND table_name = 'imp_versao';

IF (existenciaTabelaImp_Versao = TRUE) then
raise exception 'Não é possível continuar, a tabela imp_versao já existe!';
end IF;

-- ALTERA A IMP_CLIENTE
ALTER TABLE imp_cliente
ADD Ret_ContatoCelular2ID int8,
ADD Celular2 varchar(16);
COMMENT ON COLUMN Imp_Cliente.Ret_ContatoCelular2ID IS 'ID Entidade|ID da entidade salva no Chinchila';

-- ALTERA A IMP_CREDIARIO
ALTER TABLE imp_crediario
ADD Ret_ContatoCelular2ID int8,
ADD Celular2 varchar(16);
COMMENT ON COLUMN Imp_Crediario.Ret_ContatoCelular2ID IS 'ID Entidade|ID da entidade salva no Chinchila';

-- ALTERA A IMP_DEPENDENTECLIENTE
ALTER TABLE imp_dependentecliente
ADD Ret_ContatoCelular2ID int8,
ADD Celular2 varchar(16);
COMMENT ON COLUMN Imp_DependenteCliente.Ret_ContatoCelular2ID IS 'ID Entidade|ID da entidade salva no Chinchila';

-- ALTERA A IMP_FORNECEDOR
ALTER TABLE imp_fornecedor
ADD Ret_ContatoCelular2ID int8,
ADD Celular2 varchar(16);
COMMENT ON COLUMN Imp_Fornecedor.Ret_ContatoCelular2ID IS 'ID Entidade|ID da entidade salva no Chinchila';

-- ALTERA A IMP_FABRICANTE
ALTER TABLE imp_fabricante
ADD Ret_ContatoCelular2ID int8,
ADD Celular2 varchar(16);
COMMENT ON COLUMN Imp_Fabricante.Ret_ContatoCelular2ID IS 'ID Entidade|ID da entidade salva no Chinchila';

-- ALTERA A IMP_PRODUTO
ALTER TABLE imp_produto
ADD Status char(1) DEFAULT 'A' NOT NULL,
ADD ListaDcb char(1);
COMMENT ON COLUMN Imp_Produto.Status IS 'Status|Status do Produto';
COMMENT ON COLUMN Imp_Produto.ListaDcb IS 'Lista Dcb|Lista Dbc do produto que informa os fármacos ou princípios ativos utilizados no produto';

-- CRIA A IMP_ICMSPRODUTO
CREATE TABLE Imp_IcmsProduto (
Ret_Status char(1) DEFAULT 'N' NOT NULL,
Ret_Erro text,
Ret_IcmsProdutoID int8,
Ret_TotalizadorFiscalID int8,
Imp_ProdutoID varchar(100) NOT NULL,
PerfilIcmsSnID int8,
PerfilIcmsID int8,
Estado varchar(2) NOT NULL,
PRIMARY KEY (Imp_ProdutoID, Estado));
COMMENT ON COLUMN Imp_IcmsProduto.Ret_Status IS 'Status|Status da importação (N=Não Importado, S=Sucesso, E=Erro, I=Ignorado)';
COMMENT ON COLUMN Imp_IcmsProduto.Ret_Erro IS 'Erro|Mensagem de erro que ocorreu na importação';
COMMENT ON COLUMN Imp_IcmsProduto.Ret_IcmsProdutoID IS 'ID Entidade|ID da entidade salva no Chinchila';
COMMENT ON COLUMN Imp_IcmsProduto.Ret_TotalizadorFiscalID IS 'ID Entidade|ID da entidade salva no Chinchila';
COMMENT ON COLUMN Imp_IcmsProduto.PerfilIcmsSnID IS 'PerfilIcmsSnID|ID do registro referente ao regime simples nacional correspondente na Entidade PerfilIcms do Chinchila';
COMMENT ON COLUMN Imp_IcmsProduto.PerfilIcmsID IS 'PerfilIcmsID|ID do registro referente ao regime normal correspondente na Entidade PerfilIcms do Chinchila';
COMMENT ON COLUMN Imp_IcmsProduto.Estado IS 'Estado|Sigla do estado referente as unidades federativas do Brasil';
ALTER TABLE Imp_IcmsProduto ADD CONSTRAINT FK_Imp_Produto_Imp_PerfilIcms FOREIGN KEY (Imp_ProdutoID) REFERENCES Imp_Produto (ID);

--ALTERA A IMP_PRODUTO
ALTER TABLE Imp_Produto
ADD CestID int8,
ADD PerfilPISSnID int8,
ADD PerfilCofinsSnID int8,
ADD PerfilPISID int8,
ADD PerfilCofinsID int8;
COMMENT ON COLUMN Imp_Produto.CestID IS 'CestID|ID do registro correspondente na Entidade Cest do Chinchila';
COMMENT ON COLUMN Imp_Produto.PerfilPISSnID IS 'PerfilPISSnID|ID do registro referente ao regime simples nacional correspondente na Entidade PerfilPIS do Chinchila';
COMMENT ON COLUMN Imp_Produto.PerfilCofinsSnID IS 'PerfilCofinsSnID|ID do registro referente ao regime simples nacional correspondente na Entidade PerfilCofins do Chinchila';
COMMENT ON COLUMN Imp_Produto.PerfilPISID IS 'PerfilPISID|ID do registro referente ao regime normal correspondente na Entidade PerfilPIS do Chinchila';
COMMENT ON COLUMN Imp_Produto.PerfilCofinsID IS 'PerfilCofinsID|ID do registro referente ao regime normal correspondente na Entidade PerfilCofins do Chinchila';

ALTER TABLE Imp_Produto DROP COLUMN Ret_TotalizadorFiscalID;

-- ALTERA A IMP_CREDIARIO RETIRANDO A IMP_TABDESCONTOSID E COLOCA IMP_CADERNOOFERTAID
ALTER TABLE Imp_Crediario DROP COLUMN Imp_TabDescontosID;

-- DELETA IMP_TABDESCONTOSCLASSIFICACAO
ALTER TABLE Imp_TabDescontosClassificacao DROP CONSTRAINT IF EXISTS FKImp_TabDes522579;
ALTER TABLE Imp_TabDescontosClassificacao DROP CONSTRAINT IF EXISTS FKImp_TabDes28787;
DROP TABLE IF EXISTS Imp_TabDescontosClassificacao CASCADE;

-- DELETA IMP_TABDESCONTOSPRODUTO
ALTER TABLE Imp_TabDescontosProduto DROP CONSTRAINT IF EXISTS FKImp_TabDes906779;
ALTER TABLE Imp_TabDescontosProduto DROP CONSTRAINT IF EXISTS FKImp_TabDes587276;
DROP TABLE IF EXISTS Imp_TabDescontosProduto CASCADE;

-- DELETA IMP_TABDESCONTOS
DROP TABLE IF EXISTS Imp_TabDescontos CASCADE;

-- DELETA A IMP_ITEMCADERNOOFERTA
ALTER TABLE Imp_ItemCadernoOferta DROP CONSTRAINT IF EXISTS FKImp_ItemCa108948;
ALTER TABLE Imp_ItemCadernoOferta DROP CONSTRAINT IF EXISTS fkimp_itemca113214;
DROP TABLE IF EXISTS Imp_ItemCadernoOferta CASCADE;

-- DELETA AS TABELAS QUE NÃO EXISTEM NO DIAGRAMA REFERENTE A CADERNOS DE OFERTAS
DROP TABLE IF EXISTS imp_itemcadernooferta_class;
DROP TABLE IF EXISTS imp_itemcadernooferta_fabric;
DROP TABLE IF EXISTS imp_itemcadernooferta_gruporem;

-- RECRIA IMP_ITEMCADERNOOFERTA
CREATE TABLE Imp_ItemCadernoOferta (
  Ret_Status                  char(1) DEFAULT 'N' NOT NULL, 
  Ret_Erro                    text, 
  Ret_ItemCadernoOfertaID     int8, 
  Imp_CadernoOfertaID         varchar(100), 
  Imp_ProdutoID               varchar(100), 
  Imp_FabricanteID            varchar(100), 
  Imp_ClassificacaoID         varchar(100), 
  Imp_GrupoRemarcacaoID       varchar(100), 
  TipoOferta                  char(1) DEFAULT 'P' NOT NULL, 
  PrecoOferta                 numeric(15, 4), 
  DescontoOferta              numeric(15, 4), 
  Leve                        int4, 
  Pague                       int4, 
  DescontoLevePague           numeric(15, 4),
  Markup                      numeric(15, 4), 
  DescontoPorQtdTipo          char(1) default 'A' not null, 
  DescontoPorQtdVendaAcimaQtd char(1) default 'A' not null,
CONSTRAINT UQ_Imp_CadernoOferta_Imp_Produto UNIQUE (Imp_CadernoOfertaID, Imp_ProdutoID),
CONSTRAINT UQ_Imp_ItemCadernoOferta_Imp_Fabricante UNIQUE (Imp_CadernoOfertaID, Imp_FabricanteID),
CONSTRAINT UQ_Imp_ItemCadernoOferta_Imp_Classificacao UNIQUE (Imp_CadernoOfertaID, Imp_ClassificacaoID),
CONSTRAINT UQ_Imp_ItemCadernoOferta_Imp_GrupoRemarcacao UNIQUE (Imp_CadernoOfertaID, Imp_GrupoRemarcacaoID));
COMMENT ON COLUMN Imp_ItemCadernoOferta.Ret_Status IS 'Status|Status da importação (N=Não Importado, S=Sucesso, E=Erro, I=Ignorado)';
COMMENT ON COLUMN Imp_ItemCadernoOferta.Ret_Erro IS 'Erro|Mensagem de erro que ocorreu na importação';
COMMENT ON COLUMN Imp_ItemCadernoOferta.Ret_ItemCadernoOfertaID IS 'ID Entidade|ID da entidade salva no Chinchila';
COMMENT ON COLUMN Imp_ItemCadernoOferta.TipoOferta IS 'Tipo de Oferta|Tipo de Oferta a ser aplicado no item do Caderno de Oferta';
COMMENT ON COLUMN Imp_ItemCadernoOferta.PrecoOferta IS 'Preço Oferta|Preço de Oferta do item';
COMMENT ON COLUMN Imp_ItemCadernoOferta.DescontoOferta IS '% Desconto|Porcentagem de Desconto a ser aplicado no item em Oferta';
COMMENT ON COLUMN Imp_ItemCadernoOferta.Leve IS 'Leve|Quantidade de Embalagens a ser levada';
COMMENT ON COLUMN Imp_ItemCadernoOferta.Pague IS 'Pague|Quantidade de Embalagens a ser paga';
COMMENT ON COLUMN Imp_ItemCadernoOferta.DescontoLevePague IS 'Desconto Leve Pague|Desconto em porcentagem a ser aplicado no item';
COMMENT ON COLUMN Imp_ItemCadernoOferta.Markup IS 'Markup|Markup a ser aplicado no item do Caderno de Oferta';
COMMENT ON COLUMN Imp_ItemCadernoOferta.DescontoPorQtdTipo IS 'DescontoPorQtdTipo|DescontoPorQtdTipo a ser aplicado no item do Caderno de Oferta';
COMMENT ON COLUMN Imp_ItemCadernoOferta.DescontoPorQtdVendaAcimaQtd IS 'DescontoPorQtdVendaAcimaQtd|DescontoPorQtdVendaAcimaQtd a ser aplicado no item do Caderno de Oferta';
ALTER TABLE Imp_ItemCadernoOferta ADD CONSTRAINT FK_Imp_CadernoOferta_Imp_ItemCadernoOferta FOREIGN KEY (Imp_CadernoOfertaID) REFERENCES Imp_CadernoOferta (ID);
ALTER TABLE Imp_ItemCadernoOferta ADD CONSTRAINT FK_Imp_Classificacao_Imp_ItemCadernoOferta FOREIGN KEY (Imp_ClassificacaoID) REFERENCES Imp_Classificacao (ID);
ALTER TABLE Imp_ItemCadernoOferta ADD CONSTRAINT FK_Imp_Fabricante_Imp_ItemCadernoOferta FOREIGN KEY (Imp_FabricanteID) REFERENCES Imp_Fabricante (ID);
ALTER TABLE Imp_ItemCadernoOferta ADD CONSTRAINT FK_Imp_GrupoRemarcacao_Imp_ItemCadernoOferta FOREIGN KEY (Imp_GrupoRemarcacaoID) REFERENCES Imp_GrupoRemarcacao (ID);
ALTER TABLE Imp_ItemCadernoOferta ADD CONSTRAINT FK_Imp_Produto_Imp_ItemCadernoOferta FOREIGN KEY (Imp_ProdutoID) REFERENCES Imp_Produto (ID);

-- CRIA A IMP_VERSAO
CREATE TABLE Imp_Versao (
  Versao varchar(30) not null,
  DataHoraAtualizacao timestamp default current_timestamp not null);

-- INSERE A VERSÃO ATUAL
INSERT INTO Imp_Versao (Versao) VALUES ('2.0.0');

-- DÁ AS PERMISSÕES AO CHINCHILA PARA MANUSEAR AS TABELAS
GRANT SELECT,INSERT, UPDATE, DELETE  ON ALL TABLES IN SCHEMA public TO chinchila;

-- A FUNÇÃO SE AUTO DROPA AUTOMATICAMENTE
DROP FUNCTION IF EXISTS public.updates_2_0_0();

END;
$BODY$;

ALTER FUNCTION public.updates_2_0_0()
    OWNER TO chinchila;