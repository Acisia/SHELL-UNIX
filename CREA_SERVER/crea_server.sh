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
	printMessageTo  " 1 - Cle apt/source.list" "21" 
	printMessageTo  " 2 - Pre-requis et dependances" "21" 
	printMessageTo  " 3 - Serveur Web standard LAMP" "21" 
	printMessageTo  " 4 - Configuration Web standard LAMP" "21" 
	printMessageTo  " 5 - Serveur Web XAMP" "21" 
	printMessageTo  " 6 - Check Version" "21" 
	printMessageTo  " 7 - Install MySql Serveur 5" "21" 
	printMessageTo  " 8 - Install GitLab" "21" 
	printMessageTo  " 9 - Supprimer Appache 2" "21" 
	printMessageTo  " h - Commande " "21" 
	printMessageTo  " q - Quitter " "21" 

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
installPaquet() {
	if [ "$1" ];then
		printMessageTo  "   INSTALLATION PAQUET : $1	 " "3" 
		apt-get -y install "$1"
	else	
		printMessageTo  "   INSTALLATION PAQUET	 " "3" 
		apt-get -y install
	fi		
}
getVersion() {
	if [ "$1" ];then
		val_paquet=`apt-show-versions "$1" |cut -d" " -f1 |cut -d"/" -f1`
		val_paquet_dist=`apt-show-versions "$1" |cut -d" " -f1 |cut -d"/" -f2`
		val_version=`apt-show-versions "$1" |cut -d" " -f2`
		val_version_st=`apt-show-versions "$1" |cut -d" " -f3`
		printMessageTo  "   $1  " "3" 
		printMessageTo  "   Paquet : 	$val_paquet " "2" 
		printMessageTo  "   Distribution : 	$val_paquet_dist " "2" 
		printMessageTo  "   Version : 	$val_version " "2" 
		printMessageTo  "   Version : 	$val_version_st " "2" 
		
	fi	
}
get_ip_local(){
	INTERADDRIP=`ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/'`
	if [ $INTERADDRIP ] ;then
		IPLOCADRA=$INTERADDRIP
	else
		INTERADDRIP=`ip addr | grep 'global' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/'`
		IPLOCADRA=$INTERADDRIP
	fi
	readonly IPLOCADRA
}
installDependency() {
    apt-get update
    installPaquet 
    installPaquet build-essential
	installPaquet apt-show-versions
    installPaquet curl
	installPaquet git-core 
	installPaquet automake 
	installPaquet autogen 
	installPaquet libtool
	installPaquet acl
	installPaquet ruby
	installPaquet ruby-dev
	installPaquet imagemagick 
	installPaquet libmagickwand-dev
}
installServeurBDD() {
	installPaquet mysql-server-5.5
}
installServeurWeb() {
	installPaquet apache2
	installPaquet php5 
	installPaquet php5-fpm 
	installPaquet php5-gmp 
	installPaquet php5-imap 
	installPaquet php5-mcrypt 
	installPaquet php5-sqlite 
	installPaquet php5-xsl 
	installPaquet php5-curl 
	installPaquet php5-cli 
	installPaquet php5-common 
	installPaquet php5-gd 
	installPaquet php5-mysql
	installPaquet php5-intl
	installPaquet php-pear
	installPaquet php5-imagick 
	installPaquet php5-ps
	installPaquet php5-pspell 
	installPaquet php5-recode 
	installPaquet php5-snmp
	installPaquet php5-tidy 
	installPaquet php5-xmlrpc	
}
checkServeurWeb() {
	printMessageTo  "   TEST LAMP	 " "3" 
	service apache2 status	
	whereis apache2	
	printMessageTo  "   VERSION	 " "3" 	
	getVersion apache2
	getVersion php5 
	getVersion php5-fpm 
	getVersion php5-gmp 
	getVersion php5-imap 
	getVersion php5-mcrypt 
	getVersion php5-sqlite 
	getVersion php5-xsl 
	getVersion php5-curl 
	getVersion php5-cli 
	getVersion php5-common 
	getVersion php5-gd 
	getVersion php5-mysql 
	getVersion php5-imagick 
	getVersion php5-ps
	getVersion php5-pspell 
	getVersion php5-recode 
	getVersion php5-snmp
	getVersion php5-tidy 
	getVersion php5-xmlrpc
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
configLamp() {
	printMessageTo  "    LAMP	 " "3" 
	printMessageTo  "/usr/sbin/apache2" "2"
	printMessageTo  "/usr/lib/apache2 " "2"
	printMessageTo  "/etc/apache2 " "2"
	printMessageTo  "/usr/share/apache2" "2"
	
}
killApache() {
	#ecoute sur le port 80
	TESTPROCAPA=`netstat -an|grep :80`
	if [[ $TESTPROCAPA == "" ]];then
		printMessageTo  "\033[32m[OK]\033[0m Pas de process sur le port 80" "3" 
	else
		printMessageTo  "\033[31m[KO]\033[0m Arret server web" "3" 
		/etc/init.d/apache2 stop
	fi
}
removeApache() {
	printMessageTo  "    Suppression Apache 2	 " "3" 
	killApache
	apt-get remove apache2
	apt-get purge apache2
	post_install
	rm -r /etc/apache2
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
installServeurGitLab(){
	# Installation GitLab
	cd /usr/src
	#1. Install and configure the necessary dependencies
	apt-get update
    installPaquet 
    installPaquet build-essential
	installPaquet apt-show-versions
    installPaquet curl
	installPaquet ca-certificates 
	installPaquet postfix
	#2. Add the GitLab package server and install the package
	curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | bash
	installPaquet gitlab-ce
	#3. Configure and start GitLab
	gitlab-ctl reconfigure
	#4. Browse to the hostname and login
	echo "-------------------------------------------------"
	echo " |- Url : http://$IPLOCADRA"
	echo " |- Username: root"
	echo " |- Password: 5iveL!fe"
	echo "-------------------------------------------------"
}
##################################################################################################################
printMessageTo  "             $NOMPROJECTSCRIPT		 								" "1" 

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

# affichage menu
get_ip_local
getMenu

# traitement du choix
while true
do
	printMessageTo  " Tapper \033[35mm\033[0m pour obtenir le menu"
	printMessageTo  " Tapper votre choix :"
	read reponse
	case "$reponse" in
		 "1" )
			printMessageTo  "    PROCESS 1: Cle apt/source.list " "3" 
			#Gestion clés
			getSrcKeys	
			#Mise a jour du systeme	
			apt-get update
		 ;;
		 "2" )
			printMessageTo  "    PROCESS 2: Pre-requis et dependances " "3" 
			# Installation Package essentiel
			installDependency
		 ;;
		 "3" )
			printMessageTo  "    PROCESS 3: Serveur web Lamp " "3" 
			installLamp			
			exit 1
		 ;;
		  "4" )
			printMessageTo  "    PROCESS 4: Configuration Serveur web Lamp " "3" 
			configLamp
			exit 1
		 ;;
		 "5" )
			printMessageTo  "    PROCESS 5: Serveur web Xamp " "3" 
			installXamp
			exit 1
		 ;;
		 "6" )
			printMessageTo  "    PROCESS 6: Check Version " "3" 
			checkServeurWeb
		 ;;
		 "7" )
			printMessageTo  "    PROCESS 7: Installation Serveur Mysql 5 " "3" 
			installServeurBDD
		 ;;
		 "8" )
			printMessageTo  "    PROCESS 8: Installation Serveur GitLab " "3" 
			installServeurGitLab
		 ;;
		 "9" )
			printMessageTo  "    PROCESS 9: Supprimer Apache 2 " "3" 
			removeApache
		 ;;
		 "h" )
			getMenu
		 ;;
		 "m" )
			getMenu
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
		   getMenu
		 ;; 
	esac
done
#Sortie
exit 0
