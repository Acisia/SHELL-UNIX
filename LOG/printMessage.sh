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

printMessageTo "J'affiche uniquement sur l'écran" 

printMessageTo "J'affiche avec le style de formattage 2 uniquement sur l'écran" "2"

printMessageTo "J'affiche un titre uniquement sur l'écran" "1"

printMessageTo "J'affiche avec un style de formattage à l'écran et dans le fichier de log  $FICLOGNAME" "2" "2" "$PATHDEST_FICLOG"

printMessageTo "J'affiche avec un style de formattage dans le fichier de log  $FICLOGNAME" "2" "1" "$PATHDEST_FICLOG"

printMessageTo "J'affiche avec un style de formattage à l'écran" "1" "1" "$PATHDEST_FICLOG"

printMessageTo "TITRE" "1" "2" "$PATHDEST_FICLOG"
