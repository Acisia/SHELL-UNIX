#!/bin/bash
###################################################################################################################
# Author : Louis DAUBIGNARD
# Date   : 19/01/2015
#
# Description : Script pour :
#		- Connexion mysql
#
# Syntax : bddMyLogin.sh 
#
###################################################################################################################
#CHEMIN RACINE
PATHROOT="$PWD"

#RECUPERATION DES FONCTIONS
. "$PATHROOT/../lib/functions.sh"

#TEST DE L ENVIRONNEMENT
if [ $1 ]
	then
		setEnvironment $1
	else
		setEnvironment
fi	
ret=$?

#ENREGISTREMENT CONFIG MYSQL
if [ $2 ]
	then
		printMessageTo "*	CONFIGURATION MYSQL CONFIG	*" "3" 
		pr_mysql_login		
fi	

#RECUPERATION DES PROPERTIES
configEnvironment "$ret" "$PATHROOT/../config"


echo  "--------------------------------------------------------------------------------------------------"
echo  "                   CONNEXION MYSQL : $bdd_my_login_path 											"
echo  "                   USER MYSQL : $bdd_my_login												 "
echo  "--------------------------------------------------------------------------------------------------"

 mysql --login-path=$bdd_my_login_path -u $bdd_my_login

 echo "    FIN"
 echo "    CONNEXION  MYSQL TERMINE"