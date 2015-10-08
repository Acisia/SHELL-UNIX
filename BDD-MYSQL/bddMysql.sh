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
NOMPROJECTSCRIPT=" TEST REQUETE MYSQL"

#RECUPERATION DES FONCTIONS
. "$PATHROOT/../lib/functions.sh"

printMessageTo	"             $NOMPROJECTSCRIPT										" "1" 

##################################################################################################################
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
printMessageTo  "             EXECUTION REQUETE										" "3" 
# Vérifier que perl est installé pour la gestion des mots de passe
execReqParamMysql "use mysql; select user from user;"
retval=$?
if [ $retval -eq 0 ]
	then
		printMessageTo "$(date +%d/%m/%Y-%H:%M:%S) - TRAITEMENT OK" "2"
	else
		printMessageTo "$(date +%d/%m/%Y-%H:%M:%S) - TRAITEMENT KO" "2"
fi


