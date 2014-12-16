#!/bin/bash
###################################################################################################################
# Author : Louis DAUBIGNARD
# Date   : 11/12/2014
#
# Description : Script pour :
#		- cree le user et l'environnement d un user linux
#
# Syntax : checkRootAppli.sh 
#
###################################################################################################################
#CHEMIN RACINE
PATHROOT="$PWD"

#RECUPERATION DES FONCTIONS
. $PATHROOT/../lib/functions.sh
##################################################################################################################
echo  "--------------------------------------------------------------------------------------------------"
echo  "                   TEST UTILISATEUR ROOT		   													 "
echo  "--------------------------------------------------------------------------------------------------"

# TEST PRE-REQUIS
checkUserRoot

echo  "--------------------------------------------------------------------------------------------------"
echo  "                   TEST APPLICATION		   														 "
echo  "--------------------------------------------------------------------------------------------------"

# Vérifier que perl est installé pour la gestion des mots de passe
checkAppli "perl"
checkAppli "node"
checkAppli "imagick"
