#!/bin/sh
#######################################################################
# Author : Louis DAUBIGNARD
# Date   : 07/10/2015
#
# Description : Script pour :
#		- Installation application SVOX
#
# Syntax : [application].sh 
#
########################################################################
# Sources web :
#	http://forum.ubuntu-fr.org/viewtopic.php?id=108430
#	http://blog.erwan.me/post/2015/05/06/Synth%C3%A8se-vocale-sous-Ubuntu-avec-SVOX-pico-TTS
#	http://elinux.org/RPi_Text_to_Speech_%28Speech_Synthesis%29#Pico_Text_to_Speech
#	http://wiki.freeswitch.org/wiki/Mod_tts_commandline
########################################################################
#CHEMIN RACINE
PATHROOT="$PWD"
###########
clear
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
	
}
install_msg_en() {
    msg_installer_welcome="*      Welcome to SVOX Pico installer/updater        *"
	msg_installer_name="*      SVOX Pico Installer      *"
	msg_file_config="\033[31m[ERROR]\033[0m Config file is missing"
	msg_ctrl_system="\033[35m[00]\035[0m Control - Pre-requisite"
	msg_install_multiverse="\033[35m[01]\035[0m Installation Dépôts multiverse"
	msg_install_dependency="\033[35m[02]\035[0m Mise à jour du système"
	msg_install_dependency="\033[35m[03]\035[0m Installation des dépendances"
	msg_install_test="\033[35m[FIN]\035[0m Test de l'application"
}
install_msg_pt() {
    msg_installer_welcome="*      Bem-vindo ao assistente de instalação / atualização SVOX Pico        *"
	msg_installer_name="*      SVOX Pico instalação      *"
	msg_file_config="\033[31m[ERROR]\033[0m Config file is missing"
	msg_ctrl_system="\033[35m[00]\035[0m Controle - Pré-requisito"
	msg_install_multiverse="\033[35m[01]\035[0m Multiverse source install"
	msg_install_dependency="\033[35m[02]\035[0m System Update"
	msg_install_dependency="\033[35m[03]\035[0m Dependency install"
	msg_install_test="\033[35m[FIN]\035[0m Test"	
}
install_msg_de() {
    msg_installer_welcome="*       Willkommen beim SVOX Pico Installer / Updater       *"
	msg_installer_name="*      SVOX Pico Installer      *"
	msg_file_config="\033[31m[ERROR]\033[0m Config file is missing"
	msg_ctrl_system="\033[35m[00]\035[0m Steuerung - Erforderliche"
	msg_install_multiverse="\033[35m[01]\035[0m Multiverse source install"
	msg_install_dependency="\033[35m[02]\035[0m System Update"
	msg_install_dependency="\033[35m[03]\035[0m Dependency install"
	msg_install_test="\033[35m[FIN]\035[0m Test"
}
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
install_dependency() {
    apt-get update
    apt-get -y install
    apt-get -y install build-essential
    apt-get -y install curl
	apt-get -y install git-core 
	apt-get -y install automake 
	apt-get -y install autogen 
	apt-get -y install libtool 
	apt-get -y install libpopt-dev
	apt-get -y install xclip
	apt-get -y install alsa-utils
	#install pico
	apt-get -y install libttspico0 
	apt-get -y install libttspico-utils 
	apt-get -y install libttspico-data
	# zenity : Display graphical dialog boxes from shell scripts
	#apt-get -y install zenity
	# xsel : command-line tool to access X clipboard and selection buffers
	#apt-get -y install xsel

    apt-get autoremove
}

test_software() {
	#Test de lapplication
	pico2wave -l fr-FR -w test.wav "Bonjour vous avez installé pico2wave Félicitation"
	aplay test.wav
}
########################## Main Point entree ############################
# DEBUT ENTREE
setup_i18n
############################ Lib Fonctions ##############################
#
. "$PATHROOT/../lib/functions.sh"
printMessageTo  "             ${msg_installer_welcome}			" "1" 

########################## Fic Configuration ############################
#
checkPathFile "$PATHROOT/../config/config.sh" "Fichier de config"
if [ $? -eq 0 ];then
	echo -e "${msg_file_config}"
	exit 1
fi
. "$PATHROOT/../config/config.sh"
#CHECK DES LOGS
checkPathDst "$PATHDEST_REPLOG" "Chemin LOG"
##################################################################################################################
# TEST PRE-REQUIS
# Vérifier que l'utilisateur est root
printMessageTo  "             CONTROLE APPLI			" "3" 
checkUserRoot
# Vérifier que perl est installé pour la gestion des mots de passe
checkAppli perl
##################################################################################################################
# DEBUT PROCESS
printMessageTo  "    ${msg_installer_name}	 " "3" 
printMessageTo  "    ${msg_install_multiverse}	 " "2" 
install_srcmultiverse
printMessageTo  "    ${msg_install_dependency}	 " "2"
install_dependency
printMessageTo  "    ${msg_install_test}	 " "2" 
test_software



