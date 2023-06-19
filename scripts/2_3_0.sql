CREATE OR REPLACE PROCEDURE public.updates_2_3_0()\n
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
-- CRIA A FUNÇÃO retira_acentuacao\n
CREATE OR REPLACE FUNCTION retira_acentuacao(p_texto text)  \n
  RETURNS text AS  \n
 $$  \n
 SELECT TRANSLATE($1,  \n
 'áàâãåäÁÀÂÃÅÄéêèëẽÉÈÊẼËíìîïÍÌÎÏóôõòöøÓÔÒÕÖØúüùûÚÜÙÛçÇñÑýÝ\t\n\r''"',\n
'aaaaaaAAAAAAeeeeeEEEEEiiiiIIIIooooooOOOOOOuuuuUUUUcCnNyY     '\n
  );  \n
 $$  \n
 LANGUAGE sql VOLATILE  \n
 COST 100;\n
 \n
 ALTER FUNCTION public.retira_acentuacao(p_texto text)\n
    OWNER TO chinchila;\n
\n
-- CRIA A FUNÇÃO pre_verificacoes\n
CREATE OR REPLACE FUNCTION public.pre_verificacoes(referencia_importacao CHARACTER VARYING, nome_databaseoficial CHARACTER VARYING, host_baseoficial CHARACTER VARYING, porta_baseoficial CHARACTER VARYING)\n
    RETURNS void\n
    LANGUAGE 'plpgsql'\n
    COST 100\n
    VOLATILE PARALLEL UNSAFE\n
AS $$\n
DECLARE\n
existenciaDatabaseOficial BOOLEAN;\n
existenciaFuncaoValidateGtin BOOLEAN;\n
existenciaFuncaoReverse BOOLEAN;\n
existenciaFuncoesDblink BOOLEAN;\n
existenciaExtensaoDblink BOOLEAN;\n
existenciaTabelaTmpNomesCidades BOOLEAN;\n
nomeDatabaseAtual VARCHAR;\n
usuarioAtual VARCHAR;\n
quantidadeUnBaseOficial BIGINT;\n
quantidadeUnNaoImportadas BIGINT;\n
\n
BEGIN\n
\n
-- PEGA O NOME DA DATABASE ATUAL\n
SELECT current_database() INTO nomeDatabaseAtual;\n
\n
-- VERIFICA A EXISTÊNCIA DAS TABELAS, DATABASE E FUNÇÕES NECESSÁRIAS\n
SELECT\n
  (CASE\n
    WHEN COUNT(datname) <= 0 THEN FALSE\n
    ELSE TRUE\n
  END) INTO existenciaDatabaseOficial\n
FROM pg_database\n
WHERE datname = nome_databaseoficial;\n
\n
IF (existenciaDatabaseOficial = FALSE AND referencia_importacao <> 'DIA 02') THEN\n
raise exception 'Não é possível continuar, a database oficial não foi encontrada!';\n
END IF;\n
\n
SELECT\n
  (CASE\n
    WHEN COUNT(routine_name) <= 0 THEN FALSE\n
    ELSE TRUE\n
  END) INTO existenciaFuncaoValidateGtin\n
FROM information_schema.routines\n
WHERE routine_type = 'FUNCTION'\n
  AND routine_schema = 'public'\n
	AND routine_name = 'validate_gtin';\n
\n
IF (existenciaFuncaoValidateGtin = FALSE) THEN\n
raise exception 'Não é possível continuar, a função validate_gtin não existe!';\n
END IF;\n
\n
SELECT\n
  (CASE\n
    WHEN COUNT(routine_name) <= 0 THEN FALSE\n
    ELSE TRUE\n
  END) INTO existenciaFuncaoReverse\n
FROM information_schema.routines\n
WHERE routine_type = 'FUNCTION'\n
  AND routine_schema = 'public'\n
	AND routine_name = 'reverse';\n
\n
IF (existenciaFuncaoReverse = FALSE) THEN\n
raise exception 'Não é possível continuar, a função reverse não existe!';\n
END IF;\n
\n
SELECT\n
  (CASE\n
    WHEN COUNT(TABLE_NAME) <= 0 THEN FALSE\n
    ELSE TRUE\n
  END) INTO existenciaTabelaTmpNomesCidades\n
FROM information_schema.tables\n
WHERE table_catalog = nomeDatabaseAtual\n
  AND table_schema = 'public'\n
  AND TABLE_NAME = 'tmp_nomes_cidades';\n
\n
IF (existenciaTabelaTmpNomesCidades = FALSE) THEN\n
raise exception 'Não é possível continuar, a tabela tmp_nomes_cidades não existe!';\n
END IF;\n
\n
IF (referencia_importacao <> 'DIA 01' AND referencia_importacao <> 'DIA 02' AND referencia_importacao <> 'DIA 01/02') THEN\n
raise exception 'Referência de importação não encontrada!\n
\n
DIA 01: Executa somente as pré-verificações do DIA 01\n
DIA 02: Executa as pré-verificações de diferença do DIA 01 e as pré-verificações do DIA 02\n
DIA 01/02: Executa todas as pré-verificações do DIA 01 e todas as pré-verificações do DIA 02 de uma vez só\n
';\n
END IF;\n
\n
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
IF (existenciaExtensaoDblink = FALSE AND existenciaFuncoesDblink = TRUE) THEN\n
	IF (usuarioAtual <> 'postgres') THEN\n
		raise exception 'Não é possível continuar, a função deve ser executada com o usuário POSTGRES para o manuseio de funções!';\n
	ELSE \n
		DROP FUNCTION IF EXISTS dblink (text, text);\n
		DROP FUNCTION IF EXISTS dblink (text, text, BOOLEAN);\n
		DROP FUNCTION IF EXISTS dblink (text);\n
		DROP FUNCTION IF EXISTS dblink (text, BOOLEAN);\n
		DROP FUNCTION IF EXISTS dblink_exec (text, text);\n
\n
		CREATE EXTENSION IF NOT EXISTS dblink;\n
	END IF;\n
END IF;\n
\n
-------------------------------------------------------------- DIA 01 ----------------------------------------------------------------\n
\n
-------------------------------------------------------------- UNIDADE DE NEGÓCIO --------------------------------------------------------------\n
\n
IF (referencia_importacao = 'DIA 01' OR referencia_importacao = 'DIA 01/02') THEN\n
  -- Setar todas as unidades de negócio da imp para que movimentem estoque. Esse procedimento é necessário para que se possa\n
  -- importar custo padrão para todos os produtos e estoque zerado para todas as embalagens em todas as unidades de negócio\n
  -- que movimentam estoque. Caso nem todas movimentem, filtre somente as unidades desejadas.\n
  UPDATE imp_unidadenegocio SET movimentaestoque = TRUE;\n
\n
  -- Caso seja loja única, rode a query abaixo\n
  -- Rodar a query na imp e o resultado na base oficial\n
\n
  PERFORM dblink_connect('conexao_baseoficial', 'host='||host_baseoficial||' user=chinchila port='||porta_baseoficial||' password=chinchila dbname='||nome_databaseoficial||'');\n
\n
	WITH unidadenegocio_databaseoficial AS (\n
	SELECT\n
		*\n
	FROM dblink('conexao_baseoficial', 'SELECT COUNT(*) FROM unidadenegocio WHERE codigo <> ''CLOUD'';') AS DATA(quantidade_unidadesnegocios BIGINT)\n
	)\n
	SELECT\n
		quantidade_unidadesnegocios INTO quantidadeUnBaseOficial\n
	FROM unidadenegocio_databaseoficial;\n
\n
	SELECT\n
	  COUNT(*) INTO quantidadeUnNaoImportadas\n
	FROM imp_unidadenegocio\n
	WHERE ret_status <> 'S';\n
