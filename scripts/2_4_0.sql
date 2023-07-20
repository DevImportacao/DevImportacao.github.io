CREATE OR REPLACE PROCEDURE public.updates_2_4_0()\n
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
WHERE table_catalog = '$nomedatabase_clean_chinchila_imp'\n
  AND table_schema = 'public'\n
  AND table_name = 'imp_versao';\n
\n
IF (existenciaTabelaImp_Versao = FALSE) then\n
raise exception 'Não é possível continuar, a tabela imp_versao não existe!';\n
end IF;\n
\n
-- DROPA A IMP_CUSTO\n
alter table Imp_Custo drop constraint if exists FKImp_Custo378987;\n
alter table Imp_Custo drop constraint if exists FKImp_Custo449337;\n
drop table if exists Imp_Custo cascade;\n
\n
-- RECRIA A IMP_CUSTO\n
create table Imp_Custo (\n
  Ret_Status                       char(1) default 'N' not null, \n
  Ret_Erro                         text, \n
  Ret_CustoProdutoID               int8, \n
  Ret_ItemNotaFiscalCustoProdutoId int8, \n
  Imp_ProdutoID                    varchar(100) not null, \n
  Imp_UnidadeNegocioID             varchar(100) not null, \n
  Custo                            numeric(15, 4) not null, \n
  CustoMedio                       numeric(15, 4) not null, \n
  primary key (Imp_ProdutoID, \n
  Imp_UnidadeNegocioID));\n
comment on column Imp_Custo.Ret_Status is 'Status|Status da importação (N=Não Importado, S=Sucesso, E=Erro, I=Ignorado)';\n
comment on column Imp_Custo.Ret_Erro is 'Erro|Mensagem de erro que ocorreu na importação';\n
comment on column Imp_Custo.Ret_CustoProdutoID is 'ID Entidade|ID da entidade salva no Chinchila';\n
comment on column Imp_Custo.Ret_ItemNotaFiscalCustoProdutoId is 'Ret_ItemNotaFiscalCustoProdutoId|ID do item da nota fiscal que atualizou o custo do produto antes do custo da importação vir';\n
alter table Imp_Custo add constraint FK_Imp_Produto_Imp_Custo foreign key (Imp_ProdutoID) references Imp_Produto (ID);\n
alter table Imp_Custo add constraint FK_Imp_UnidadeNegocio_Imp_Custo foreign key (Imp_UnidadeNegocioID) references Imp_UnidadeNegocio (ID);\n
\n
-- INSERE A VERSÃO ATUAL\n
INSERT INTO Imp_Versao (Versao) VALUES ('2.4.0');\n
\n
-- DÁ AS PERMISSÕES AO CHINCHILA PARA MANUSEAR AS TABELAS\n
GRANT SELECT,INSERT, UPDATE, DELETE  ON ALL TABLES IN SCHEMA public TO chinchila;\n
\n
-- A FUNÇÃO SE AUTO DROPA AUTOMATICAMENTE\n
DROP PROCEDURE IF EXISTS public.updates_2_4_0();\n
\n
END; $BODY$;\n
\n
ALTER PROCEDURE public.updates_2_4_0() OWNER TO chinchila;\n