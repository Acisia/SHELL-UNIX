#!/bin/bash
###################################################################################################################
# Author : Louis DAUBIGNARD
# Date   : 24/09/2015
#
# Description : Script pour :
#		- cree le serveur
#
# Syntax : crea_server.sh 
#
###################################################################################################################
#CHEMIN RACINE
PATHROOT="$PWD"
NOMPROJECTSCRIPT="CREATION SERVEUR LINUX"
#RECUPERATION DES PARAMETRES
. "$PATHROOT/user_param.sh"

#RECUPERATION DES FONCTIONS
. "$PATHROOT/../lib/functions.sh"
##################################################################################################################
# FONCTIONS SPECIALES
getMenu() {
	#choix du systeme
	printMessageTo  "    MENU	 " "3" 
	printMessageTo  "Faites votre choix dans la liste suivante : " "2" 
	printMessageTo  " 1 - Serveur Web standard LAMP" "2" 
	printMessageTo  " 2 - Serveur Web XAMP" "2" 
	printMessageTo  " h - Commande " "2" 
	printMessageTo  " q - Quitter " "2" 

}
getSrcKeys() {
	# Gestion des clés public pour apt-get update
	apt-get install debian-keyring debian-archive-keyring
	if [ $? -gt 0 ]; then
			echo "[ERREUR] Problème de clés !"
			exit 1
		else		
			echo -e "\033[32m[OK]\033[0m clés ajoutés!"		
		fi
		
	apt-key update
	if [ $? -gt 0 ]; then
			echo "[ERREUR] Problème de clés !"
			exit 1
		else		
			echo -e "\033[32m[OK]\033[0m clés mises a jour!"		
		fi
}
installDependency() {
    apt-get update
    apt-get -y install
    apt-get -y install build-essential
    apt-get -y install curl
	apt-get -y install git-core 
	apt-get -y install automake 
	apt-get -y install autogen 
	apt-get -y install libtool
	apt-get -y install acl
	apt-get -y install ruby
	apt-get -y install ruby-dev	
}
installServeurWeb() {
	apt-get -y install apache2
	apt-get -y install php5 
	apt-get -y install php5-fpm 
	apt-get -y install php5-curl 
	apt-get -y install php5-cli 
	apt-get -y install php5-common 
	apt-get -y install php5-gd 
	apt-get -y install php5-mysql 
}
checkServeurWeb() {
	printMessageTo  "   TEST LAMP	 " "3" 
	service apache2 status	
	whereis apache2	
	php -v
}
post_install() {
	apt-get autoremove
}
installLamp() {
	printMessageTo  "    LAMP	 " "3" 
	installServeurWeb
	post_install
	checkServeurWeb
}
installXamp() {
	# Installation XAMPP
	cd /usr/src
	wget --no-check-certificate  https://www.apachefriends.org/xampp-files/5.6.12/xampp-linux-5.6.12-0-installer.run
	echo " Apache 2.4.16, MySQL 5.6.26, PHP 5.6.12 & PEAR + SQLite 2.8.17/3.7.17 + multibyte (mbstring) support, Perl 5.16.3, ProFTPD 1.3.4c, phpMyAdmin 4.4.14, OpenSSL 1.0.1p, GD 2.0.35, Freetype2 2.4.8, libpng 1.5.9, gdbm 1.8.3, zlib 1.2.8, expat 2.0.1, Sablotron 1.0.3, libxml 2.0.1, Ming 0.4.5, Webalizer 2.23-05, pdf class 0.11.7, ncurses 5.9, pdf class 0.11.7, mod_perl 2.0.8-dev, FreeTDS 0.91, gettext 0.18.1.1, IMAP C-Client 2007e, OpenLDAP (client) 2.4.21, mcrypt 2.5.8, mhash 0.9.9.9, cUrl 7.30.0, libxslt 1.1.28, libapreq 2.12, FPDF 1.7, ICU4C Library 4.8.1, APR 1.4.6, APR-utils 1.5.1"
	chmod 755 xampp-linux-*-installer.run
	./xampp-linux-*-installer.run

	#Démarrer XAMPP
	/opt/lampp/lampp start

	# Rappel
	echo "-------------------------------------------------"
	echo " |- The MySQL administrator (root) has no password."
	echo " |- The MySQL daemon is accessible via network."
	echo " |- ProFTPD uses the password lampp for user daemon."
	echo " |- PhpMyAdmin is accessible via network."
	echo " |- Examples are accessible via network."
	echo "-------------------------------------------------"

	#Sécurité
	#sudo /opt/lampp/lampp security

	cd /opt/lamp/
}
##################################################################################################################
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
printMessageTo  "    PROCESS $NOMPROJECTSCRIPT START	 " "3" 
# Deplacement dans le dossier personnel de l'utilisateur
cd ~
#Gestion clés
getSrcKeys

#Mise a jour du systeme	
apt-get update

# Installation Package essentiel
installDependency
# affichage menu
getMenu

# traitement du choix
while true
do
	printMessageTo  " Tapper votre choix :"
	read reponse
	case "$reponse" in
		 "1" )
			printMessageTo  "    PROCESS 1: Serveur web Lamp " "3" 
			installLamp			
			exit 1
		 ;;
		  "2" )
			printMessageTo  "    PROCESS 1: Serveur web Xamp " "3" 
			installXamp
			exit 1
		 ;;
		 "3" )
			printMessageTo  "    PROCESS 3:  " "3" 
			
		 ;;
		 "4" )
			printMessageTo  "    PROCESS 4: " "3" 
			
		 ;;
		 "5" )
			printMessageTo  "    PROCESS 5:  " "3" 
			
		 ;;
		 "h" )
			printMessageTo  "    COMMANDES  " "3" 
			printMessageTo  "Pour sortir  : \033[35mq\033[0m " "2"
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
#Sortie
exit 0
