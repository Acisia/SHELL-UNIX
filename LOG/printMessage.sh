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
echo  "--------------------------------------------------------------------------------------------------"
echo  "                   TEST AFFICHAGE LOG                                                                                                                     "
echo  "--------------------------------------------------------------------------------------------------"
# initialisation du fichier de log
checkLog $PATHDEST_REPLOG $FICLOGNAME
echo  "----------------------------------"

printMessageToUser "J'affiche uniquement sur l'écran"

printFormatMessageToUser "J'affiche avec un style de formattage uniquement sur l'écran"

printMessageToLog "J'affiche uniquement dans le fichier de log $FICLOGNAME" "$PATHDEST_FICLOG"

printFormatMessageToLog "J'affiche avec un style de formattage uniquement dans le fichier de log  $FICLOGNAME" "$PATHDEST_FICLOG"

printMessageToLogAndUser "J'affiche à l'écran et dans le fichier de log $FICLOGNAME" "$PATHDEST_FICLOG"

printFormatMessageToLogAndUser "J'affiche avec un style de formattage à l'écran et dans le fichier de log  $FICLOGNAME" "$PATHDEST_FICLOG"
