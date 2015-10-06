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
PATHVAGRANTVM="/root/project"
###########
clear
#RECUPERATION DES FONCTIONS
. "$PATHROOT/../lib/functions.sh"

printMessageTo  "             $NOMPROJECTSCRIPT			" "1" 

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
printMessageTo  "             CONTROLE APPLI			" "3" 
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
#deplacement dans l espace de travail
cd "$PATHVAGRANTVM/$PROJECTNAME"
#choix du systeme d exploitation
printMessageTo  "    MENU VAGRANT	 " "3" 
printMessageTo  "Faites votre choix dans la liste suivante : " "2" 
printMessageTo  " 1 - Vagrant Ubuntu Server 14.04 LTS (trusty32)" "2" 
printMessageTo  " 2 - Vagrant Ubuntu Server 14.04 LTS (trusty64)" "2" 
printMessageTo  " 3 - Vagrant Debian 8 (Jessie64) " "2" 
printMessageTo  " 4 - Vagrant Debian 7.5 (Wheezy64) " "2" 
printMessageTo  " 5 - Vagrant Android x86 " "2" 
printMessageTo  " h - Commande vagrant " "2" 
printMessageTo  " q - Quitter " "2" 

while true
do
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
		 "h" )
			printMessageTo  "    COMMANDES VAGRANT	 " "3" 
			printMessageTo  "Pour ajouter une box : \033[35mvagrant box add\033[0m nom_de_ma_box url_de_la_box" "2"
			printMessageTo  "Pour supprimer une box : \033[35mvagrant box remove\033[0m nom_de_ma_box" "2"
			printMessageTo  "Pour lister les box existantes : \033[35mvagrant box list\033[0m" "2"
			printMessageTo  "Pour lancer la machine virtuelle : \033[35mvagrant up\033[0m" "2"
			printMessageTo  "Pour se connecter en SSH  à la VM : \033[35mvagrant ssh\033[0m" "2"
			printMessageTo  "\t\t|--Pour obtenir les droit root \033[35msudo su -\033[0m" "2"   
			printMessageTo  "Pour mettre la VM en veille prolongée : \033[35mvagrant suspend\033[0m" "2"
			printMessageTo  "Pour arrêter la VM : \033[35mvagrant halt\033[0m" "2"
			printMessageTo  "Pour relancer la VM : \033[35mvagrant resume\033[0m" "2"
			printMessageTo  "Pour provisionner la VM : \033[35mvagrant provision\033[0m" "2"
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
done
##################################################################################################################
# Commande Vagrant
printMessageTo  "   RAPPEL COMMANDES VAGRANT BASIQUE	 " "3" 
printMessageTo  "Voici les commandes de bases : " "2"   
printMessageTo  "\033[35mvagrant ssh\033[0m : connexion ssh " "2"   
printMessageTo  "\t\t|--\033[35msudo su -\033[0m :  droit root sans mot de passe" "2"   
printMessageTo  "\033[35mvagrant up\033[0m : demarage VM " "2"   
printMessageTo  "\033[35mvagrant halt\033[0m : arrêt VM " "2"   
printMessageTo  "\033[35mvagrant provision\033[0m : mets a jour VM " "2"   


exit 0
