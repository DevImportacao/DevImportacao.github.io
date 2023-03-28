CREATE OR REPLACE FUNCTION public.updates_2_1_0()\n
    RETURNS void\n
    LANGUAGE 'plpgsql'\n
    COST 100\n
    VOLATILE PARALLEL UNSAFE\n
AS $BODY$\n
DECLARE\n
existenciaTabelaImp_Prescritor boolean;\n
existenciaTabelaImp_PrecoProdutoUnidadeNegocio boolean;\n
existenciaTabelaImp_ItemCadernoOfertaQuantidade boolean;\n
existenciaTabelaImp_Versao boolean;\n
\n
BEGIN\n
\n
SELECT\n
  (CASE\n
    WHEN COUNT(table_name) <= 0 THEN FALSE\n
    ELSE TRUE\n
  END) INTO existenciaTabelaImp_Prescritor\n
FROM information_schema.tables\n
WHERE table_catalog = '$nomedatabase_clean_chinchila_imp'\n
  AND table_schema = 'public'\n
  AND table_name = 'imp_prescritor';\n
\n
IF (existenciaTabelaImp_Prescritor = TRUE) then\n
raise exception 'Não é possível continuar, a tabela imp_prescritor já existe!';\n
end IF;\n
\n
SELECT\n
  (CASE\n
    WHEN COUNT(table_name) <= 0 THEN FALSE\n
    ELSE TRUE\n
  END) INTO existenciaTabelaImp_PrecoProdutoUnidadeNegocio\n
FROM information_schema.tables\n
WHERE table_catalog = '$nomedatabase_clean_chinchila_imp'\n
  AND table_schema = 'public'\n
  AND table_name = 'imp_precoprodutounidadenegocio';\n
\n
IF (existenciaTabelaImp_PrecoProdutoUnidadeNegocio = TRUE) then\n
raise exception 'Não é possível continuar, a tabela imp_precoprodutounidadenegocio já existe!';\n
end IF;\n
\n
SELECT\n
  (CASE\n
    WHEN COUNT(table_name) <= 0 THEN FALSE\n
    ELSE TRUE\n
  END) INTO existenciaTabelaImp_ItemCadernoOfertaQuantidade\n
FROM information_schema.tables\n
WHERE table_catalog = '$nomedatabase_clean_chinchila_imp'\n
  AND table_schema = 'public'\n
  AND table_name = 'imp_itemcadernoofertaquantidade';\n
\n
IF (existenciaTabelaImp_ItemCadernoOfertaQuantidade = FALSE) then\n
raise exception 'Não é possível continuar, a tabela imp_itemcadernoofertaquantidade não existe!';\n
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
IF (existenciaTabelaImp_Versao = FALSE) then\n
raise exception 'Não é possível continuar, a tabela imp_versao não existe!';\n
end IF;\n
\n
-- CRIA A IMP_PRESCRITOR\n
CREATE TABLE Imp_Prescritor (\n
  Ret_Status       char(1) DEFAULT 'N' NOT NULL, \n
  Ret_Erro         text, \n
  Ret_PrescritorID int8, \n
  ID               varchar(100) NOT NULL, \n
  Status           char(1) DEFAULT 'A' NOT NULL, \n
  Nome             varchar(100) NOT NULL, \n
  Numero           int8 NOT NULL, \n
  TipoConselho     char(1) DEFAULT 'M' NOT NULL, \n
  Cidade           varchar(40), \n
  Estado           varchar(2) NOT NULL, \n
  DataInscricao    timestamp, \n
  PRIMARY KEY (ID, Numero));\n
