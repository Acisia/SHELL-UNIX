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
NOMPROJECTSCRIPT="CREATION SERVEUR JEEDOM"
#RECUPERATION DES PARAMETRES
. "$PATHROOT/user_param.sh"

########################## Main Point entree ############################
# DEBUT ENTREE
setup_i18n
#RECUPERATION DES FONCTIONS
. "$PATHROOT/../lib/functions.sh"
##################################################################################################################
##################################################################################################################
# TEST PRE-REQUIS
# Vérifier que l'utilisateur est root
printMessageTo  "             CONTROLE APPLI			" "3" 
checkUserRoot
# Vérifier que perl est installé pour la gestion des mots de passe
checkAppli perl
############################ Traduction ##############################
#
install_msg_fr() {
    msg_installer_welcome="*      Bienvenue dans l'assistant d'intallation/mise à jour de SVOX Pico       *"
	msg_installer_name="*      Installation SVOX Pico       *"
	msg_file_config="\033[31m[ERREUR]\033[0m Manque fichier de config"
	msg_ctrl_system="\033[35m[00]\035[0m Contrôle - Pre-requis"
	msg_install_multiverse="\033[35m[01]\035[0m Installation Dépôts multiverse"
	msg_install_dependency="\033[35m[02]\035[0m Mise à jour du système"
	msg_install_dependency="\033[35m[03]\035[0m Installation des dépendances"
	msg_install_test="\033[35m[FIN]\035[0m Test de l'application"
	
############################ Fonctions ##############################
#
setup_i18n() {
    lang=${LANG:=en_US}
    case ${lang} in
        [Ff][Rr]*)
            install_msg_fr
        ;;
        [Ee][Nn]*|*)
            install_msg_en
        ;;
		[Pt][Pt]*|*)
            install_msg_pt
        ;;
        [De][De]*|*)
            install_msg_de
        ;;
    esac
}
install_srcmultiverse() {
	# source multiverse sur serveur français
	echo "deb http://fr.archive.ubuntu.com/ubuntu/ trusty universe multiverse" | sudo tee /etc/apt/sources.list.d/multiverse.list
	echo "deb http://security.ubuntu.com/ubuntu trusty-security universe multiverse" 	>> /etc/apt/sources.list.d/multiverse.list
	echo "deb http://fr.archive.ubuntu.com/ubuntu/ trusty-updates universe multiverse" 	>> /etc/apt/sources.list.d/multiverse.list
	# Cle serveur
	apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 40976EAF437D05B5
	apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 3B4FE6ACC0B21F32
	# mise a jour 
	apt-get update	
}


test_software() {
	#Test de lapplication
	pico2wave -l fr-FR -w test.wav "Bonjour vous avez installé pico2wave Félicitation"
	aplay test.wav
}
# FONCTIONS SPECIALES
getMenu() {
	#choix du systeme
	printMessageTo  "    MENU	 " "3" 
	printMessageTo  "Faites votre choix dans la liste suivante : " "2" 
	printMessageTo  " 1 - Cle apt/source.list" "21" 
	printMessageTo  " 2 - Pre-requis et dependances pour Raspberry" "21" 
	printMessageTo  " 3 - Installation Jeedom" "21" 
	printMessageTo  " 4 - Installation xPL" "21" 
	printMessageTo  " 5 - Installation Sonos" "21" 
	printMessageTo  " 6 - Installation Wifi" "21" 
	printMessageTo  " 7 - Installation Svox" "21" 
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

installRaspDependency() {
    apt-get update
    installPaquet 
    installPaquet build-essential
    installPaquet curl
	installPaquet git-core 
	installPaquet install automake 
	installPaquet install autogen 
	installPaquet libyaml-perl 
	installPaquet libyaml-syck-perl
	installPaquet libsub-name-perl 
    installPaquet libanyevent-perl 
    installPaquet libdatetime-format-dateparse-perl 
    installPaquet libconfig-yaml-perl 
    installPaquet librrds-perl 
    installPaquet libio-all-perl	
	installPaquet libtool 
	installPaquet libpopt-dev
	installPaquet xclip
	installPaquet alsa-utils
	#install pico
	installPaquet libttspico0 
	installPaquet libttspico-utils 
	installPaquet libttspico-data
	# zenity : Display graphical dialog boxes from shell scripts
	#apt-get -y install zenity
	# xsel : command-line tool to access X clipboard and selection buffers
	#apt-get -y install xsel

    apt-get autoremove
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

installServeurJeedom(){
	# Installation Jeedom
	cd /usr/src
	#1. Install and configure the necessary dependencies
	apt-get update
	apt-get upgrade
    wget -q https://raw.githubusercontent.com/jeedom/core/stable/install/install.sh
	chmod 777 install.sh
	./install.sh
	#2. installation razberry.z-wave.me
	wget -q -O - razberry.z-wave.me/install | bash
	service mongoose stop
	update-rc.d mongoose remove
	service nginx restart
	#3. droit root
	echo "www-data ALL=(ALL) NOPASSWD: ALL" | (EDITOR="tee -a" visudo)
	#4. Browse to the hostname and login
	echo "-------------------------------------------------"
	echo " |- Url : http://$IPLOCADRA/jeedom"
	echo " |- Username: admin"
	echo " |- Password: admin"
	echo "-------------------------------------------------"
}
installSvoxPico(){
	printMessageTo  "    ${msg_installer_name}	 " "3" 
	printMessageTo  "    ${msg_install_multiverse}	 " "2" 
	install_srcmultiverse
	printMessageTo  "    ${msg_install_dependency}	 " "2"
	install_dependency
	printMessageTo  "    ${msg_install_test}	 " "2" 
	test_software
}
installServeurxPL(){
	cd /usr/src
	wget http://www.xpl4java.org/xPL4Linux/downloads/xPLLib.tgz
	tar -xzvf xPLLib.tgz
	cd xPLLib
	make
	cd examples
	make
	file xPL_Hub
	cp xPL_Hub /usr/local/bin
	#librairie et logger
	cd /usr/src
	wget https://github.com/downloads/beanz/xpl-perl/xPL-Perl-0.12.tar.gz
	tar -xzvf xPL-Perl-0.12.tar.gz
	cd xPL-Perl-0.12
    perl Makefile.PL
    make    
    make install
	echo "A installer"
	perl -MCPAN -e shell
	echo install YAML::Syck
	echo quit;
}
##################################################################################################################
printMessageTo  "             $NOMPROJECTSCRIPT		 								" "1" 


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
			installRaspDependency
		 ;;		 
		 "3" )
			printMessageTo  "    PROCESS 3: Installation Jeedom " "3" 
			installLamp			
			exit 1
		 ;;
		  "4" )
			printMessageTo  "    PROCESS 4: Installation xPL " "3" 
			configLamp
			exit 1
		 ;;
		 "5" )
			printMessageTo  "    PROCESS 5: Installation Sonos " "3" 
			installXamp
			exit 1
		 ;;
		 "6" )
			printMessageTo  "    PROCESS 6: Installation Wifi " "3" 
			checkServeurWeb
		 ;;
		 "7" )
			printMessageTo  "    PROCESS 7: Installation Svox " "3" 
			installSvoxPico
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
