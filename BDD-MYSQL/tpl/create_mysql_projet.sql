-- SET SERVEROUTPUT ON SIZE UNLIMITED;
-- EXEC DBMS_OUTPUT.PUT_LINE(' -- ---------   Script de creation BDD    ----------- ');
-- ----------------------------------------------------------------------------+
--                                DEFINITION DU SCRIPT                       -+
-- ----------------------------------------------------------------------------+
-- 
-- Title: create_database.sql
--
--
--
-- Description :  
-- 		Script de Script de creation BDD 
--	
-- ATTENTION FICHIER TEMPLATE
-- -- Les variables suivantes sont remplacées
-- 		VAL_SEPARATEUR=${VAL_SEPARATEUR}
-- 		VAL_SCHEMA=${VAL_SCHEMA}
-- 		VAL_SCHEMA_USER=${VAL_SCHEMA_USER}
-- 		VAL_SCHEMA_PASSWD=${VAL_SCHEMA_PASSWD}
--	
--
-- Historique:		
--	 08/10/2015		 Louis DAUBIGNARD	- Creation
-- -----------------------------------------------------------------------------+
-- use ${VAL_SCHEMA} ;

-- BASE DE DONNEES OU SCHEMA
prompt *** Creation base de donnees 
-- SCHEMA 
SELECT CONCAT(DATE_FORMAT(SYSDATE(), "%d/%m/%Y %H:%i:%s")," - CREATION BDD ${VAL_SCHEMA}") FROM DUAL;
CREATE DATABASE IF NOT EXISTS ${VAL_SCHEMA} CHARACTER SET utf8 COLLATE utf8_general_ci;

-- UTILISATEURS
prompt *** Creation utilisateur
SELECT CONCAT(DATE_FORMAT(SYSDATE(), "%d/%m/%Y %H:%i:%s")," - CREATION USER ${VAL_SCHEMA_USER}") FROM DUAL;

-- Mise en place des provilleges utilisateur par schema de base de donnees
-- Read Only
-- GRANT SELECT ON *.* TO '${VAL_SCHEMA_USER}'@'127.0.0.1' IDENTIFIED BY '${VAL_SCHEMA_PASSWD}';
-- All privillege
GRANT ALL PRIVILEGES ON ${VAL_SCHEMA}.* TO '${VAL_SCHEMA_USER}'@'127.0.0.1' IDENTIFIED BY '${VAL_SCHEMA_PASSWD}';



