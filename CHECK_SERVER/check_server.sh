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
FICHIERJSON="compare.json"
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
	printMessageTo "\033[36m[FORMATAGE][KO]\033[0m " "2"
fi
if [ $2 ];then
	val_print=1
	printMessageTo "\033[32m[PRINT][OK]\033[0m " "2"
else
	val_print=0
	printMessageTo "\033[36m[PRINT][KO]\033[0m " "2"
fi
##################################################################################################################
# FONCTIONS
installPaquet() {
	if [ "$1" ];then
		printMessageTo  "   INSTALLATION PAQUET : $1	 " "3" 
		apt-get -y install "$1"
	else	
		printMessageTo  "   INSTALLATION PAQUET	 " "3" 
		apt-get -y install
	fi		
}
checkLsbRelease() {
	val_lsbrelease=`lsb_release`
	val_error="No LSB modules are available."
	val_result="$?"
	if [[ $val_lsbrelease == *$val_error ]];then
		installPaquet lsb-core
	elif [ $val_result -eq 127 ];then
		installPaquet lsb-core		
	else 
		printMessageTo "\033[32m[LSB_RELEASE][OK]\033[0m " "2"
	fi
}
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
	val_value=$(echo "$1"| sed s/\"//g)
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
get_ip_public(){
	IPPUB=`curl -s 'ipinfo.io' | jq '.ip,.hostname,.city,.region,.country,.loc,.org'`
	IPPUBADR=`echo $IPPUB |cut -d "\"" -f2`
	IPPUBNOM=`echo $IPPUB |cut -d "\"" -f4`
	IPPUBVIL=`echo $IPPUB |cut -d "\"" -f6`
	IPPUBREG=`echo $IPPUB |cut -d "\"" -f8`
	IPPUBPAY=`echo $IPPUB |cut -d "\"" -f10`
	IPPUBLOC=`echo $IPPUB |cut -d "\"" -f12`
	IPPUBFOU=`echo $IPPUB |cut -d "\"" -f14`
	readonly IPPUBADR
	readonly IPPUBNOM
	readonly IPPUBVIL
	readonly IPPUBREG
	readonly IPPUBPAY
	readonly IPPUBLOC
	readonly IPPUBFOU	
}
get_ip_local(){
	IPLOCADR=`ifconfig | perl -nle 's/dr:(\S+)/print $1/e'| tr '\n' ','`
	#netstat -i
	INTERADDRIP=`ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/'`
	if [ $INTERADDRIP ] ;then
		IPLOCADRA=$INTERADDRIP
	else
		INTERADDRIP=`ip addr | grep 'global' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/'`
		IPLOCADRA=$INTERADDRIP
	fi

	readonly IPLOCADR
	readonly IPLOCADRA
}
get_disque_info(){
	 DISKINFO=`df -h |sed 1d |awk '{print $1":"$2}'| tr '\n' ','`	 
	 DISKINFOUSED=`df -h |sed 1d |awk '{print $1":"$3}'| tr '\n' ','`	 	 
	 DISKINFOAVAIL=`df -h |sed 1d |awk '{print $1":"$4}'| tr '\n' ','`	 
	 DISKINFOUSE=`df -h |sed 1d |awk '{print $1":"$5}'| tr '\n' ','`	 
	 DISKINFOMOUNT=`df -h |sed 1d |awk '{print $1":"$6}'| tr '\n' ','`
	 readonly DISKINFO
	 readonly DISKINFOUSED
	 readonly DISKINFOAVAIL
	 readonly DISKINFOUSE
	 readonly DISKINFOMOUNT
}
get_ram_info(){
	 RAMINFO=`free -h|sed 1d| sed -re 's/-\/\+//g' |awk '{print $1$2}'| tr '\n' ','`
	 RAMINFOUSED=`free -h|sed 1d| sed -re 's/-\/\+//g' |awk '{print $1$3}'| tr '\n' ','`
	 RAMINFOAVAIL=`free -h|sed 1d| sed -re 's/-\/\+//g' |awk '{print $1$4}'| tr '\n' ','`
	 readonly RAMINFO
	 readonly RAMINFOUSED
	 readonly RAMINFOAVAIL
}
get_service_installed(){
	val_format="$1"
	val_print="$2"
	dpkg-query -l |sed '1,5d' |while read id name version architecture description ; do 
		get_osinfo "$version" "$name"  $val_format $val_print ;
	 done
}
# JSON ---------------------------------------------
json_start(){
	val_format="$1"
	val_print="$2"
	val_name="$3"
	if [ "$val_format" -eq 1 ];then 		
		echo -e "{\n\t\"$val_name\": {\n"
	else
		echo "{\"$val_name\":{" > "${FICHIERJSON}"
	fi	
}
json_sub_start(){
	val_format="$1"
	val_print="$2"
	val_name="$3"
	if [ "$val_format" -eq 1 ];then 		
		echo -e "}\n\t\"$val_name\": {\n"
	else
		echo "}\"$val_name\":{" >> "${FICHIERJSON}"
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
		echo "\"$val_label\" : \"$val_value\"" >> "${FICHIERJSON}" 
	fi
	
}
##################################################################################################################
# TEST PRE-REQUIS
printMessageTo  "             CONTROLE APPLI										" "3" 
# Vérifier que l'utilisateur est root
# checkUserRoot
# Vérifier que perl est installé pour la gestion des mots de passe
checkAppli perl
# Vérifier que jq librairie pour parser le json
checkAppli jq
if [ $? -eq 0 ];then			
		installPaquet jq
	fi	
checkAppli curl
if [ $? -eq 0 ];then			
		installPaquet curl
	fi
##################################################################################################################

##################################################################################################################
# DEBUT PROCESS
# Vérifier que l'utilisateur est root
printMessageTo  "    PROCESS $NOMPROJECTSCRIPT START	 " "3" 
checkLsbRelease

# recuperation des elements
get_hostname $val_format $val_print
get_os $val_format $val_print 
get_ip_public $val_format $val_print 
get_ip_local $val_format $val_print
get_disque_info $val_format $val_print
get_ram_info  $val_format $val_print

# debut du fichier json
json_start $val_format $val_print  "HARDWARE_INFO"
# Affichage des resultats hostname
get_osinfo "$OS" "OS" $val_format $val_print 
get_osinfo "$DIST" "Distribution" $val_format $val_print 
get_osinfo "$DistroBasedOn" "DistributionBasedOn" $val_format $val_print 
get_osinfo "$PSUEDONAME" "Login" $val_format $val_print 
get_osinfo "$REV" "Revision" $val_format $val_print 
get_osinfo "$KERNEL" "Kernel" $val_format $val_print 
get_osinfo "$MACH" "Hardware" $val_format $val_print 
# Affichage des resultat IPPUBLIC
json_sub_start $val_format $val_print "NETWORK_PUBLIC_INFO"
get_osinfo "$IPPUBADR" "IpPub" $val_format $val_print
get_osinfo "$IPPUBNOM" "IpPubHostname" $val_format $val_print
get_osinfo "$IPPUBVIL" "IpPubCity" $val_format $val_print
get_osinfo "$IPPUBREG" "IpPubRegion" $val_format $val_print
get_osinfo "$IPPUBPAY" "IpPubCountry" $val_format $val_print
get_osinfo "$IPPUBLOC" "IpPubLocation" $val_format $val_print
get_osinfo "$IPPUBFOU" "IpPubProvider" $val_format $val_print
# Affichage des resultats IPLOCAL
json_sub_start $val_format $val_print "NETWORK_LOCAL_INFO"
get_osinfo "$IPLOCADRA" "IpLoc" $val_format $val_print
get_osinfo "$IPLOCADR" "IpLocLst" $val_format $val_print
# Affichage des resultat DISQUE
json_sub_start $val_format $val_print "DISK_INFO"
get_osinfo "$DISKINFO" "DiskInfo" $val_format $val_print
get_osinfo "$DISKINFOUSED" "DiskInfoUsed" $val_format $val_print
get_osinfo "$DISKINFOAVAIL" "DiskInfoAvailable" $val_format $val_print
get_osinfo "$DISKINFOUSE" "DiskInfoUse" $val_format $val_print
get_osinfo "$DISKINFOMOUNT" "DiskInfoMountedOn" $val_format $val_print
get_osinfo "$RAMINFO" "RamInfo" $val_format $val_print
get_osinfo "$RAMINFOUSED" "RamInfoUsed" $val_format $val_print
get_osinfo "$RAMINFOAVAIL" "RamInfoAvailable" $val_format $val_print

json_sub_start $val_format $val_print "SERVICES_INFO"
# Affichage liste des services
get_service_installed  $val_format $val_print

# fin du fichier json
json_end $val_format $val_print
exit 1

printMessageTo  "    ESPACE DISQUE	 " "2"
df -h

printMessageTo  "    LISTE DES UTILISATEURS CONNECTES	 " "2"
w

printMessageTo  "    ALLOCATION DE LA RAM, MEMOIRE LIBRE, SWAP, CPU	 " "2"
vmstat

printMessageTo  "    LISTER LES DISQUES	 " "2"
fdisk -l

