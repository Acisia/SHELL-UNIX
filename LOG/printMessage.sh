#!/bin/bash
###################################################################################################################
# Author : Louis DAUBIGNARD
# Date   : 17/12/2014
#
# Description : Script pour :
#		- Affichage dans les log ou sur console
#
# Syntax : printMessage.sh 
#
###################################################################################################################
#CHEMIN RACINE
PATHROOT="$PWD"

#RECUPERATION DES PROPERTIES
. $PATHROOT/../config/config.sh
#RECUPERATION DES FONCTIONS
. $PATHROOT/../lib/functions.sh

##################################################################################################################
# nettoyage
clear

printMessageTo "TEST AFFICHAGE LOG" "1" "2" "$PATHDEST_FICLOG"
# initialisation du fichier de log
checkLog $PATHDEST_REPLOG $FICLOGNAME
echo  "----------------------------------"

printMessageTo "1 - J'affiche uniquement sur l'écran" 

printMessageTo "2 - J'affiche avec le style de formatage 2 uniquement sur l'écran" "2"

printMessageTo "3 - J'affiche un titre uniquement sur l'écran" "1"

printMessageTo "4 - J'affiche avec un style de formatage à l'écran et dans le fichier de log  $FICLOGNAME" "2" "2" "$PATHDEST_FICLOG"

printMessageTo "5 - J'affiche avec un style de formatage dans le fichier de log  $FICLOGNAME" "2" "1" "$PATHDEST_FICLOG"

printMessageTo "6 - J'affiche avec un style de formatage à l'écran" "1" "1" "$PATHDEST_FICLOG"

printMessageTo "7 - TITRE" "1" "2" "$PATHDEST_FICLOG"
