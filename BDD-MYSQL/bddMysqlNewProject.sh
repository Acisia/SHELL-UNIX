#!/bin/bash
###################################################################################################################
# Author : Louis DAUBIGNARD
# Date   : 19/01/2015
#
# Description : Script pour :
#		- executer une requete oracle 
#
# Syntax : bddOracle.sh 
#
###################################################################################################################
#CHEMIN RACINE
PATHROOT="$PWD"
NOMPROJECTSCRIPT=" CREATION NOUVEAU PROJET MYSQL"
########################################################################"
VAL_SEPARATEUR=";"
VAL_SCHEMA="b_$2"
VAL_SCHEMA_USER="u_$2"
#RECUPERATION DES FONCTIONS
. "$PATHROOT/../lib/functions.sh"

printMessageTo	"             $NOMPROJECTSCRIPT										" "1" 

##################################################################################################################
if [ $2 ]
	then
		printMessageTo  "  ***  $2	***	" "2" 
	else
		printMessageTo "\033[31m[ERREUR]\033[0m Pas de parametre entree (bddMySqlNewProject.sh int nomBDD)" "2"
		exit 1
fi	
#TEST DE L ENVIRONNEMENT
if [ $1 ]
	then
		setEnvironment $1
	else
		setEnvironment
fi	
ret=$?
#RECUPERATION DES PROPERTIES
configEnvironment "$ret" "$PATHROOT/../config"
#CHECK DES LOGS
checkPathDst "$PATHDEST_REPLOG" "Chemin LOG"


##################################################################################################################
# TEST PRE-REQUIS
printMessageTo  "             CONTROLE APPLI										" "3" 
# Vérifier que l'utilisateur est root
# checkUserRoot
# Vérifier que perl est installé pour la gestion des mots de passe
checkAppli perl
##################################################################################################################
printMessageTo  "             DEPUT PROCESS									" "3" 
printMessageTo  " $(date +%d/%m/%Y-%H:%M:%S) - LANCEMENT PROCESS TEMPLATE SQL " "2"
printMessageTo  " $(date +%d/%m/%Y-%H:%M:%S) - CREATION FICHIER AVEC TEMPLATE " "2"
# createSqlFileInDir [PAHTDESTLOG] [FILESQLPATHSRC] [FILESQLPATHDST] 
createSqlFileInDir "$PATHDEST_REPLOG" "tpl" "sql"

printMessageTo  " $(date +%d/%m/%Y-%H:%M:%S) - LANCEMENT PROCESS  SQL  " "2"
printMessageTo  " $(date +%d/%m/%Y-%H:%M:%S) - LECTURE FICHIER : create_mysql_projet.sqlfusion.sql          " "2"
# Lancemen de requete sans entete de colonne mysql
execReqMysql "sql/create_mysql_projet.sqlfusion.sql" "sql/" "SC" 
retval=$?
if [ $retval -eq 0 ]
	then
		printMessageTo "\033[32m[OK]\033[0m $(date +%d/%m/%Y-%H:%M:%S) - TRAITEMENT OK" "2"
	else
		printMessageTo "\033[31m[ERREUR]\033[0m $(date +%d/%m/%Y-%H:%M:%S) - TRAITEMENT KO" "2"
fi