COMMENT ON COLUMN Imp_Prescritor.ID IS 'Identificação|Identificação da entidade no sistema do qual está sendo importado. Se a identificação for uma chave composta, pode-se utilizar aqui uma concatenação dos campos usando "|" como separador, ou qualquer outra identificação do gênero';\n
COMMENT ON COLUMN Imp_Prescritor.Ret_Status IS 'Status|Status da importação (N=Não Importado, S=Sucesso, E=Erro, I=Ignorado)';\n
COMMENT ON COLUMN Imp_Prescritor.Ret_Erro IS 'Erro|Mensagem de erro que ocorreu na importação';\n
COMMENT ON COLUMN Imp_Prescritor.Ret_PrescritorID IS 'ID Entidade|ID da entidade salva no Chinchila';\n
COMMENT ON COLUMN Imp_Prescritor.Status IS 'Status|Status do Prescritor';\n
COMMENT ON COLUMN Imp_Prescritor.Nome IS 'Nome|Nome do Prescritor';\n
COMMENT ON COLUMN Imp_Prescritor.Numero IS 'Numero|Número do CRM, CRO e assim por diante';\n
COMMENT ON COLUMN Imp_Prescritor.TipoConselho IS 'TipoConselho| Tipo de conselho do prescritor, ou seja, se ele é médico, veterinário e assim por diante';\n
COMMENT ON COLUMN Imp_Prescritor.Cidade IS 'Cidade|Cidade do Prescritor';\n
COMMENT ON COLUMN Imp_Prescritor.Estado IS 'Estado|Estado do Prescritor';\n
COMMENT ON COLUMN Imp_Prescritor.DataInscricao IS 'DataInscricao|Data de Inscrição do Prescritor';\n
\n
-- CRIA A IMP_PRECOPRODUTOUNIDADENEGOCIO\n
CREATE TABLE Imp_PrecoProdutoUnidadeNegocio (\n
  Ret_Status                         char(1) DEFAULT 'N' NOT NULL, \n
  Ret_Erro                           text, \n
  Ret_PrecoEmbalagemUnidadeNegocioID int8, \n
  Imp_UnidadeNegocioID               varchar(100) NOT NULL, \n
  Imp_ProdutoID                      varchar(100) NOT NULL, \n
  PrecoReferencial                   numeric(15, 4) NOT NULL, \n
  PrecoVenda                         numeric(15, 4) NOT NULL,\n
PRIMARY KEY (Imp_UnidadeNegocioID, Imp_ProdutoID));\n
COMMENT ON COLUMN Imp_PrecoProdutoUnidadeNegocio.Ret_Status IS 'Status|Status da importação (N=Não Importado, S=Sucesso, E=Erro, I=Ignorado)';\n
COMMENT ON COLUMN Imp_PrecoProdutoUnidadeNegocio.Ret_Erro IS 'Erro|Mensagem de erro que ocorreu na importação';\n
COMMENT ON COLUMN Imp_PrecoProdutoUnidadeNegocio.Ret_PrecoEmbalagemUnidadeNegocioID IS 'ID Entidade|ID da entidade salva no Chinchila';\n
COMMENT ON COLUMN Imp_PrecoProdutoUnidadeNegocio.PrecoReferencial IS 'PrecoReferencial|Preço referência para a embalagem na unidade de negócio';\n
COMMENT ON COLUMN Imp_PrecoProdutoUnidadeNegocio.PrecoVenda IS 'PrecoVenda|Preço de venda para a embalagem na unidade de negócio';\n
ALTER TABLE Imp_PrecoProdutoUnidadeNegocio ADD CONSTRAINT FK_Imp_Produto_Imp_PrecoProdutoUnidadeNegocio FOREIGN KEY (Imp_ProdutoID) REFERENCES Imp_Produto (ID);\n
ALTER TABLE Imp_PrecoProdutoUnidadeNegocio ADD CONSTRAINT FK_Imp_UnidadeNegocio_Imp_PrecoProdutoUnidadeNegocio FOREIGN KEY (Imp_UnidadeNegocioID) REFERENCES Imp_UnidadeNegocio (ID);\n
\n
-- REMOVE AS COLUNAS DE ITEM CADERNO OFERTA QUANTIDADE DA IMP_ITEMCADERNOOFERTA\n
ALTER TABLE imp_itemcadernooferta DROP COLUMN DescontoPorQtdVendaAcimaQtd;\n
ALTER TABLE imp_itemcadernooferta DROP COLUMN DescontoPorQtdTipo;\n
\n
-- CRIA A IMP_ITEMCADERNOOFERTAQUANTIDADE\n
CREATE TABLE Imp_ItemCadernoOfertaQuantidade (\n
  Ret_Status                        char(1) default 'N' NOT NULL, \n
  Ret_Erro                          text, \n
  Ret_ItemCadernoOfertaID           int8, \n
  Ret_ItemCadernoOfertaQuantidadeID int8, \n
  Imp_CadernoOfertaID               varchar(100) NOT NULL, \n
  Imp_ProdutoID                     varchar(100), \n
  Imp_FabricanteID                  varchar(100), \n
  Imp_ClassificacaoID               varchar(100), \n
  Imp_GrupoRemarcacaoID             varchar(100), \n
  Quantidade                        int4 NOT NULL, \n
  Desconto                          numeric(15, 4), \n
  Preco                             numeric(15, 4), \n
  PrecoTotal                        numeric(15, 4), \n
  Markup                            numeric(15, 4), \n
  DescontoPorQtdVendaAcimaQtd       char DEFAULT 'A' NOT NULL, \n
  DescontoPorQtdTipo                char DEFAULT 'A' NOT NULL,\n
CONSTRAINT UQ_Imp_ItemCadernoOfertaQuantidade_Imp_CadernoOferta_Imp_Produto UNIQUE (Imp_CadernoOfertaID, Imp_ProdutoID, Quantidade),\n
CONSTRAINT UQ_Imp_ItemCadernoOfertaQuantidade_Imp_CadernoOferta_Imp_Fabricante UNIQUE (Imp_CadernoOfertaID, Imp_FabricanteID, Quantidade),\n
CONSTRAINT UQ_Imp_ItemCadernoOfertaQuantidade_Imp_CadernoOferta_Imp_Classificacao UNIQUE (Imp_CadernoOfertaID, Imp_ClassificacaoID, Quantidade),\n
CONSTRAINT UQ_Imp_ItemCadernoOfertaQuantidade_Imp_CadernoOferta_Imp_GrupoRemarcacao UNIQUE (Imp_CadernoOfertaID, Imp_GrupoRemarcacaoID, Quantidade));\n
COMMENT ON COLUMN Imp_ItemCadernoOfertaQuantidade.Ret_Status IS 'Status|Status da importação (N=Não Importado, S=Sucesso, E=Erro, I=Ignorado)';\n
COMMENT ON COLUMN Imp_ItemCadernoOfertaQuantidade.Ret_Erro IS 'Erro|Mensagem de erro que ocorreu na importação';\n
COMMENT ON COLUMN Imp_ItemCadernoOfertaQuantidade.Ret_ItemCadernoOfertaQuantidadeID IS 'ID Entidade|ID da entidade salva no Chinchila';\n
COMMENT ON COLUMN Imp_ItemCadernoOfertaQuantidade.Ret_ItemCadernoOfertaID IS 'ID Entidade|ID da entidade salva no Chinchila';\n
COMMENT ON COLUMN Imp_ItemCadernoOfertaQuantidade.Quantidade IS 'Quantidade|Quantidade do item de caderno de oferta';\n
COMMENT ON COLUMN Imp_ItemCadernoOfertaQuantidade.Desconto IS 'Desconto|Desconto do item de caderno de oferta';\n
COMMENT ON COLUMN Imp_ItemCadernoOfertaQuantidade.Preco IS 'Preco|Preço do item do caderno de oferta';\n
COMMENT ON COLUMN Imp_ItemCadernoOfertaQuantidade.PrecoTotal IS 'PrecoTotal|Preço Total do item de caderno de oferta';\n
COMMENT ON COLUMN Imp_ItemCadernoOfertaQuantidade.Markup IS 'Markup|Markup do item de caderno de oferta';\n
COMMENT ON COLUMN Imp_ItemCadernoOfertaQuantidade.DescontoPorQtdVendaAcimaQtd IS 'DescontoPorQtdVendaAcimaQtd|DescontoPorQtdVendaAcimaQtd a ser aplicado no item do Caderno de Oferta';\n
COMMENT ON COLUMN Imp_ItemCadernoOfertaQuantidade.DescontoPorQtdTipo IS 'DescontoPorQtdTipo|DescontoPorQtdTipo a ser aplicado no item do Caderno de Oferta';\n
ALTER TABLE Imp_ItemCadernoOfertaQuantidade ADD CONSTRAINT FK_Imp_CadernoOferta_Imp_ItemCadernoOfertaQuantidade FOREIGN KEY (Imp_CadernoOfertaID) REFERENCES Imp_CadernoOferta (ID);\n
ALTER TABLE Imp_ItemCadernoOfertaQuantidade ADD CONSTRAINT FK_Imp_Classificacao_Imp_ItemCadernoOfertaQuantidade FOREIGN KEY (Imp_ClassificacaoID) REFERENCES Imp_Classificacao (ID);\n
ALTER TABLE Imp_ItemCadernoOfertaQuantidade ADD CONSTRAINT FK_Imp_Fabricante_Imp_ItemCadernoOfertaQuantidade FOREIGN KEY (Imp_FabricanteID) REFERENCES Imp_Fabricante (ID);\n
ALTER TABLE Imp_ItemCadernoOfertaQuantidade ADD CONSTRAINT FK_Imp_GrupoRemarcacao_Imp_ItemCadernoOfertaQuantidade FOREIGN KEY (Imp_GrupoRemarcacaoID) REFERENCES Imp_GrupoRemarcacao (ID);\n
ALTER TABLE Imp_ItemCadernoOfertaQuantidade ADD CONSTRAINT FK_Imp_Produto_Imp_ItemCadernoOfertaQuantidade FOREIGN KEY (Imp_ProdutoID) REFERENCES Imp_Produto (ID);\n
\n
-- INSERE A VERSÃO ATUAL\n
INSERT INTO Imp_Versao (Versao) VALUES ('2.1.0');\n
\n
-- DÁ AS PERMISSÕES AO CHINCHILA PARA MANUSEAR AS TABELAS\n
GRANT SELECT,INSERT, UPDATE, DELETE  ON ALL TABLES IN SCHEMA public TO chinchila;\n
\n
-- A FUNÇÃO SE AUTO DROPA AUTOMATICAMENTE\n
DROP FUNCTION IF EXISTS public.updates_2_1_0();\n
\n
END;\n
$BODY$;\n
\n
ALTER FUNCTION public.updates_2_1_0()\n
    OWNER TO chinchila;\n