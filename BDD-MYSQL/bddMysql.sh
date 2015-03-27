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

#RECUPERATION DES FONCTIONS
. $PATHROOT/../lib/functions.sh
#RECUPERATION DES PROPERTIES
. $PATHROOT/../config/config.sh
##################################################################################################################


echo  "--------------------------------------------------------------------------------------------------"
echo  "                   TEST REQUETE ORACLE		   														 "
echo  "--------------------------------------------------------------------------------------------------"

# Vérifier que perl est installé pour la gestion des mots de passe
execReqMysql "SELECT * FROM TABLE;" "$PATHDESTLOG"
retval=$?
if [ $retval -eq 0 ]
	then
		printMessageTo "$(date +%d/%m/%Y-%H:%M:%S) - TRAITEMENT OK" "2" "2" "$PATHDEST_FICLOG"	
	else
		printMessageTo "$(date +%d/%m/%Y-%H:%M:%S) - TRAITEMENT KO" "2" "2" "$PATHDEST_FICLOG"		
fi

echo "use mysql; select user from user;" | mysql --user=root --password=