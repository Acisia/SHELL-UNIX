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
FICHIERJSON="/var/www/html/compare.json"
readonly $FICHIERJSON
#RECUPERATION DES FONCTIONS
. "$PATHROOT/../lib/functions.sh"
clear
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
# AFFICHAGE FORMMATTAGE OU PAS
if [ $1 ];then
	val_format=1
	printMessageTo "\033[32m[FORMATAGE][OK]\033[0m " "2"
else
	val_format=0
	printMessageTo "\033[31m[FORMATAGE][KO]\033[0m " "2"
fi
if [ $2 ];then
	val_print=1
	printMessageTo "\033[32m[PRINT][OK]\033[0m " "2"
else
	val_print=0
	printMessageTo "\033[31m[PRINT][KO]\033[0m " "2"
fi
##################################################################################################################
# FONCTIONS
get_hostname(){
	val_format="$1"
	val_print="$2"
	val_hostname=`hostname`
	if [ $val_print -eq 1 ];then 		
		printMessageTo  "   Nom Machine : ${val_hostname}" "2"
	fi
	json_encode "$val_hostname" "hostname" $val_format $val_print
}
get_osinfo(){
	val_value="$1"
	val_label="$2"
	val_format="$3"
	val_print="$4"	
	if [ $val_print -eq 1 ];then 		
		printMessageTo  "   ${val_label} : ${val_value}" "2"
	fi
	json_encode "${val_value}" "${val_label}" $val_format $val_print
}
#echo  "--------------------------------------------------------------------------------------------------"
#echo  "	  - OS : $OS"
#echo  "	  - DISTRIB : $DIST"
#echo  "	  - DISTRIB BASE : $DistroBasedOn"
#echo  "	  - LOGIN : $PSUEDONAME"
#echo  "	  - REVISION : $REV"
#echo  "	  - KERNEL : $KERNEL"
#echo  "	  - MACHINE : $MACH"
#echo  "--------------------------------------------------------------------------------------------------"
lowercase(){
    echo "$1" | sed "y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/"
}
get_os(){
	OS=`lowercase \`uname\``
	KERNEL=`uname -r`
	MACH=`uname -m`

	if [ "{$OS}" == "windowsnt" ]; then
		OS=windows
	elif [ "{$OS}" == "darwin" ]; then
		OS=mac
	else
		OS=`uname`
		if [ "${OS}" = "SunOS" ] ; then
			OS=Solaris
			ARCH=`uname -p`
			OSSTR="${OS} ${REV}(${ARCH} `uname -v`)"
		elif [ "${OS}" = "AIX" ] ; then
			OSSTR="${OS} `oslevel` (`oslevel -r`)"
		elif [ "${OS}" = "Linux" ] ; then
			if [ -f /etc/redhat-release ] ; then
				DistroBasedOn='RedHat'
				DIST=`cat /etc/redhat-release |sed s/\ release.*//`
				PSUEDONAME=`cat /etc/redhat-release | sed s/.*\(// | sed s/\)//`
				REV=`cat /etc/redhat-release | sed s/.*release\ // | sed s/\ .*//`
			elif [ -f /etc/SuSE-release ] ; then
				DistroBasedOn='SuSe'
				PSUEDONAME=`cat /etc/SuSE-release | tr "\n" ' '| sed s/VERSION.*//`
				REV=`cat /etc/SuSE-release | tr "\n" ' ' | sed s/.*=\ //`
			elif [ -f /etc/mandrake-release ] ; then
				DistroBasedOn='Mandrake'
				PSUEDONAME=`cat /etc/mandrake-release | sed s/.*\(// | sed s/\)//`
				REV=`cat /etc/mandrake-release | sed s/.*release\ // | sed s/\ .*//`
			elif [ -f /etc/debian_version ] ; then
				DistroBasedOn='Debian'
				DIST=`lsb_release -a | grep Distributor | awk -F=  '{ print $2 }'`
				PSUEDONAME=`lsb_release -a | grep Codename | awk -F=  '{ print $2 }'`
				REV=`lsb_release -a | grep Release | awk -F=  '{ print $2 }'`
			fi
			if [ -f /etc/UnitedLinux-release ] ; then
				DIST="${DIST}[`cat /etc/UnitedLinux-release | tr "\n" ' ' | sed s/VERSION.*//`]"
			fi
			OS=`lowercase $OS`
			DistroBasedOn=`lowercase $DistroBasedOn`
			readonly OS			
			readonly DIST
			readonly DistroBasedOn
			readonly PSUEDONAME
			readonly REV
			readonly KERNEL
			readonly MACH
		fi

fi
}
# JSON
json_start(){
	val_format="$1"
	val_print="$2"
	if [ "$val_format" -eq 1 ];then 		
		echo -e "{\n\t\"hardware_lst\": {\n"
	else
		echo "{\"hardware_lst\":{" >> "${FICHIERJSON}"
	fi
	
}
json_end(){
	val_format="$1"
	val_print="$2"
if [ "$val_format" -eq 1 ];then 		
		echo -e "\n\t}\n}"
	else
		echo "}}" >> "${FICHIERJSON}"
	fi	
}

json_encode(){
	val_value="$1"
	val_label="$2"
	val_format="$3"
	val_print="$4"	
	if [ "$val_value" ];then
		val_value="$1"
	else
		val_value="non_communique"	
	fi
	if [ "$val_label" ];then
		val_label="$2"
	else
		val_label="objet"	
	fi
	if [ "$val_format" -eq 1 ];then 		
		echo -e "\t\t\"label\": \"$val_label\",\n\t\t\"value\": \"$val_value\""
	else
		echo "\"label\": \"$val_label\",\"value\": \"$val_value\"" >> "${FICHIERJSON}" 
	fi
	
}
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
# debut du fichier json
json_start $val_format $val_print
# recuperation des elements
get_hostname $val_format $val_print
get_os $val_format $val_print 
get_osinfo "$OS" "OS" $val_format $val_print 
get_osinfo "$DIST" "Distribution" $val_format $val_print 
get_osinfo "$DistroBasedOn" "DistributionBasedOn" $val_format $val_print 
get_osinfo "$PSUEDONAME" "Login" $val_format $val_print 
get_osinfo "$REV" "Revision" $val_format $val_print 
get_osinfo "$KERNEL" "Kernel" $val_format $val_print 
get_osinfo "$MACH" "Hardware" $val_format $val_print 
# fin du fichier json
json_end $val_format $val_print
exit 1

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

