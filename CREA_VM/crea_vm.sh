#!/bin/bash
###################################################################################################################
# Author : Louis DAUBIGNARD
# Date   : 05/10/2015
#
# Description : Script pour :
#		- cree le serveur
#
# Syntax : crea_vm.sh 
#
###################################################################################################################
#CHEMIN RACINE
PATHROOT="$PWD"
NOMPROJECTSCRIPT="CREATION VM AVEC VAGRANT"
PROJECTNAME=""
PATHVAGRANTVM="/c/VAGRANT/"
###########
clear
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
# Vérifier que l'utilisateur est root
printMessageTo  "             CONTROLE APPLI										" "3" 
#checkUserRoot
# Vérifier que perl est installé pour la gestion des mots de passe
checkAppli perl
checkAppli vagrant
#checkAppli VirtualBox
##################################################################################################################
# DEBUT PROCESS
# Vérifier que l'utilisateur est root
printMessageTo  "    PROCESS $NOMPROJECTSCRIPT START	 " "3" 


# Deplacement dans le dossier Vagrant de l'utilisateur
cd "$PATHVAGRANTVM"

if [ $# -eq 0 ]
	then		
		echo -e  "\033[31m[ERREUR]\033[0m Manque paramètre Nom du projet"
		exit 1		
	else	
		PROJECTNAME=$1
		printMessageTo "\033[32m[PROJECT][OK]\033[0m $1"	"2"	
	fi

#creation espace de travail
checkPathDst "$PATHVAGRANTVM/$PROJECTNAME" "Espace de travail vagrant"
#choix du systeme d exploitation
printMessageTo  "    MENU VAGRANT	 " "3" 
printMessageTo  "Faites votre choix dans la liste suivante : " "2" 
printMessageTo  " 1 - Vagrant Ubuntu Server 14.04 LTS (trusty32)" "2" 
printMessageTo  " 2 - Vagrant Ubuntu Server 14.04 LTS (trusty64)" "2" 
printMessageTo  " 3 - Vagrant Debian 8 (Jessie64) " "2" 
printMessageTo  " 4 - Vagrant Debian 7.5 (Wheezy64) " "2" 
printMessageTo  " 5 - Vagrant Android x86 " "2" 
printMessageTo  " q - Quitter " "2" 
printMessageTo  " Tapper votre choix :"
read reponse
case "$reponse" in
 "1" )
	printMessageTo  "    PROCESS 1: Ubuntu Server 14.04 LTS ubuntu/trusty32 " "3" 
	vagrant init ubuntu/trusty32; vagrant up --provider virtualbox
 ;;
  "2" )
	printMessageTo  "    PROCESS 2: Ubuntu Server 14.04 LTS ubuntu/trusty64 " "3" 
	vagrant init ubuntu/trusty64; vagrant up --provider virtualbox
 ;;
 "3" )
	printMessageTo  "    PROCESS 3: Debian 8 debian/jessie64 " "3" 
	vagrant init debian/jessie64; vagrant up --provider virtualbox
 ;;
 "4" )
	printMessageTo  "    PROCESS 4: Debian 7.5 (Wheezy64) puphpet/debian75-x64 " "3" 
	vagrant init puphpet/debian75-x64; vagrant up --provider virtualbox
 ;;
 "5" )
	printMessageTo  "    PROCESS 5: Android x86 dictcp/android-x86 " "3" 
	vagrant init dictcp/android-x86; vagrant up --provider virtualbox
 ;;
 "q" | "Q" )  
	echo "Au revoir...."
	exit 1
 ;; 
 * )
   # Default option.    
   # Empty input (hitting RETURN) fits here, too.
   echo
   printMessageTo "\033[31m[ERREUR]\033[0m mauvais choix" "2"
 ;;
 
esac  
exit 0
