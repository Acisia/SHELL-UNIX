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
-- 		VAL_SEPARATEUR=;
-- 		VAL_SCHEMA=b_wordpress
-- 		VAL_SCHEMA_USER=u_wordpress
--	
--
-- Historique:		
--	 08/10/2015		 Louis DAUBIGNARD	- Creation
-- -----------------------------------------------------------------------------+
-- use b_wordpress ;

-- BASE DE DONNEES OU SCHEMA
prompt *** Creation base de donnees 
-- SCHEMA 
SELECT CONCAT(DATE_FORMAT(SYSDATE(), "%d/%m/%Y %H:%i:%s")," - CREATION BDD b_wordpress") FROM DUAL;
CREATE DATABASE IF NOT EXISTS b_wordpress CHARACTER SET utf8 COLLATE utf8_general_ci;

-- UTILISATEURS
prompt *** Creation utilisateur u_fov4
SELECT CONCAT(DATE_FORMAT(SYSDATE(), "%d/%m/%Y %H:%i:%s")," - CREATION USER u_wordpress") FROM DUAL;

-- Mise en place des provill�ges utilisateur par sch�ma de base de donn�es
-- Read Only
-- GRANT SELECT ON *.* TO 'u_wordpress'@'127.0.0.1' IDENTIFIED BY 'caa61753f4e0c43d488a0f4b';
-- All privillege
GRANT ALL PRIVILEGES ON b_wordpress.* TO 'u_wordpress'@'127.0.0.1' IDENTIFIED BY 'caa61753f4e0c43d488a0f4b';



