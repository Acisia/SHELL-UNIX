#!/bin/bash
###################################################################################################################
# Author : Louis DAUBIGNARD
# Date   : 04/10/2015
#
# Description : Script pour :
#		- check le serveur
#
# Syntax : check_server.sh 
#
###################################################################################################################
#CHEMIN RACINE
PATHROOT="$PWD"
NOMPROJECTSCRIPT="CHECK SERVEUR LINUX"

#RECUPERATION DES FONCTIONS
. "$PATHROOT/../lib/functions.sh"

printMessageTo  "             $NOMPROJECTSCRIPT										" "1" 

##################################################################################################################
#RECUPERATION DES PROPERTIES
checkPathFile "$PATHROOT/../config/config.sh" "Fichier de config"
if [ $? -eq 0 ];then
	echo -e "\033[31m[ERREUR]\033[0m Manque fichier de config"
	exit 1
fi
. "$PATHROOT/../config/config.sh"
#CHECK DES LOGS
checkPathDst "$PATHDEST_REPLOG" "Chemin LOG"


##################################################################################################################
# TEST PRE-REQUIS
printMessageTo  "             CONTROLE APPLI										" "3" 
# Vérifier que l'utilisateur est root
checkUserRoot
# Vérifier que perl est installé pour la gestion des mots de passe
checkAppli perl
##################################################################################################################

##################################################################################################################
# DEBUT PROCESS
# Vérifier que l'utilisateur est root
printMessageTo  "    PROCESS $NOMPROJECTSCRIPT START	 " "3" 

printMessageTo  "    HOSTNAME	 " "2"
hostname

printMessageTo  "    OS	 " "2"
cat /etc/lsb-release
cat /proc/version

printMessageTo  "    ARCHITECTURE	 " "2"
uname -i

printMessageTo  "    PROCESSEUR	 " "2"
cat /proc/cpuinfo |grep "model name"

printMessageTo  "    ESPACE DISQUE	 " "2"
df -h

printMessageTo  "    LISTE DES INTERFACES RESEAUX	 " "2"
ifconfig | perl -nle 's/dr:(\S+)/print $1/e'
netstat -i

printMessageTo  "    ADRESSE IP UP	 " "2"
INTERADDRIP=`ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/'`
if [ $INTERADDRIP ] ;then
	echo $INTERADDRIP
else
	INTERADDRIP=`ip addr | grep 'global' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/'`
	echo $INTERADDRIP
fi

printMessageTo  "    LISTE DES UTILISATEURS CONNECTES	 " "2"
w

printMessageTo  "    ALLOCATION DE LA RAM, MEMOIRE LIBRE, SWAP, CPU	 " "2"
vmstat

printMessageTo  "    LISTER LES DISQUES	 " "2"
fdisk -l