\n
IF (quantidadeUnBaseOficial = 1 AND quantidadeUnNaoImportadas > 0) THEN\n
  PERFORM\n
    dblink_exec('conexao_baseoficial',\n
                            'UPDATE unidadenegocio \n
                            SET nome = '||nome||',\n
                            codigo = '||codigo||',\n
                            cnpj = '||cnpj||', \n
                            movimentaestoque = true, \n
                            estado = '||estado||', \n
                            nomefantasia = '||nomefantasia||', \n
                            razaosocial = '||razaosocial||', \n
                            inscricaoestadual = '||inscricaoestadual||', \n
                            estadoinscricaoestadual = '||estadoinscricaoestadual||', \n
                            isentoinscricaoestadual = '||isentoinscricaoestadual||',\n
                            inscricaomunicipal = '||inscricaomunicipal||', \n
                            endereco = '||endereco||', \n
                            numero = '||numero||', \n
                            cep = '||cep||', \n
                            bairro = '||bairro||', \n
                            cidade = '||cidade||', \n
                            telefone = '||telefone||', \n
                            fax = '||fax||' \n
                            where id = 1')\n
  FROM (\n
  SELECT\n
          ''''||nome||'''' AS nome,\n
	  '''01''' AS codigo,\n
          (CASE\n
            WHEN NULLIF(regexp_replace(cnpj, '[^0-9]', '', 'g'), '') IS NULL THEN 'NULL'\n
            ELSE ''''||regexp_replace(cnpj, '[^0-9]', '', 'g')||''''\n
          END) AS cnpj,\n
          ''''||estado||'''' AS estado,\n
          (CASE\n
            WHEN NULLIF(nomefantasia, '') IS NULL THEN 'NULL'\n
            ELSE ''''||nomefantasia||''''\n
          END) AS nomefantasia,\n
          (CASE\n
            WHEN NULLIF(razaosocial, '') IS NULL THEN 'NULL'\n
            ELSE ''''||razaosocial||''''\n
          END) AS razaosocial,\n
          (CASE\n
            WHEN NULLIF(inscricaoestadual, '') IS NULL THEN 'NULL'\n
            ELSE ''''||inscricaoestadual||''''\n
          END) AS inscricaoestadual,\n
          (CASE\n
            WHEN NULLIF(estadoinscricaoestadual, '') IS NULL THEN 'NULL'\n
            ELSE ''''||estadoinscricaoestadual||''''\n
          END) AS estadoinscricaoestadual,\n
          isentoinscricaoestadual,\n
          (CASE\n
            WHEN NULLIF(inscricaomunicipal, '') IS NULL THEN 'NULL'\n
            ELSE ''''||inscricaomunicipal||''''\n
          END) AS inscricaomunicipal,\n
          (CASE\n
            WHEN NULLIF(endereco, '') IS NULL THEN 'NULL'\n
            ELSE ''''||endereco||''''\n
          END) AS endereco,\n
          (CASE\n
            WHEN NULLIF(numero, '') IS NULL THEN 'NULL'\n
            ELSE ''''||numero||''''\n
          END) AS numero,\n
          (CASE\n
            WHEN NULLIF(regexp_replace(cep, '[^0-9]', '', 'g'), '') IS NULL THEN 'NULL'\n
            ELSE ''''||regexp_replace(cep, '[^0-9]', '', 'g')||''''\n
          END) AS cep,\n
          (CASE\n
            WHEN NULLIF(bairro, '') IS NULL THEN 'NULL'\n
            ELSE ''''||bairro||''''\n
          END) AS bairro,\n
          (CASE\n
            WHEN NULLIF(cidade, '') IS NULL THEN 'NULL'\n
            ELSE ''''||cidade||''''\n
          END) AS cidade,\n
          (CASE\n
            WHEN NULLIF(regexp_replace(telefone, '[^0-9]', '', 'g'), '') IS NULL THEN 'NULL'\n
            ELSE ''''||regexp_replace(telefone, '[^0-9]', '', 'g')||''''\n
          END) AS telefone,\n
          (CASE\n
            WHEN NULLIF(regexp_replace(fax, '[^0-9]', '', 'g'), '') IS NULL THEN 'NULL'\n
            ELSE ''''||regexp_replace(fax, '[^0-9]', '', 'g')||''''\n
          END) AS fax\n
  FROM imp_unidadenegocio\n
  ) AS dados_unidadenegocio\n
  WHERE (SELECT COUNT(*) FROM imp_unidadenegocio) = 1;\n
\n
END IF;\n
\n
  PERFORM dblink_disconnect('conexao_baseoficial');\n
\n
	-- Verificar se a importação que está sendo feito é para uma loja única, para uma rede que não possuirá Escritório. \n
  -- Se for loja única, a tabela "limpa" de Unidade de Negócio do A7Pharma já possui um registro para \n
  -- a unidade "ESC" com o ID = 1, e por isso  é necessário apenas marcar esse registro como sendo a UN importada,\n
  -- e depois alterar os dados dessa UN por dentro do sistema mesmo.\n
  UPDATE imp_unidadenegocio SET ret_status = 'S', ret_unidadenegocioid = 1  \n
    WHERE (SELECT COUNT(*) FROM imp_unidadenegocio) = 1;\n
END IF;\n
\n
-------------------------------------------------------------- FABRICANTE --------------------------------------------------------------\n
\n
-- Seta para null os campos que estiverem vazios('')\n
UPDATE imp_fabricante SET cpf = NULL WHERE cpf = '';\n
UPDATE imp_fabricante SET inscricaoestadual = NULL WHERE inscricaoestadual = '';\n
UPDATE imp_fabricante SET cnpj = NULL WHERE cnpj = '';\n
UPDATE imp_fabricante SET identidade = NULL WHERE identidade = '';\n
\n
-- Seta para null os campos que estiverem repetidos e com nome diferente.\n
-- CNPJ\n
UPDATE imp_fabricante AS t1 SET cnpj = NULL\n
FROM ( SELECT DISTINCT imp_fabricante.id\n
	FROM imp_fabricante AS imp_fabricante  \n
	JOIN imp_fabricante AS f ON f.cnpj = imp_fabricante.cnpj AND f.nome <> imp_fabricante.nome \n
	WHERE imp_fabricante.cnpj IS NOT NULL AND f.cnpj IS NOT NULL\n
	ORDER BY 1) AS t2\n
WHERE t1.id = t2.id;\n
\n
-- Inscrição Estadual\n
UPDATE imp_fabricante AS t1 SET inscricaoestadual = NULL\n
FROM ( SELECT DISTINCT imp_fabricante.id\n
	FROM imp_fabricante AS imp_fabricante  \n
	JOIN imp_fabricante AS f ON f.inscricaoestadual = imp_fabricante.inscricaoestadual AND f.nome <> imp_fabricante.nome \n
	WHERE imp_fabricante.inscricaoestadual IS NOT NULL AND f.inscricaoestadual IS NOT NULL\n
	ORDER BY 1) AS t2\n
WHERE t1.id = t2.id;\n
\n
-- CPF\n
UPDATE imp_fabricante AS t1 SET cpf = NULL\n
FROM ( SELECT DISTINCT imp_fabricante.id\n
	FROM imp_fabricante AS imp_fabricante  \n
	JOIN imp_fabricante AS f ON f.cpf = imp_fabricante.cpf AND f.nome <> imp_fabricante.nome \n
	WHERE imp_fabricante.cpf IS NOT NULL AND f.cpf IS NOT NULL\n
	ORDER BY 1) AS t2\n
WHERE t1.id = t2.id;\n
\n
-- Identidade\n
UPDATE imp_fabricante AS t1 SET identidade = NULL\n
FROM ( SELECT DISTINCT imp_fabricante.id\n
	FROM imp_fabricante AS imp_fabricante  \n
	JOIN imp_fabricante AS f ON f.identidade = imp_fabricante.identidade AND f.nome <> imp_fabricante.nome \n
	WHERE imp_fabricante.identidade IS NOT NULL AND f.identidade IS NOT NULL\n
	ORDER BY 1) AS t2\n
WHERE t1.id = t2.id;\n
\n
-- Normalização de telefones (remove qualquer carácter que não seja um número).\n
UPDATE imp_fabricante SET telefone = regexp_replace(telefone, '[^0-9]', '', 'g') WHERE telefone IS NOT NULL;\n
UPDATE imp_fabricante SET telefone2 = regexp_replace(telefone2, '[^0-9]', '', 'g') WHERE telefone2 IS NOT NULL;\n
UPDATE imp_fabricante SET celular = regexp_replace(celular, '[^0-9]', '', 'g') WHERE celular IS NOT NULL;\n
UPDATE imp_fabricante SET fax = regexp_replace(fax, '[^0-9]', '', 'g') WHERE fax IS NOT NULL;\n
UPDATE imp_fabricante SET telefone = NULL WHERE TRIM(telefone) = '';\n
UPDATE imp_fabricante SET telefone2 = NULL WHERE TRIM(telefone2) = '';\n
UPDATE imp_fabricante SET celular = NULL WHERE TRIM(celular) = '';\n
UPDATE imp_fabricante SET celular2 = NULL WHERE TRIM(celular2) = '';\n
UPDATE imp_fabricante SET fax = NULL WHERE TRIM(fax) = '';\n
UPDATE imp_fabricante SET email = NULL WHERE TRIM(email) = '';\n
\n
-- Updates para evitar o erro 'Contato já cadastrado para esse cliente'\n
UPDATE imp_fabricante SET\n
telefone2 = CASE WHEN LENGTH(telefone) > LENGTH(telefone2) THEN NULL WHEN LENGTH(telefone) < LENGTH(telefone2) THEN telefone2 ELSE NULL END,\n
telefone = CASE WHEN LENGTH(telefone) > LENGTH(telefone2) THEN telefone WHEN LENGTH(telefone) < LENGTH(telefone2) THEN NULL ELSE telefone END\n
WHERE ret_status <> 'S' AND \n
SUBSTRING(regexp_replace(REVERSE(telefone), '[^0-9]', '', 'g'), 1, 8) = SUBSTRING(regexp_replace(REVERSE(telefone2), '[^0-9]', '', 'g'), 1, 8);\n
\n
UPDATE imp_fabricante SET\n
celular = CASE WHEN LENGTH(telefone) > LENGTH(celular) THEN NULL WHEN LENGTH(telefone) < LENGTH(celular) THEN celular ELSE NULL END,\n
telefone = CASE WHEN LENGTH(telefone) > LENGTH(celular) THEN telefone WHEN LENGTH(telefone) < LENGTH(celular) THEN NULL ELSE telefone END\n
WHERE ret_status <> 'S' AND \n
SUBSTRING(regexp_replace(REVERSE(telefone), '[^0-9]', '', 'g'), 1, 8) = SUBSTRING(regexp_replace(REVERSE(celular), '[^0-9]', '', 'g'), 1, 8);\n
\n
UPDATE imp_fabricante SET\n
fax = CASE WHEN LENGTH(telefone) > LENGTH(fax) THEN NULL WHEN LENGTH(telefone) < LENGTH(fax) THEN fax ELSE NULL END,\n
telefone = CASE WHEN LENGTH(telefone) > LENGTH(fax) THEN telefone WHEN LENGTH(telefone) < LENGTH(fax) THEN NULL ELSE telefone END\n
WHERE ret_status <> 'S' AND \n
SUBSTRING(regexp_replace(REVERSE(telefone), '[^0-9]', '', 'g'), 1, 8) = SUBSTRING(regexp_replace(REVERSE(fax), '[^0-9]', '', 'g'), 1, 8);\n
\n
UPDATE imp_fabricante SET\n
celular = CASE WHEN LENGTH(telefone2) > LENGTH(celular) THEN NULL WHEN LENGTH(telefone2) < LENGTH(celular) THEN celular ELSE celular END,\n
telefone2 = CASE WHEN LENGTH(telefone2) > LENGTH(celular) THEN telefone2 WHEN LENGTH(telefone2) < LENGTH(celular) THEN NULL ELSE NULL END\n
WHERE ret_status <> 'S' AND \n
SUBSTRING(regexp_replace(REVERSE(telefone2), '[^0-9]', '', 'g'), 1, 8) = SUBSTRING(regexp_replace(REVERSE(celular), '[^0-9]', '', 'g'), 1, 8);\n
\n
UPDATE imp_fabricante SET\n
fax = CASE WHEN LENGTH(telefone2) > LENGTH(fax) THEN NULL WHEN LENGTH(telefone2) < LENGTH(fax) THEN fax ELSE NULL END,\n
telefone2 = CASE WHEN LENGTH(telefone2) > LENGTH(fax) THEN telefone2 WHEN LENGTH(telefone2) < LENGTH(fax) THEN NULL ELSE telefone2 END\n
WHERE ret_status <> 'S' AND \n
SUBSTRING(regexp_replace(REVERSE(telefone2), '[^0-9]', '', 'g'), 1, 8) = SUBSTRING(regexp_replace(REVERSE(fax), '[^0-9]', '', 'g'), 1, 8);\n
\n
UPDATE imp_fabricante SET\n
fax = CASE WHEN LENGTH(celular) > LENGTH(fax) THEN NULL WHEN LENGTH(celular) < LENGTH(fax) THEN fax ELSE NULL END,\n
celular = CASE WHEN LENGTH(celular) > LENGTH(fax) THEN celular WHEN LENGTH(celular) < LENGTH(fax) THEN NULL ELSE celular END\n
WHERE ret_status <> 'S' AND \n
SUBSTRING(regexp_replace(REVERSE(celular), '[^0-9]', '', 'g'), 1, 8) = SUBSTRING(regexp_replace(REVERSE(fax), '[^0-9]', '', 'g'), 1, 8);\n
\n
-- Corrige erros comuns nos nomes de Cidades\n
UPDATE imp_fabricante_endereco SET cidade = tmp_nomes_cidades.correto\n
FROM tmp_nomes_cidades\n
WHERE TRIM(UPPER(tmp_nomes_cidades.errado)) = TRIM(UPPER(imp_fabricante_endereco.cidade));\n
\n
UPDATE imp_fabricante_endereco SET bairro = 'NÃO INFORMADO' WHERE bairro IS NULL;\n
\n
UPDATE imp_fabricante_endereco SET cidade = 'NÃO INFORMADA' WHERE cidade IS NULL OR cidade = TRIM('');\n
\n
-- Corrige siglas de Estados\n
UPDATE imp_fabricante_endereco SET Estado = 'SP' WHERE Estado NOT IN\n
('AC','AL','AP','AM','BA','CE','DF','ES','GO','MA','MT','MS','MG','PA','PB','PR','PE','PI','RJ','RN','RS','RO','RR','SC','SP','SE','TO');\n
\n
-- Nulifica ceps inválidos\n
UPDATE imp_fabricante_endereco SET cep = NULL WHERE (cep ~ '^[0-9]{8}$') = FALSE;\n
\n
-- SETA COMO NÃO INFORMADO O ENDEREÇO\n
UPDATE imp_fabricante_endereco SET endereco = 'LOGRADOURO NÃO INFORMADO' where NULLIF(endereco, '.') IS NULL;\n
UPDATE imp_fabricante_endereco SET cidade = 'CIDADE NÃO INFORMADA' where NULLIF(cidade, '.') IS NULL;\n
UPDATE imp_fabricante_endereco SET bairro = 'BAIRRO NÃO INFORMADO' where NULLIF(bairro, '.') IS NULL;\n
\n
-------------------------------------------------------------- CLASSIFICAÇÃO --------------------------------------------------------------\n
\n
IF (referencia_importacao = 'DIA 01' OR referencia_importacao = 'DIA 01/02') THEN\n
  -- insere classificações inexistentes que estão vinculadas à um produto.\n
  INSERT INTO imp_classificacao (id, nome, profundidade, principal, imp_classificacaopaiid)\n
  WITH classificacoes_nao_folha AS (\n
  SELECT DISTINCT\n
  	imp_classificacaoid \n
  FROM imp_produto \n
  WHERE EXISTS (SELECT id FROM imp_classificacao WHERE imp_classificacaopaiid = imp_produto.imp_classificacaoid))\n
  SELECT\n
    imp_classificacao.id||'.FILHA', imp_classificacao.nome||' (Filha)', imp_classificacao.profundidade + 1, TRUE, imp_classificacao.id\n
  FROM imp_classificacao\n
  JOIN classificacoes_nao_folha ON classificacoes_nao_folha.imp_classificacaoid = imp_classificacao.id\n
  LEFT JOIN imp_classificacao impc ON impc.id = imp_classificacao.id||'.FILHA'\n
  WHERE impc.id IS NULL;\n
\n
  -- vincula os produtos que possuem as classficações inexistentes inseridas anteriormente.\n
  UPDATE imp_produto \n
  SET imp_classificacaoid = imp_classificacaoid||'.FILHA'\n
  WHERE EXISTS (SELECT id FROM imp_classificacao WHERE imp_classificacaopaiid = imp_produto.imp_classificacaoid);\n
END IF;\n
\n
-------------------------------------------------------------- PRODUTOS --------------------------------------------------------------\n
\n
-- Altera o tipo aliquota para substituido aonde for tributado e valor da aliquota estiver como 0.\n
UPDATE imp_produto SET tipoaliquota = 'A' WHERE tipoaliquota = 'D'  AND (valoraliquota = 0.00 OR valoraliquota IS NULL);\n
\n
-- Altera o preço de referencial para o preço de venda onde o preço de venda for menor que o preço referencial\n
UPDATE imp_produto SET precoreferencial = precovenda WHERE precoreferencial > precovenda;\n
\n
-- Concatenar o nome do Fabricante para descrições duplicadas que não sejam embalagem mãe\n
UPDATE imp_produto \n
   SET descricao = SUBSTRING(descricao FROM 1 FOR 55) || '(' || SUBSTRING(imp_fabricante.nome FROM 1 FOR 3) || ')'\n
 FROM imp_fabricante\n
 WHERE imp_fabricante.id = imp_produto.imp_fabricanteid\n
   AND UPPER(imp_produto.descricao) IN \n
     (SELECT UPPER(descricao) FROM imp_produto WHERE idprodutocontido IS NULL GROUP BY 1 HAVING COUNT(*)>1);\n
\n
-- Remove duplicação de codigo de barras\n
UPDATE\n
  imp_produto \n
SET\n
  codigobarras = NULL\n
WHERE \n
  codigobarras IN (-- Produtos com código de barras duplicados\n
    SELECT \n
      codigobarras \n
    FROM \n
      imp_produto \n
    WHERE \n
      codigobarras IS NOT NULL \n
    GROUP BY \n
      1 \n
    HAVING \n
      COUNT(*) > 1)\n
  AND\n
    id NOT IN (-- Produtos que continuarão com código de barras entre os que apresentam duplicação\n
      SELECT DISTINCT ON (codigobarras)\n
        id \n
      FROM \n
        imp_produto \n
      WHERE \n
        codigobarras IN (\n
          SELECT \n
            codigobarras \n
          FROM \n
            imp_produto \n
          WHERE \n
            codigobarras IS NOT NULL \n
          GROUP BY \n
            1 \n
          HAVING \n
            COUNT(*) > 1)\n
      ORDER BY\n
        codigobarras,\n
        registroms NULLS LAST,\n
        codigoncm NULLS LAST,\n
        codigonbm NULLS LAST,\n
        imp_gruporemarcacaoid NULLS LAST,\n
        imp_principioativoid NULLS LAST);\n
\n
-- Remover códigos de barras inválidos\n
UPDATE imp_produto SET codigobarras = NULL WHERE codigobarras ~ '[^0-9]';\n
DELETE FROM imp_codigobarras WHERE codigobarras ~ '[^0-9]';\n
UPDATE imp_produto SET codigobarras = NULL WHERE codigobarras IS NOT NULL AND NOT validate_gtin(codigobarras);\n
DELETE FROM imp_codigobarras WHERE codigobarras IS NOT NULL AND NOT validate_gtin(codigobarras);\n
DELETE FROM imp_codigobarras WHERE codigobarras IN (SELECT codigobarras FROM imp_produto);\n
\n
-- Para evitar o seguinte erro: Caused by: java.lang.NumberFormatException: For input string: \n
UPDATE imp_produto SET codigobarras = NULL  WHERE codigobarras = '' AND codigobarras IS NOT NULL;\n
\n
-- Remover todos os caracteres * da descrição de produtos\n
UPDATE imp_produto SET descricao = REPLACE(descricao, '*', '') WHERE descricao ILIKE '%*%';\n
\n
-- Excluir icms produto inseridos erroneamente para embalagens mães e pais.\n
WITH embalagens_maes_pais AS (\n
SELECT DISTINCT\n
  imp_produto.id\n
FROM imp_produto\n
WHERE idprodutocontido IS NOT NULL\n
  OR idprodutopai IS NOT NULL\n
)\n
DELETE FROM imp_icmsproduto WHERE imp_produtoid IN (SELECT * FROM embalagens_maes_pais);\n
\n
-- Excluir códigos de barras adicionais inseridos erroneamente para embalagens mães e pais.\n
WITH embalagens_maes_pais AS (\n
SELECT DISTINCT\n
  imp_produto.id\n
FROM imp_produto\n
WHERE idprodutocontido IS NOT NULL\n
  OR idprodutopai IS NOT NULL\n
)\n
DELETE FROM imp_codigobarras WHERE imp_produtoid IN (SELECT * FROM embalagens_maes_pais);\n
\n
-- Deletar preços por unidade de negócio vinculados a embalagens mãe ou pai\n
WITH embalagens_maes_pais AS (\n
SELECT DISTINCT\n
  imp_produto.id\n
FROM imp_produto\n
WHERE idprodutocontido IS NOT NULL\n
  OR idprodutopai IS NOT NULL\n
)\n
DELETE FROM imp_precoprodutounidadenegocio WHERE imp_produtoid IN (SELECT * FROM embalagens_maes_pais);\n
\n
-------------------------------------------------------------- FORNECEDOR --------------------------------------------------------------\n
\n
--Seta para null os campos que estiverem vazios('')\n
UPDATE imp_fornecedor SET cpf = NULL WHERE cpf = '';\n
UPDATE imp_fornecedor SET inscricaoestadual = NULL WHERE inscricaoestadual = '';\n
UPDATE imp_fornecedor SET cnpj = NULL WHERE cnpj = '';\n
UPDATE imp_fornecedor SET identidade = NULL WHERE identidade = '';\n
\n
\n
-- Seta para null os campos que estiverem repetidos e com nome diferente.\n
-- CNPJ\n
UPDATE imp_fornecedor AS t1 SET cnpj = NULL\n
FROM ( SELECT DISTINCT imp_fornecedor.id\n
  FROM imp_fornecedor AS imp_fornecedor  \n
  JOIN imp_fornecedor AS f ON f.cnpj = imp_fornecedor.cnpj AND f.nome <> imp_fornecedor.nome \n
  WHERE imp_fornecedor.cnpj IS NOT NULL AND f.cnpj IS NOT NULL\n
  ORDER BY 1) AS t2\n
WHERE t1.id = t2.id;\n
\n
-- Inscrição Estadual\n
UPDATE imp_fornecedor AS t1 SET inscricaoestadual = NULL\n
FROM ( SELECT DISTINCT imp_fornecedor.id\n
  FROM imp_fornecedor AS imp_fornecedor  \n
  JOIN imp_fornecedor AS f ON f.inscricaoestadual = imp_fornecedor.inscricaoestadual AND f.nome <> imp_fornecedor.nome \n
  WHERE imp_fornecedor.inscricaoestadual IS NOT NULL AND f.inscricaoestadual IS NOT NULL\n
  ORDER BY 1) AS t2\n
WHERE t1.id = t2.id;\n
\n
-- CPF\n
UPDATE imp_fornecedor AS t1 SET cpf = NULL\n
FROM ( SELECT DISTINCT imp_fornecedor.id\n
  FROM imp_fornecedor AS imp_fornecedor  \n
  JOIN imp_fornecedor AS f ON f.cpf = imp_fornecedor.cpf AND f.nome <> imp_fornecedor.nome \n
  WHERE imp_fornecedor.cpf IS NOT NULL AND f.cpf IS NOT NULL\n
  ORDER BY 1) AS t2\n
WHERE t1.id = t2.id;\n
\n
-- Identidade\n
UPDATE imp_fornecedor AS t1 SET identidade = NULL\n
FROM ( SELECT DISTINCT imp_fornecedor.id\n
  FROM imp_fornecedor AS imp_fornecedor  \n
  JOIN imp_fornecedor AS f ON f.identidade = imp_fornecedor.identidade AND f.nome <> imp_fornecedor.nome \n
  WHERE imp_fornecedor.identidade IS NOT NULL AND f.identidade IS NOT NULL\n
  ORDER BY 1) AS t2\n
WHERE t1.id = t2.id;\n
\n
\n
-- Corrige erros comuns nos nomes de Cidades\n
UPDATE imp_fornecedor_endereco SET cidade = tmp_nomes_cidades.correto\n
FROM tmp_nomes_cidades\n
WHERE TRIM(UPPER(tmp_nomes_cidades.errado)) = TRIM(UPPER(imp_fornecedor_endereco.cidade));\n
\n
UPDATE imp_fornecedor_endereco SET bairro = 'NÃO INFORMADO' WHERE bairro IS NULL;\n
\n
UPDATE imp_fornecedor_endereco SET cidade = 'NÃO INFORMADA' WHERE cidade IS NULL OR cidade = TRIM('');\n
\n
-- Corrige siglas de Estados\n
UPDATE imp_fornecedor_endereco SET Estado = 'SP' WHERE Estado NOT IN\n
('AC','AL','AP','AM','BA','CE','DF','ES','GO','MA','MT','MS','MG','PA','PB','PR','PE','PI','RJ','RN','RS','RO','RR','SC','SP','SE','TO');\n
\n
-- Normalização de telefones (remove qualquer carácter que não seja um número).\n
UPDATE imp_fornecedor SET telefone = regexp_replace(telefone, '[^0-9]', '', 'g') WHERE telefone IS NOT NULL;\n
UPDATE imp_fornecedor SET telefone2 = regexp_replace(telefone2, '[^0-9]', '', 'g') WHERE telefone2 IS NOT NULL;\n
UPDATE imp_fornecedor SET celular = regexp_replace(celular, '[^0-9]', '', 'g') WHERE celular IS NOT NULL;\n
UPDATE imp_fornecedor SET fax = regexp_replace(fax, '[^0-9]', '', 'g') WHERE fax IS NOT NULL;\n
UPDATE imp_fornecedor SET telefone = NULL WHERE TRIM(telefone) = '';\n
UPDATE imp_fornecedor SET telefone2 = NULL WHERE TRIM(telefone2) = '';\n
UPDATE imp_fornecedor SET celular = NULL WHERE TRIM(celular) = '';\n
UPDATE imp_fornecedor SET celular2 = NULL WHERE TRIM(celular2) = '';\n
UPDATE imp_fornecedor SET fax = NULL WHERE TRIM(fax) = '';\n
UPDATE imp_fornecedor SET email = NULL WHERE TRIM(email) = '';\n
\n
-- Updates para evitar o erro 'Contato já cadastrado para esse cliente'\n
UPDATE imp_fornecedor SET\n
telefone2 = CASE WHEN LENGTH(telefone) > LENGTH(telefone2) THEN NULL WHEN LENGTH(telefone) < LENGTH(telefone2) THEN telefone2 ELSE NULL END,\n
telefone = CASE WHEN LENGTH(telefone) > LENGTH(telefone2) THEN telefone WHEN LENGTH(telefone) < LENGTH(telefone2) THEN NULL ELSE telefone END\n
WHERE ret_status <> 'S' AND \n
SUBSTRING(regexp_replace(REVERSE(telefone), '[^0-9]', '', 'g'), 1, 8) = SUBSTRING(regexp_replace(REVERSE(telefone2), '[^0-9]', '', 'g'), 1, 8);\n
\n
UPDATE imp_fornecedor SET\n
celular = CASE WHEN LENGTH(telefone) > LENGTH(celular) THEN NULL WHEN LENGTH(telefone) < LENGTH(celular) THEN celular ELSE NULL END,\n
telefone = CASE WHEN LENGTH(telefone) > LENGTH(celular) THEN telefone WHEN LENGTH(telefone) < LENGTH(celular) THEN NULL ELSE telefone END\n
WHERE ret_status <> 'S' AND \n
SUBSTRING(regexp_replace(REVERSE(telefone), '[^0-9]', '', 'g'), 1, 8) = SUBSTRING(regexp_replace(REVERSE(celular), '[^0-9]', '', 'g'), 1, 8);\n
\n
UPDATE imp_fornecedor SET\n
fax = CASE WHEN LENGTH(telefone) > LENGTH(fax) THEN NULL WHEN LENGTH(telefone) < LENGTH(fax) THEN fax ELSE NULL END,\n
telefone = CASE WHEN LENGTH(telefone) > LENGTH(fax) THEN telefone WHEN LENGTH(telefone) < LENGTH(fax) THEN NULL ELSE telefone END\n
WHERE ret_status <> 'S' AND \n
SUBSTRING(regexp_replace(REVERSE(telefone), '[^0-9]', '', 'g'), 1, 8) = SUBSTRING(regexp_replace(REVERSE(fax), '[^0-9]', '', 'g'), 1, 8);\n
\n
UPDATE imp_fornecedor SET\n
celular = CASE WHEN LENGTH(telefone2) > LENGTH(celular) THEN NULL WHEN LENGTH(telefone2) < LENGTH(celular) THEN celular ELSE celular END,\n
telefone2 = CASE WHEN LENGTH(telefone2) > LENGTH(celular) THEN telefone2 WHEN LENGTH(telefone2) < LENGTH(celular) THEN NULL ELSE NULL END\n
WHERE ret_status <> 'S' AND \n
SUBSTRING(regexp_replace(REVERSE(telefone2), '[^0-9]', '', 'g'), 1, 8) = SUBSTRING(regexp_replace(REVERSE(celular), '[^0-9]', '', 'g'), 1, 8);\n
\n
UPDATE imp_fornecedor SET\n
fax = CASE WHEN LENGTH(telefone2) > LENGTH(fax) THEN NULL WHEN LENGTH(telefone2) < LENGTH(fax) THEN fax ELSE NULL END,\n
telefone2 = CASE WHEN LENGTH(telefone2) > LENGTH(fax) THEN telefone2 WHEN LENGTH(telefone2) < LENGTH(fax) THEN NULL ELSE telefone2 END\n
WHERE ret_status <> 'S' AND \n
SUBSTRING(regexp_replace(REVERSE(telefone2), '[^0-9]', '', 'g'), 1, 8) = SUBSTRING(regexp_replace(REVERSE(fax), '[^0-9]', '', 'g'), 1, 8);\n
\n
UPDATE imp_fornecedor SET\n
fax = CASE WHEN LENGTH(celular) > LENGTH(fax) THEN NULL WHEN LENGTH(celular) < LENGTH(fax) THEN fax ELSE NULL END,\n
celular = CASE WHEN LENGTH(celular) > LENGTH(fax) THEN celular WHEN LENGTH(celular) < LENGTH(fax) THEN NULL ELSE celular END\n
WHERE ret_status <> 'S' AND \n
SUBSTRING(regexp_replace(REVERSE(celular), '[^0-9]', '', 'g'), 1, 8) = SUBSTRING(regexp_replace(REVERSE(fax), '[^0-9]', '', 'g'), 1, 8);\n
\n
-- Nulifica ceps inválidos\n
UPDATE imp_fornecedor_endereco SET cep = NULL WHERE (cep ~ '^[0-9]{8}$') = FALSE;\n
\n
-- SETA COMO NÃO INFORMADO O ENDEREÇO\n
UPDATE imp_fornecedor_endereco SET endereco = 'LOGRADOURO NÃO INFORMADO' where NULLIF(endereco, '.') IS NULL;\n
UPDATE imp_fornecedor_endereco SET cidade = 'CIDADE NÃO INFORMADA' where NULLIF(cidade, '.') IS NULL;\n
UPDATE imp_fornecedor_endereco SET bairro = 'BAIRRO NÃO INFORMADO' where NULLIF(bairro, '.') IS NULL;\n
\n
-------------------------------------------------------------- TABELA DE RESTRIÇÕES ----------------------------------------------------------------\n
\n
IF (referencia_importacao = 'DIA 01' OR referencia_importacao = 'DIA 01/02') THEN\n
  -- Excluir produtos da tabela de restrições inseridos erroneamente para embalagens mães e pais.\n
  WITH embalagens_maes_pais AS (\n
  SELECT DISTINCT\n
    imp_produto.id\n
  FROM imp_produto\n
  WHERE idprodutocontido IS NOT NULL\n
    OR idprodutopai IS NOT NULL\n
  )\n
  DELETE FROM imp_tabrestricoesproduto WHERE imp_produtoid IN (SELECT * FROM embalagens_maes_pais);\n
END IF;\n
\n
-------------------------------------------------------------- CADERNO DE OFERTAS ----------------------------------------------------------------\n
\n
IF (referencia_importacao = 'DIA 01' OR referencia_importacao = 'DIA 01/02') THEN\n
  -- Seta os cadernos de ofertas vinculados com crediário para forma específica para evitar erro ao importar o crediário\n
  WITH cadernooferta_formapagamento_especifica AS (\n
  SELECT DISTINCT\n
    imp_cadernoofertaid\n
  FROM imp_crediario\n
  WHERE imp_cadernoofertaid IS NOT NULL\n
  )\n
  UPDATE imp_cadernooferta SET formapagamentoaceita = 'B'\n
  WHERE id IN (SELECT * FROM cadernooferta_formapagamento_especifica);\n
\n
  -- Excluir itens de caderno de oferta inseridos erroneamente para embalagens mães e pais.\n
  WITH embalagens_maes_pais AS (\n
  SELECT DISTINCT\n
    imp_produto.id\n
  FROM imp_produto\n
  WHERE idprodutocontido IS NOT NULL\n
    OR idprodutopai IS NOT NULL\n
  )\n
  DELETE FROM imp_itemcadernooferta WHERE imp_produtoid IN (SELECT * FROM embalagens_maes_pais);\n
\n
  -- Excluir itens de caderno de oferta por quantidade inseridos erroneamente para embalagens mães e pais.\n
  WITH embalagens_maes_pais AS (\n
  SELECT DISTINCT\n
    imp_produto.id\n
  FROM imp_produto\n
  WHERE idprodutocontido IS NOT NULL\n
    OR idprodutopai IS NOT NULL\n
  )\n
  DELETE FROM imp_itemcadernoofertaquantidade WHERE imp_produtoid IN (SELECT * FROM embalagens_maes_pais);\n
END IF;\n
\n
-------------------------------------------------------------- CREDIÁRIO ----------------------------------------------------------------\n
\n
IF (referencia_importacao = 'DIA 01' OR referencia_importacao = 'DIA 01/02') THEN\n
  -- Seta para null os campos que estiverem repetidos e com nome diferente.\n
  -- CNPJ\n
  UPDATE imp_crediario AS t1 SET cnpj = NULL\n
  FROM ( SELECT DISTINCT imp_crediario.id\n
    FROM imp_crediario AS imp_crediario  \n
    JOIN imp_crediario AS c ON c.cnpj = imp_crediario.cnpj AND c.nome <> imp_crediario.nome \n
    WHERE imp_crediario.cnpj IS NOT NULL AND c.cnpj IS NOT NULL\n
    ORDER BY 1) AS t2\n
  WHERE t1.id = t2.id;\n
\n
  -- Inscrição Estadual\n
  UPDATE imp_crediario AS t1 SET inscricaoestadual = NULL\n
  FROM ( SELECT DISTINCT imp_crediario.id\n
    FROM imp_crediario AS imp_crediario  \n
    JOIN imp_crediario AS c ON c.inscricaoestadual = imp_crediario.inscricaoestadual AND c.nome <> imp_crediario.nome \n
    WHERE imp_crediario.inscricaoestadual IS NOT NULL AND c.inscricaoestadual IS NOT NULL\n
    ORDER BY 1) AS t2\n
  WHERE t1.id = t2.id;\n
\n
  -- CPF\n
  UPDATE imp_crediario AS t1 SET cpf = NULL\n
  FROM ( SELECT DISTINCT imp_crediario.id\n
    FROM imp_crediario AS imp_crediario  \n
    JOIN imp_crediario AS c ON c.cpf = imp_crediario.cpf AND c.nome <> imp_crediario.nome \n
    WHERE imp_crediario.cpf IS NOT NULL AND c.cpf IS NOT NULL\n
    ORDER BY 1) AS t2\n
  WHERE t1.id = t2.id;\n
\n
  -- Identidade\n
  UPDATE imp_crediario AS t1 SET identidade = NULL\n
  FROM ( SELECT DISTINCT imp_crediario.id\n
    FROM imp_crediario AS imp_crediario  \n
    JOIN imp_crediario AS c ON c.identidade = imp_crediario.identidade AND c.nome <> imp_crediario.nome \n
    WHERE imp_crediario.identidade IS NOT NULL AND c.identidade IS NOT NULL\n
    ORDER BY 1) AS t2\n
  WHERE t1.id = t2.id;\n
END IF;\n
\n
-------------------------------------------------------------- CLIENTE ----------------------------------------------------------------\n
\n
-- Nulifica numeros de cartão vazios para evitar exception no checada\n
UPDATE imp_cliente SET numerocartao = NULL WHERE TRIM(numerocartao) = '';\n
\n
-- Seta para null o campo senha se estiver preenchido.\n
UPDATE imp_cliente SET senha = NULL;\n
\n
--Seta para null os campos que estiverem vazios('')\n
UPDATE imp_cliente SET cpf = NULL WHERE cpf = '';\n
UPDATE imp_cliente SET inscricaoestadual = NULL WHERE inscricaoestadual = '';\n
UPDATE imp_cliente SET cnpj = NULL WHERE cnpj = '';\n
UPDATE imp_cliente SET identidade = NULL WHERE identidade = '';\n
\n
-- Seta para null os campos que estiverem repetidos e com nome diferente.\n
-- CNPJ\n
UPDATE imp_cliente AS t1 SET cnpj = NULL\n
FROM ( SELECT DISTINCT imp_cliente.id\n
  FROM imp_cliente AS imp_cliente  \n
  JOIN imp_cliente AS c ON c.cnpj = imp_cliente.cnpj AND c.nome <> imp_cliente.nome \n
  WHERE imp_cliente.cnpj IS NOT NULL AND c.cnpj IS NOT NULL\n
  ORDER BY 1) AS t2\n
WHERE t1.id = t2.id;\n
\n
-- Inscrição Estadual\n
UPDATE imp_cliente AS t1 SET inscricaoestadual = NULL\n
FROM ( SELECT DISTINCT imp_cliente.id\n
  FROM imp_cliente AS imp_cliente  \n
  JOIN imp_cliente AS c ON c.inscricaoestadual = imp_cliente.inscricaoestadual AND c.nome <> imp_cliente.nome \n
  WHERE imp_cliente.inscricaoestadual IS NOT NULL AND c.inscricaoestadual IS NOT NULL\n
  ORDER BY 1) AS t2\n
WHERE t1.id = t2.id;\n
\n
-- CPF\n
UPDATE imp_cliente AS t1 SET cpf = NULL\n
FROM ( SELECT DISTINCT imp_cliente.id\n
  FROM imp_cliente AS imp_cliente  \n
  JOIN imp_cliente AS c ON c.cpf = imp_cliente.cpf AND c.nome <> imp_cliente.nome \n
  WHERE imp_cliente.cpf IS NOT NULL AND c.cpf IS NOT NULL\n
  ORDER BY 1) AS t2\n
WHERE t1.id = t2.id;\n
\n
-- Identidade\n
UPDATE imp_cliente AS t1 SET identidade = NULL\n
FROM ( SELECT DISTINCT imp_cliente.id\n
  FROM imp_cliente AS imp_cliente  \n
  JOIN imp_cliente AS c ON c.identidade = imp_cliente.identidade AND c.nome <> imp_cliente.nome \n
  WHERE imp_cliente.identidade IS NOT NULL AND c.identidade IS NOT NULL\n
  ORDER BY 1) AS t2\n
WHERE t1.id = t2.id;\n
\n
\n
-- Remover emails inválidos\n
UPDATE Imp_Cliente SET email = NULL WHERE email NOT LIKE '%@%.%';\n
\n
-- Corrige erros comuns nos nomes de Cidades\n
UPDATE imp_cliente_endereco SET cidade = tmp_nomes_cidades.correto\n
FROM tmp_nomes_cidades\n
WHERE TRIM(UPPER(tmp_nomes_cidades.errado)) = TRIM(UPPER(imp_cliente_endereco.cidade));\n
\n
UPDATE imp_cliente_endereco SET bairro = 'NÃO INFORMADO' WHERE bairro IS NULL OR TRIM(bairro) = '';\n
\n
UPDATE imp_cliente_endereco SET cidade = 'NÃO INFORMADA' WHERE cidade IS NULL OR TRIM(cidade) = '';\n
\n
-- Corrige siglas de Estados\n
UPDATE imp_cliente_endereco SET Estado = 'SP' WHERE Estado NOT IN\n
('AC','AL','AP','AM','BA','CE','DF','ES','GO','MA','MT','MS','MG','PA','PB','PR','PE','PI','RJ','RN','RS','RO','RR','SC','SP','SE','TO');\n
\n
-- Normalização de telefones (remove qualquer carácter que não seja um número).\n
UPDATE imp_cliente SET telefone = regexp_replace(telefone, '[^0-9]', '', 'g') WHERE telefone IS NOT NULL;\n
UPDATE imp_cliente SET telefone2 = regexp_replace(telefone2, '[^0-9]', '', 'g') WHERE telefone2 IS NOT NULL;\n
UPDATE imp_cliente SET celular = regexp_replace(celular, '[^0-9]', '', 'g') WHERE celular IS NOT NULL;\n
UPDATE imp_cliente SET fax = regexp_replace(fax, '[^0-9]', '', 'g') WHERE fax IS NOT NULL;\n
UPDATE imp_cliente SET telefone = NULL WHERE TRIM(telefone) = '';\n
UPDATE imp_cliente SET telefone2 = NULL WHERE TRIM(telefone2) = '';\n
UPDATE imp_cliente SET celular = NULL WHERE TRIM(celular) = '';\n
UPDATE imp_cliente SET celular2 = NULL WHERE TRIM(celular2) = '';\n
UPDATE imp_cliente SET fax = NULL WHERE TRIM(fax) = '';\n
UPDATE imp_cliente SET email = NULL WHERE TRIM(email) = '';\n
\n
-- Updates para evitar o erro 'Contato já cadastrado para esse cliente'\n
UPDATE imp_cliente SET\n
telefone2 = CASE WHEN LENGTH(telefone) > LENGTH(telefone2) THEN NULL WHEN LENGTH(telefone) < LENGTH(telefone2) THEN telefone2 ELSE NULL END,\n
telefone = CASE WHEN LENGTH(telefone) > LENGTH(telefone2) THEN telefone WHEN LENGTH(telefone) < LENGTH(telefone2) THEN NULL ELSE telefone END\n
WHERE ret_status <> 'S' AND \n
SUBSTRING(regexp_replace(REVERSE(telefone), '[^0-9]', '', 'g'), 1, 8) = SUBSTRING(regexp_replace(REVERSE(telefone2), '[^0-9]', '', 'g'), 1, 8);\n
\n
UPDATE imp_cliente SET\n
celular = CASE WHEN LENGTH(telefone) > LENGTH(celular) THEN NULL WHEN LENGTH(telefone) < LENGTH(celular) THEN celular ELSE NULL END,\n
telefone = CASE WHEN LENGTH(telefone) > LENGTH(celular) THEN telefone WHEN LENGTH(telefone) < LENGTH(celular) THEN NULL ELSE telefone END\n
WHERE ret_status <> 'S' AND \n
SUBSTRING(regexp_replace(REVERSE(telefone), '[^0-9]', '', 'g'), 1, 8) = SUBSTRING(regexp_replace(REVERSE(celular), '[^0-9]', '', 'g'), 1, 8);\n
\n
UPDATE imp_cliente SET\n
fax = CASE WHEN LENGTH(telefone) > LENGTH(fax) THEN NULL WHEN LENGTH(telefone) < LENGTH(fax) THEN fax ELSE NULL END,\n
telefone = CASE WHEN LENGTH(telefone) > LENGTH(fax) THEN telefone WHEN LENGTH(telefone) < LENGTH(fax) THEN NULL ELSE telefone END\n
WHERE ret_status <> 'S' AND \n
SUBSTRING(regexp_replace(REVERSE(telefone), '[^0-9]', '', 'g'), 1, 8) = SUBSTRING(regexp_replace(REVERSE(fax), '[^0-9]', '', 'g'), 1, 8);\n
\n
UPDATE imp_cliente SET\n
celular = CASE WHEN LENGTH(telefone2) > LENGTH(celular) THEN NULL WHEN LENGTH(telefone2) < LENGTH(celular) THEN celular ELSE celular END,\n
telefone2 = CASE WHEN LENGTH(telefone2) > LENGTH(celular) THEN telefone2 WHEN LENGTH(telefone2) < LENGTH(celular) THEN NULL ELSE NULL END\n
WHERE ret_status <> 'S' AND \n
SUBSTRING(regexp_replace(REVERSE(telefone2), '[^0-9]', '', 'g'), 1, 8) = SUBSTRING(regexp_replace(REVERSE(celular), '[^0-9]', '', 'g'), 1, 8);\n
\n
UPDATE imp_cliente SET\n
fax = CASE WHEN LENGTH(telefone2) > LENGTH(fax) THEN NULL WHEN LENGTH(telefone2) < LENGTH(fax) THEN fax ELSE NULL END,\n
telefone2 = CASE WHEN LENGTH(telefone2) > LENGTH(fax) THEN telefone2 WHEN LENGTH(telefone2) < LENGTH(fax) THEN NULL ELSE telefone2 END\n
WHERE ret_status <> 'S' AND \n
SUBSTRING(regexp_replace(REVERSE(telefone2), '[^0-9]', '', 'g'), 1, 8) = SUBSTRING(regexp_replace(REVERSE(fax), '[^0-9]', '', 'g'), 1, 8);\n
\n
UPDATE imp_cliente SET\n
fax = CASE WHEN LENGTH(celular) > LENGTH(fax) THEN NULL WHEN LENGTH(celular) < LENGTH(fax) THEN fax ELSE NULL END,\n
celular = CASE WHEN LENGTH(celular) > LENGTH(fax) THEN celular WHEN LENGTH(celular) < LENGTH(fax) THEN NULL ELSE celular END\n
WHERE ret_status <> 'S' AND \n
SUBSTRING(regexp_replace(REVERSE(celular), '[^0-9]', '', 'g'), 1, 8) = SUBSTRING(regexp_replace(REVERSE(fax), '[^0-9]', '', 'g'), 1, 8);\n
\n
-- Nulifica ceps inválidos\n
UPDATE imp_cliente_endereco SET cep = NULL WHERE (cep ~ '^[0-9]{8}$') = FALSE;\n
\n
-- SETA COMO NÃO INFORMADO O ENDEREÇO\n
UPDATE imp_cliente_endereco SET endereco = 'LOGRADOURO NÃO INFORMADO' where NULLIF(endereco, '.') IS NULL;\n
UPDATE imp_cliente_endereco SET cidade = 'CIDADE NÃO INFORMADA' where NULLIF(cidade, '.') IS NULL;\n
UPDATE imp_cliente_endereco SET bairro = 'BAIRRO NÃO INFORMADO' where NULLIF(bairro, '.') IS NULL;\n
\n
-------------------------------------------------------------- DEPENDENTE CLIENTE ----------------------------------------------------------------\n
\n
--Seta para null os campos que estiverem vazios('')\n
UPDATE imp_dependentecliente SET cpf = NULL WHERE cpf = '';\n
UPDATE imp_dependentecliente SET inscricaoestadual = NULL WHERE inscricaoestadual = '';\n
UPDATE imp_dependentecliente SET cnpj = NULL WHERE cnpj = '';\n
UPDATE imp_dependentecliente SET identidade = NULL WHERE identidade = '';\n
\n
\n
-- Seta para null os campos que estiverem repetidos e com nome diferente.\n
-- CNPJ\n
UPDATE imp_dependentecliente AS t1 SET cnpj = NULL\n
FROM ( SELECT DISTINCT imp_dependentecliente.id\n
  FROM imp_dependentecliente AS imp_dependentecliente  \n
  JOIN imp_dependentecliente AS dc ON dc.cnpj = imp_dependentecliente.cnpj AND dc.nome <> imp_dependentecliente.nome \n
  WHERE imp_dependentecliente.cnpj IS NOT NULL AND dc.cnpj IS NOT NULL\n
  ORDER BY 1) AS t2\n
WHERE t1.id = t2.id;\n
\n
-- Inscrição Estadual\n
UPDATE imp_dependentecliente AS t1 SET inscricaoestadual = NULL\n
FROM ( SELECT DISTINCT imp_dependentecliente.id\n
  FROM imp_dependentecliente AS imp_dependentecliente  \n
  JOIN imp_dependentecliente AS dc ON dc.inscricaoestadual = imp_dependentecliente.inscricaoestadual AND dc.nome <> imp_dependentecliente.nome \n
  WHERE imp_dependentecliente.inscricaoestadual IS NOT NULL AND dc.inscricaoestadual IS NOT NULL\n
  ORDER BY 1) AS t2\n
WHERE t1.id = t2.id;\n
\n
-- CPF\n
UPDATE imp_dependentecliente AS t1 SET cpf = NULL\n
FROM ( SELECT DISTINCT imp_dependentecliente.id\n
  FROM imp_dependentecliente AS imp_dependentecliente  \n
  JOIN imp_dependentecliente AS dc ON dc.cpf = imp_dependentecliente.cpf AND dc.nome <> imp_dependentecliente.nome \n
  WHERE imp_dependentecliente.cpf IS NOT NULL AND dc.cpf IS NOT NULL\n
  ORDER BY 1) AS t2\n
WHERE t1.id = t2.id;\n
\n
-- Identidade\n
UPDATE imp_dependentecliente AS t1 SET identidade = NULL\n
FROM ( SELECT DISTINCT imp_dependentecliente.id\n
  FROM imp_dependentecliente AS imp_dependentecliente  \n
  JOIN imp_dependentecliente AS dc ON dc.identidade = imp_dependentecliente.identidade AND dc.nome <> imp_dependentecliente.nome \n
  WHERE imp_dependentecliente.identidade IS NOT NULL AND dc.identidade IS NOT NULL\n
  ORDER BY 1) AS t2\n
WHERE t1.id = t2.id;\n
\n
\n
-- Normalização de telefones (remove qualquer carácter que não seja um número).\n
UPDATE imp_dependentecliente SET telefone = regexp_replace(telefone, '[^0-9]', '', 'g') WHERE telefone IS NOT NULL;\n
UPDATE imp_dependentecliente SET telefone2 = regexp_replace(telefone2, '[^0-9]', '', 'g') WHERE telefone2 IS NOT NULL;\n
UPDATE imp_dependentecliente SET celular = regexp_replace(celular, '[^0-9]', '', 'g') WHERE celular IS NOT NULL;\n
UPDATE imp_dependentecliente SET fax = regexp_replace(fax, '[^0-9]', '', 'g') WHERE fax IS NOT NULL;\n
UPDATE imp_dependentecliente SET telefone = NULL WHERE TRIM(telefone) = '';\n
UPDATE imp_dependentecliente SET telefone2 = NULL WHERE TRIM(telefone2) = '';\n
UPDATE imp_dependentecliente SET celular = NULL WHERE TRIM(celular) = '';\n
UPDATE imp_dependentecliente SET celular2 = NULL WHERE TRIM(celular2) = '';\n
UPDATE imp_dependentecliente SET fax = NULL WHERE TRIM(fax) = '';\n
UPDATE imp_dependentecliente SET email = NULL WHERE TRIM(email) = '';\n
\n
-- Remover emails inválidos\n
UPDATE imp_dependentecliente SET email = NULL WHERE email NOT LIKE '%@%.%';\n
\n
-------------------------------------------------------------- PLANO REMUNERAÇÃO ----------------------------------------------------------------\n
\n
IF (referencia_importacao = 'DIA 01' OR referencia_importacao = 'DIA 01/02') THEN\n
  -- Excluir itens de plano de remuneração por bonificação por quantidade inseridos erroneamente para embalagens mães e pais.\n
  WITH embalagens_maes_pais AS (\n
  SELECT DISTINCT\n
    imp_produto.id\n
  FROM imp_produto\n
  WHERE idprodutocontido IS NOT NULL\n
    OR idprodutopai IS NOT NULL\n
  )\n
  DELETE FROM imp_planoremubonificacao WHERE imp_produtoid IN (SELECT * FROM embalagens_maes_pais);\n
\n
  -- Excluir itens de plano de remuneração por comissão por quantidade inseridos erroneamente para embalagens mães e pais.\n
  WITH embalagens_maes_pais AS (\n
  SELECT DISTINCT\n
    imp_produto.id\n
  FROM imp_produto\n
  WHERE idprodutocontido IS NOT NULL\n
    OR idprodutopai IS NOT NULL\n
  )\n
  DELETE FROM imp_planoremucomissao WHERE imp_produtoid IN (SELECT * FROM embalagens_maes_pais);\n
END IF;\n
\n
-------------------------------------------------------------- DIA 02 ----------------------------------------------------------------\n
\n
IF (referencia_importacao = 'DIA 02' OR referencia_importacao = 'DIA 01/02') THEN\n
\n
-------------------------------------------------------------- CUSTO ----------------------------------------------------------------\n
\n
-- Excluir custos inseridos erroneamente para embalagens mães e pais, pois o custo é por produto e isso pode gerar problemas por inserir\n
-- custo errado, ou seja, um custo bem absurdo onde os implantadores não saberão de onde vem. Na verdade é para o módulo nem deixar importar o\n
-- custo e soltar um erro\n
WITH embalagens_maes_pais AS (\n
SELECT DISTINCT\n
  imp_produto.id\n
FROM imp_produto\n
WHERE idprodutocontido IS NOT NULL\n
  OR idprodutopai IS NOT NULL\n
)\n
DELETE FROM imp_custo WHERE imp_produtoid IN (SELECT * FROM embalagens_maes_pais);\n
\n
-- Seta o precoReferencial para o custoMedio onde custoMedio >= precoReferencial * 1.3\n
UPDATE imp_custo SET customedio = foo.precoreferencial\n
FROM\n
  (SELECT id, precoreferencial FROM imp_produto) AS foo\n
WHERE\n
  imp_custo.imp_produtoid = foo.id\n
  AND\n
  imp_custo.customedio >= foo.precoreferencial * 1.3;\n
\n
\n
-- Seta o precoReferencial para o custo onde custo>= precoReferencial * 1.3\n
UPDATE imp_custo SET custo = foo.precoreferencial\n
FROM\n
  (SELECT id, precoreferencial FROM imp_produto) AS foo\n
WHERE\n
  imp_custo.imp_produtoid = foo.id\n
  AND\n
  imp_custo.custo >= foo.precoreferencial * 1.3;  \n
\n
-------------------------------------------------------------- ESTOQUE ----------------------------------------------------------------\n
\n
-- Remover registros com estoque negativo\n
DELETE FROM imp_estoque WHERE estoque < 0;\n
\n
-- Excluir estoque inseridos erroneamente para embalagens mães e pais.\n
WITH embalagens_maes_pais AS (\n
SELECT DISTINCT\n
  imp_produto.id\n
FROM imp_produto\n
WHERE idprodutocontido IS NOT NULL\n
  OR idprodutopai IS NOT NULL\n
)\n
DELETE FROM imp_estoque WHERE imp_produtoid IN (SELECT * FROM embalagens_maes_pais);\n
\n
-------------------------------------------------------------- HISTÓRICO DE VENDAS ----------------------------------------------------------------\n
\n
-- Excluir históricos de venda inseridos erroneamente para embalagens mães e pais.\n
WITH embalagens_maes_pais AS (\n
SELECT DISTINCT\n
  imp_produto.id\n
FROM imp_produto\n
WHERE idprodutocontido IS NOT NULL\n
  OR idprodutopai IS NOT NULL\n
)\n
DELETE FROM imp_historicovenda WHERE imp_produtoid IN (SELECT * FROM embalagens_maes_pais);\n
\n
END IF;\n
\n
END;\n
$$;\n
\n
ALTER FUNCTION public.pre_verificacoes(referencia_importacao CHARACTER VARYING, nome_databaseoficial CHARACTER VARYING, host_baseoficial CHARACTER VARYING, porta_baseoficial CHARACTER VARYING)\n
    OWNER TO chinchila;\n
\n
-- INSERE A VERSÃO ATUAL\n
INSERT INTO Imp_Versao (Versao) VALUES ('2.3.0');\n
\n
-- DÁ AS PERMISSÕES AO CHINCHILA PARA MANUSEAR AS TABELAS\n
GRANT SELECT,INSERT, UPDATE, DELETE  ON ALL TABLES IN SCHEMA public TO chinchila;\n
\n
-- A FUNÇÃO SE AUTO DROPA AUTOMATICAMENTE\n
DROP PROCEDURE IF EXISTS public.updates_2_3_0();\n
\n
END; $BODY$;\n
\n
ALTER PROCEDURE public.updates_2_3_0() OWNER TO chinchila;\n