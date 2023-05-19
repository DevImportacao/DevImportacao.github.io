CREATE OR REPLACE PROCEDURE public.updates_2_2_1()\n
    LANGUAGE plpgsql\n
AS $BODY$\n
DECLARE\n
existenciaTabelaImp_Versao boolean;\n
existenciaFuncoesDblink BOOLEAN;\n
existenciaExtensaoDblink BOOLEAN;\n
usuarioAtual VARCHAR;\n
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
-- CRIA A EXTENSÃO DO DBLINK\n
SELECT\n
  (CASE\n
    WHEN COUNT(extname) <= 0 THEN FALSE\n
    ELSE TRUE\n
  END) INTO existenciaExtensaoDblink\n
FROM pg_catalog.pg_extension\n
WHERE extname = 'dblink';\n
 \n
SELECT\n
  (CASE\n
    WHEN COUNT(routine_name) <= 0 THEN FALSE\n
    ELSE TRUE\n
  END) INTO existenciaFuncoesDblink\n
FROM information_schema.routines\n
WHERE routine_type = 'FUNCTION'\n
  AND routine_schema = 'public'\n
	AND routine_name ilike 'dblink%';\n
 \n
SELECT CURRENT_USER INTO usuarioAtual;\n
 \n
IF (usuarioAtual <> 'postgres') THEN\n
    raise exception 'Não é possível continuar, a função deve ser executada com o usuário POSTGRES para o manuseio de funções!';\n
  ELSE \n
\n
  IF (existenciaExtensaoDblink = FALSE AND existenciaFuncoesDblink = TRUE) THEN\n
  		DROP FUNCTION IF EXISTS dblink (text, text);\n
  		DROP FUNCTION IF EXISTS dblink (text, text, BOOLEAN);\n
  		DROP FUNCTION IF EXISTS dblink (text);\n
  		DROP FUNCTION IF EXISTS dblink (text, BOOLEAN);\n
  		DROP FUNCTION IF EXISTS dblink_exec (text, text);\n
  END IF;\n
\n
  CREATE EXTENSION IF NOT EXISTS dblink;\n
END IF;\n
\n
-- INSERE A VERSÃO ATUAL\n
INSERT INTO Imp_Versao (Versao) VALUES ('2.2.1');\n
\n
-- DÁ AS PERMISSÕES AO CHINCHILA PARA MANUSEAR AS TABELAS\n
GRANT SELECT,INSERT, UPDATE, DELETE  ON ALL TABLES IN SCHEMA public TO chinchila;\n
\n
-- A FUNÇÃO SE AUTO DROPA AUTOMATICAMENTE\n
DROP PROCEDURE IF EXISTS public.updates_2_2_1();\n
\n
END; $BODY$;\n
\n
ALTER PROCEDURE public.updates_2_2_1() OWNER TO chinchila;\n