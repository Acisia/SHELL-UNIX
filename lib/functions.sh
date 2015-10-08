#!/bin/sh
###################################################################################################################
# Author : Louis DAUBIGNARD
# Date   : 31/07/2012
# 
# Description : Liste des fonctions utilisés dans les scripts de sauvegarde
#
# Ce fichier est à placer dans ../lib/function.sh
#
###################################################################################################################
#
# AFFICHAGE CONSOLE ET LOG
#
###################################################################################################################
# printMessageTo  $MESSAGE  $FORMATTAGE $DESTINATION $PATHDEST_FICLOG
printMessageTo(){
	MESSAGE=$1
	FORMATTAGE=$2  # (0=sans, 1=titre, 2=mise en avant)
	DESTINATION=$3 # (0=console, 1=fichier, 2=console et fichier)
	PATHDEST_FICLOG=$4
	MSG_ERREUR="\033[31m[ERREUR]\033[0m Manque paramètre Syntaxe : (printMessageTo  MESSAGE  FORMATTAGE DESTINATION PATHDEST_FICLOG)"
	
	if [ ! "$MESSAGE" ] 
	then
		echo -e $MSG_ERREUR
	fi

	if [ $FORMATTAGE ]; then
		# TEST 0=Pas de formattage
		if [ $FORMATTAGE -eq 0 ]; then
			MESSAGE=$MESSAGE
		# TEST 1=titre
		elif [ $FORMATTAGE -eq 1 ]; then
			MESSAGE="\033[33m------------------------------------------------------------------------\n    $(date +%d/%m/%Y)  |$MESSAGE\n------------------------------------------------------------------------\033[0m"
		# TEST 2=mise en avant
		elif [ $FORMATTAGE -eq 2 ]; then
			MESSAGE="\t\t\033[33m|\033[0m\n    $(date +%H:%M:%S) ---\033[33m|--\033[0m $MESSAGE\n\t\t\033[33m|\033[0m"
		# TEST 3=mise en avant
		elif [ $FORMATTAGE -eq 3 ]; then
			MESSAGE="\t\t\033[33m|---------------------------------------------------\n$(date +%d/%m/%Y) -----|$MESSAGE\n\t\t|---------------------------------------------------\033[0m"
		#Bloc resultat
		elif [ $FORMATTAGE -eq 4 ]; then
			MESSAGE="\033[33m-------------------------------------------------------------------------\n|\t\tFIN\t\t\t\t\t\t\t|\n-------------------------------------------------------------------------\n\n\033[0m$MESSAGE\n\n\033[33m-------------------------------------------------------------------------\033[0m"
		fi
	fi
	#traitement de la destination 
	if [ $DESTINATION ]; then
		# TEST 0=console
		if [ $DESTINATION -eq 0 ]; then
			echo -e "$MESSAGE"
		# TEST 1=fichier
		elif [ $DESTINATION -eq 1 ]; then			
			echo -e  "$MESSAGE" >> "$PATHDEST_FICLOG"
		# TEST 2=fichier et console
		elif [ $DESTINATION -eq 2 ]; then			
			echo -e  "$MESSAGE"
			echo -e  "$MESSAGE" >> "$PATHDEST_FICLOG"
		fi
	else
		#PAR DEFAUT : Sortie console
		echo -e  "$MESSAGE"
	fi
}

###################################################################################################################
#
# COMPTAGE
#
###################################################################################################################
# Compte le nombre d'occurence d'un caractère
# getNbCara $TEXT $CARA
getNbCara(){
	#!/bin/bash
	TEXT="$1"
	CARA="$2"
	echo $(echo $TEXT | sed 's/./&\n/g' | grep $CARA | wc -l)
}

# fonction affichant le nombre de fichier dans un dossier
getNbFicInDir(){
	CHEMINDOSSIER=$1
	PATHDEST_FICLOG=$2
	EXTENSION=$3
	SILENCEMODE=$4
	if [ ! -e "$CHEMINDOSSIER" ]
	then
		if [ ! "$SILENCEMODE" ]
			then
			#printMessageTo "Message à afficher" "0" "2" "$PATHDEST_FICLOG"
			printMessageTo "[ERROR][DIRECTORY] $CHEMINDOSSIER : KO" "2" "2" "$PATHDEST_FICLOG"			
		else	
			echo 0
		fi		
	elif [ "$EXTENSION" ]
		then
		NB_FILE=`ls -A1 $CHEMINDOSSIER | grep $EXTENSION | wc -l`
		if [ ! "$SILENCEMODE" ]
			then
			printMessageTo "Nombre de fichier $EXTENSION : $NB_FILE" "2" "2" "$PATHDEST_FICLOG"
		else	
			echo $NB_FILE
		fi
		
	else		
		NB_FILE=`ls -A1 $CHEMINDOSSIER | wc -l`
		if [ ! "$SILENCEMODE" ]
			then
			printMessageTo "Nombre de fichier : $NB_FILE" "2" "2" "$PATHDEST_FICLOG"			
		else
			echo $NB_FILE
		fi
		
	fi	
}

###################################################################################################################
#
# GESTION UTILISATEUR
#
###################################################################################################################
#Retourne le login à partir du nom et du prénom
# getLoginName $NOM $PRENOM
getLoginName(){
	NOM=$1
	PRENOM=$2
	#Traitement sans accent et sans espace tout en undescore
	NOM=$(echo "$NOM" | tr "àçéèêëîïôöùüÂÇÉÈÊËÎÏÔÖÙÜ -" "aceeeeiioouuACEEEEIIOOUU__")
	PRENOM=$(echo "$PRENOM" | tr "àçéèêëîïôöùüÂÇÉÈÊËÎÏÔÖÙÜ -" "aceeeeiioouuACEEEEIIOOUU__")
	# On compte les UNDERSCORE	
	NB_SPC_NOM=`getNbCara $NOM "_"`
	NB_SPC_PRENOM=`getNbCara $PRENOM "_"`
	
	# Gestion du nom	
	if [ $NB_SPC_NOM -gt 0 ]; 
		then
		# Extraction de la premiere lettre de chaque NOM
		NLETTRE1=$(echo $NOM | cut -f1 -d '_' | cut -c -2)
		NLETTRE2=$(echo $NOM | cut -f2 -d '_' )
		NOM=$NLETTRE1$NLETTRE2
	fi
	#Gestion du prenom
	if [ $NB_SPC_PRENOM -gt 0 ]; 
		then
		# Extraction de la premiere lettre de chaque Phrase
		PLETTRE1=$(echo $PRENOM | cut -f1 -d '_' | cut -c -1)
	else
		PLETTRE1=$(echo $PRENOM | cut -c -1)
	fi	
	#Construction du user login
	USER_LOGIN=$PLETTRE1$NOM
	# on retourne le login en minuscule
	echo $USER_LOGIN| tr '[:upper:]' '[:lower:]'
}

#getTplFic ".vimrc" "$CREA_USER" "$CREA_GROUP" "$DIR_HOME"
getTplFic(){	
	FILE_NAME="$1"
	CREA_USER="$2"
	CREA_GROUP="$3"
	DIR_HOME="$4"
	DIR_TPL="$5"
	if [ "$1" ]
	then
		#Copie du ficher template dans le dossier home
		cp "$DIR_TPL/$FILE_NAME.sample" "$DIR_HOME/$FILE_NAME"
		#Changement des droits
		chown "$CREA_USER":"$CREA_GROUP" "$DIR_HOME/$FILE_NAME"
	fi
}

# génération de mot de passe alléatoire
getPasswd() {
	local l=$1
       	[ "$l" == "" ] && l=16
      	tr -dc A-Za-z0-9_ < /dev/urandom | head -c ${l} | xargs
}

###################################################################################################################
#
# Check
#
###################################################################################################################
# checkLog $PATHDEST_FICLOG
checkLog(){
	PATHDEST_REPLOG=$1
	FICLOGNAME=$2
	PATHDEST_FICLOG="$PATHDEST_REPLOG/$FICLOGNAME"
		# Vérification du dossier de log
		if [ ! -e "$PATHDEST_REPLOG" ]
		then		
			mkdir "$PATHDEST_REPLOG"
			chmod -R 755 "$PATHDEST_REPLOG"
			echo -e "\033[32m[CTRL-LOG]\033[0m DOSSIER $PATHDEST_REPLOG : \033[32mOK\033[0m"
		else			
			echo -e "\033[32m[CTRL-LOG]\033[0m DOSSIER $PATHDEST_REPLOG : \033[32mOK\033[0m"
		fi
		# Vérification du fichier de log
		if [ ! -f "$PATHDEST_FICLOG" ]
		then		
			touch $PATHDEST_FICLOG			
			chmod -R 755 "$PATHDEST_FICLOG"
			TAILLE=`du -hs $PATHDEST_FICLOG`
			echo -e "\033[32m[CTRL-LOG]\033[0m FICHIER $FICLOGNAME : \033[32mOK\033[0m -> $TAILLE"
		else
			chmod -R 755 "$PATHDEST_FICLOG"
			TAILLE=`du -hs $PATHDEST_FICLOG`
			echo -e "\033[32m[CTRL-LOG]\033[0m FICHIER $FICLOGNAME : \033[32mOK\033[0m -> $TAILLE"
		fi
}
setEnvironment(){
	if [ $1 ]; then		
		ENVSET=$(echo $1| tr '[:lower:]' '[:upper:]')
	else		
		printMessageTo "[ENV][INFO] Environnement de travail : $ENVSET"  "2" 
		printMessageTo "[ENV][ERROR] Pas d environnement défini en parametre "  "2" 
		printMessageTo "[ENV][INFO]      INT (pour l'integration)"	 "2" 
		printMessageTo "[ENV][INFO]      REC (pour la recette)"	 "2" 
		printMessageTo "[ENV][INFO]      PROD (pour la production)"	 "2"
		exit 1
	fi
	#test de l environnement
	if [ $ENVSET = "INT" ]; then
		#INTEGRATION : 1
		printMessageTo "[ENV][INFO] PARAMETRE : $ENVSET"  "2" 
		return 1
		exit 1
	elif [ $ENVSET = "REC" ]; then
		#RECETTE : 2
		printMessageTo "[ENV][INFO] PARAMETRE : $ENVSET"  "2" 
		return 2
		exit 1
	elif [ $ENVSET = "PROD" ]; then
		#PRODUCTION : 3
		printMessageTo "[ENV][INFO] PARAMETRE : $ENVSET"  "2" 
		return 3
		exit 1
	else 
		printMessageTo "[ENV][ERROR] Parametre invalide : INT ou REC ou PROD"  "2" 
		exit 1		
	fi

}
#configEnvironment [ENVPARAM] [PATH_FILE_CONFIG]
configEnvironment() {
	if [ "$2" ]; then
		PATH_FILE_CONFIG="$2"
		printMessageTo "[ENV][INFO] CHEMIN : $PATH_FILE_CONFIG"  "2" 
	else
		printMessageTo "[ENV][ERROR] Pas de chemin de fichier de config defini en parametre"  "2" 
	fi	

	if [ $1 ]; then
		if [ $1 = 1 ]; then
			printMessageTo "[ENV][INFO] Environnement de travail : INTEGRATION"  "2" 
			PATH_FILE_CONFIG_INT="$PATH_FILE_CONFIG/config-int.sh"
			checkPathFile "$PATH_FILE_CONFIG_INT"  "$PATH_FILE_CONFIG_INT"
			ret=$?
			if [ $ret = 1 ]; then
				. "$PATH_FILE_CONFIG_INT"
			else 
				printMessageTo "[ENV][ERROR] Fichier de configuration (config-int.sh) absent"  "2" 
				exit 1	
			fi
		elif [ $1 = 2 ]; then
			printMessageTo "[ENV][INFO] Environnement de travail : RECETTE"  "2" 
			PATH_FILE_CONFIG_REC="$PATH_FILE_CONFIG/config-rec.sh"
			checkPathFile "$PATH_FILE_CONFIG_REC"  "$PATH_FILE_CONFIG_REC"
			ret=$?
			if [ $ret = 1 ]; then
				. "$PATH_FILE_CONFIG_REC"
			else 
				printMessageTo "[ENV][ERROR] Fichier de configuration (config-rec.sh) absent"  "2" 
				exit 1	
			fi
		elif [ $1 = 3 ]; then
			printMessageTo "[ENV][INFO] Environnement de travail : PRODUCTION"  "2" 
			PATH_FILE_CONFIG_PROD="$PATH_FILE_CONFIG/config-prod.sh"
			checkPathFile "$PATH_FILE_CONFIG_PROD"  "$PATH_FILE_CONFIG_PROD"
			ret=$?
			if [ $ret = 1 ]; then
				. "$PATH_FILE_CONFIG_PROD"
			else 
				printMessageTo "[ENV][ERROR] Fichier de configuration (config-prod.sh) absent"  "2" 
				exit 1	
			fi
		else
		 	printMessageTo "[ENV][ERROR] parametre entree non compris : 1=INT ou 2=REC ou 3=PROD"  "2" 
			exit 1
		fi
	else
		printMessageTo "[ENV][ERROR] Parametre invalide : 1=INT ou 2=REC ou 3=PROD"  "2" 
		exit 1
	fi	
}

checkVarOk(){
	#Check if variable is ok or not
	printMessageTo "[CHECK] result parameter..."  "2" "2" "$PATHDEST_FICLOG"
	if [ $# -eq 3 ]
	then
	    RESULT=1
		printMessageTo "[OK] variable is ok"  "2" "2" "$PATHDEST_FICLOG"
	else    
		if [ $# -eq 2 ]
		then
			printMessageTo "[ERROR] $1 is missing because $2 is unknown"  "2" "2" "$PATHDEST_FICLOG"
			RESULT=0		
		fi	
	return $RESULT
	fi
}

#test qu une fonction a 2 parametres en entree
check2ParamOk(){
	#Check the parameters 1 (ne=not equal, eq=equal)
	if [ $# -eq 0 ]
	then
		printMessageTo "[ERROR][PARAM] $0 arguments are required "  "2" "2" "$PATHDEST_FICLOG"
	fi

	#check the parameters 2
	if [ $# -eq 1 ]
	then
		printMessageTo "[ERROR][PARAM]  2 arguments are required"  "2" "2" "$PATHDEST_FICLOG"
	fi
}

# fonction test du chemin --> checkPathDst [chemin de destination] [nom du chemin]
checkPathDst(){
	CHEMINDST=$1
	CHEMINNOM=$2
	PATHDEST_FICLOG=$3
	if [ ! -e "$CHEMINDST" ]
	then
		printMessageTo "\033[31m[ERROR][DIRECTORY]\033[0m  $CHEMINNOM : KO"  "2" 	 
		if [ $# -eq 3 ]
		then
			printMessageTo "$CHEMINNOM : CREATION"  "2" "2" "$PATHDEST_FICLOG"			
		else
			printMessageTo "$CHEMINNOM : CREATION"  "2" 	
		fi
		mkdir "$CHEMINDST"
		chmod -R 755 "$CHEMINDST"		
		if [ $# -eq 3 ]
		then
			printMessageTo "\033[32m[DIRECTORY][OK]\033[0m $CHEMINNOM : OK"   "2" "2" "$PATHDEST_FICLOG"
		else
			printMessageTo "\033[32m[DIRECTORY][OK]\033[0m $CHEMINNOM : OK"   "2" 	
		fi
		return 0
	else	
		if [ $# -eq 3 ]
		then
			printMessageTo "\033[32m[DIRECTORY][OK]\033[0m $CHEMINNOM : OK"   "2" "2" "$PATHDEST_FICLOG"
		else
			printMessageTo "\033[32m[DIRECTORY][OK]\033[0m $CHEMINNOM : OK"  "2"	
		fi
		return 1
	fi
}

# fonction test du fichier 
# checkPathFile [chemin de destination] [nom du fichier]
checkPathFile(){
	CHEMINDST=$1
	CHEMINNOM=$2
	PATHDEST_FICLOG=$3
	if [ ! -f "$CHEMINDST" ]
	then		
		if [ $# -eq 3 ]
		then
			printMessageTo "\033[31m[ERROR][FILE]\033[0m $CHEMINNOM : KO : $CHEMINDST" "2" "2" "$PATHDEST_FICLOG"
		else
			printMessageTo "\033[31m[ERROR][FILE]\033[0m $CHEMINNOM : KO : $CHEMINDST" "2" 	
		fi
		return 0
	else
		chmod -R 755 "$CHEMINDST"
	    TAILLE=`du -hs "$CHEMINDST"`
		if [ $# -eq 3 ]
		then
			printMessageTo "\033[32m[FILE][OK]\033[0m $CHEMINNOM : OK -> $TAILLE" "2" "2" "$PATHDEST_FICLOG"
		else
			printMessageTo "\033[32m[FILE][OK]\033[0m $CHEMINNOM : OK -> $TAILLE" "2" 	
		fi
		return 1
	fi
}


# fonction test du fichier --> checkPathFile [chemin et nom de fichier source] [chemin de destination] [nom du fichier]
#checkPathBackupFile [CHEMINSRC] [CHEMINDST] [CHEMINNOM]
checkPathBackupFile(){
	# chemin et nom de fichier
	CHEMINSRC=$1
	# chemin du dossier de destination
	CHEMINDST=$2
	# nom du chemin
	CHEMINNOM=$3
	# nom du fichier
	FILENAME=$(basename $1)
	# SI dossier de destination n est pas existant
	if [ ! -e "$CHEMINDST" ]
	then		
		printMessageTo "[ERROR][FILE] $CHEMINNOM : KO : $CHEMINDST"	 "2" "2" "$PATHDEST_FICLOG"	
	else
		# si le dossier existe
		CHEMINFICBACKUP="$CHEMINDST/$FILENAME.backup"
		# on modifie les droits du dossier
		if [ ! -f "$CHEMINFICBACKUP" ]
			then
			# Copie du fichier 
			cp "$CHEMINSRC" "$CHEMINFICBACKUP"						
			TAILLE=`du -hs $CHEMINFICBACKUP`
			printMessageTo "Copie du $CHEMINNOM : OK -> $TAILLE" "2" "2" "$PATHDEST_FICLOG"	
		else
			printMessageTo "Fichier de backup existe deja"	 "2" "2" "$PATHDEST_FICLOG"
		fi
	fi
}

# Test si une application est installé
# checkAppli $APPLICATION
checkAppli(){
	if [ "$1" ]
	then
		command -v $1 >/dev/null 2>&1
		if [ $? -eq 0 ]; then
			printMessageTo "\033[32m[CTRL-APPLI]\033[0m $1 : \033[32mOK\033[0m" "2"
			return 1
		else			
			printMessageTo "\033[31m[ERREUR]\033[0m $1 : \033[31mKO\033[0m" "2"
			return 0
			exit 1
		fi
	fi	
}

# Test de la présence des droits root
# checkUserRoot
checkUserRoot(){
	# Vérifier que l'utilisateur est root
	if [[ $EUID -ne 0 ]]; then
	   echo -e "\033[31m[ERREUR]\033[0m Ce script doit être lancé en root"	   
	   exit 1
	else	
	   echo -e "\033[32m[CTRL-DROIT]\033[0m USER : ROOT : \033[32mOK\033[0m"
	fi
}
# Test de user connecté
# checkUser $login
checkUser(){
	# Vérifier que l'utilisateur connecté est le même que le parametre en entrée
	if [[ `id -un` != $1 ]]; then
	   echo -e "\033[31m[ERREUR]\033[0m Ce script doit être lancé avec l'utilisateur \033[31m $1 \033[0m"	   
	   exit 1
	else	
	   echo -e "\033[32m[CTRL-DROIT]\033[0m USER : $1 : \033[32mOK\033[0m"
	fi
}
###################################################################################################################
#
# GESTION DOSSIER FICHIER
#
###################################################################################################################
# Fonction statistique du fichier
# statFile [FILESRC] [PATHDEST_FICLOG] [SEPARATEUR]
getStatFile(){
	FILESRC=$1
	PATHDEST_FICLOG=$2
	FILENAME=$(basename $1)
	if [ $3 ]
		then
			SEPARATEUR="$3"
		else
			#defaut tabulation
			SEPARATEUR="\t"
	fi
	
	#taille du fichier
	fic_TAILLE=`du -hs "$FILESRC"`
	#Nombre de ligne total
	fic_NB_TOTAL_LIGNE=`awk 'END {print NR }' "$FILESRC" `	
	#Affiche le Nombre champs
	fic_NB_TOTAL_COL=`awk '{cnt=0 ; for(i=1; i<=NF; i++) {if($i != "") {cnt++}} {if (cnt > 2 && NR == 1) {print cnt}} }' FS=$SEPARATEUR "$FILESRC"`
	
	#[CONSOLE] Ecriture dans fichier de log
	printMessageTo "---------------------------------------------------------------" "2" "2" "$PATHDEST_FICLOG"
	printMessageTo "   STATISTIQUE FICHIER		" "2" "2" "$PATHDEST_FICLOG"
	printMessageTo "---------------------------------------------------------------" "2" "2" "$PATHDEST_FICLOG"	
	printMessageTo "Nom du fichier : $FILENAME"  "2" "2" "$PATHDEST_FICLOG"
	printMessageTo "Chemin du fichier : $FILESRC" "2" "2" "$PATHDEST_FICLOG"
	printMessageTo "Taille du fichier : $fic_TAILLE" "2" "2" "$PATHDEST_FICLOG"
	printMessageTo "Total ligne : $fic_NB_TOTAL_LIGNE" "2" "2" "$PATHDEST_FICLOG"
	printMessageTo "Nb de colonne : $fic_NB_TOTAL_COL" "2" "2" "$PATHDEST_FICLOG"
	printMessageTo "SEPARATEUR:----->$SEPARATEUR<-------"		
}
# fonction suppression de fichier s'il est présent seulement
# deleteFile [chemin de destination] [nom du fichier]
deleteFile(){
	CHEMINDST="$1"
	CHEMINNOM="$2"
	FILENAME=$(basename $1)
	if [ ! -f "$CHEMINDST" ]
	then		
		printMessageTo "[INFO][FILE] $FILENAME : Fichier inexistant" "2" "2" "$PATHDEST_FICLOG"		
	else
		rm "$CHEMINDST"	    
		printMessageTo "[DELETE][FILE] $CHEMINDST : SUPPRESSION $CHEMINNOM" "2" "2" "$PATHDEST_FICLOG"	
	fi
}
# deleteFile [chemin de destination] [nom du fichier]
deleteFiles(){
	CHEMINDST="$1"
	CHEMINNOM="$2"
	# Creation d un boucle ls pour traiter tous les fichiers
		cnt=1
		printMessageTo "[INFO][PATH] $CHEMINDST" "2" "2" "$PATHDEST_FICLOG"
		ls $CHEMINDST | while read i
		do
			FILENAME=$(basename $i)
			if [ ! -f "$CHEMINDST/$i" ]
			then		
				printMessageTo "[INFO][FILE] $FILENAME : Fichier inexistant" "2" "2" "$PATHDEST_FICLOG"		
			else
				rm "$CHEMINDST/$i"	    
				printMessageTo "[DELETE][FILE] $CHEMINDST/$i : SUPPRESSION $CHEMINNOM" "2" "2" "$PATHDEST_FICLOG"	
			fi
			cnt=$(($cnt+1))
		done
}


# Fonction Commpression de Dossier  --> compressFolder [dossier source] [dossier compresse]
compressFolder(){
	FILEDST=$1
	FILESRC=$2
	
	check2ParamOk $FILESRC  $FILEDST 
	#compression du dossier
	cd "$FILESRC"
	tar -cf "$PATHDEST/$FILEDST" *
	cd "$PATHSRC"
	checkPathFile "$PATHDEST/$DOSDST$FILEDST"  "$FILEDST"

}

# fonction decompression du fichier zip
# unzipFile [chemin et nom du fichier zip] [Chemin de destination] [Chemin d origine]
unzipFile(){
	CHEMINSRC=$1
	CHEMINDST=$2
	PATHROOT=$3
	FILENAME=$(basename $1)
	if [ ! -f "$CHEMINSRC" ]
	then		
		printMessageTo "[INFO][ZIPFILE] $FILENAME : Fichier inexistant"	 "2" "2" "$PATHDEST_FICLOG"	
	else
		cd $CHEMINDST		
		unzip -o "$CHEMINSRC"   
		cd $PATHROOT
		printMessageTo "[INFO][ZIPFILE] $CHEMINSRC : DECOMPRESSEE DANS $CHEMINDST" "2" "2" "$PATHDEST_FICLOG"	
		deleteFile $CHEMINSRC "Fichier Archive $FILENAME"
	fi
}


# fonction test du fichier avant deplacement
#moveFile [CHEMINSRC] [CHEMINDST] [CHEMINNOM]
moveFile(){
	# chemin et nom de fichier
	CHEMINSRC=$1
	# chemin du dossier de destination
	CHEMINDST=$2
	# nom du chemin
	CHEMINNOM=$3
	# nom du fichier
	FILENAME=$(basename $1)
	# chemin et nom du fichier de destination
	CHEMINFICBACKUP="$CHEMINDST/$FILENAME"
	if [ ! -e "$CHEMINDST" ]
	then		
		printMessageTo "[ERROR][PATH] $CHEMINNOM : KO : $CHEMINDST" "2" "2" "$PATHDEST_FICLOG"		
	else
		printMessageTo "[OK][PATH] $CHEMINDST" "2" "2" "$PATHDEST_FICLOG"	
		if [ -f "$CHEMINSRC" ]
			then
			# deplacement du fichier 
			mv "$CHEMINSRC" "$CHEMINDST"
			TAILLE=`du -hs $CHEMINFICBACKUP`
			printMessageTo "[OK][FILE] Deplacement du $CHEMINNOM : OK -> $TAILLE" "2" "2" "$PATHDEST_FICLOG"	
		else
			printMessageTo "[ERROR][FIILE] Le fichier source n existe pas" "2" "2" "$PATHDEST_FICLOG"	
		fi
	fi
}
###################################################################################################################
#
# GESTION SQL FICHIER
#
###################################################################################################################
# createSQLextractCols [FILESRC] [PAHTDESTLOG] [PATHSRCFICFT] [TABLENAME]
createSQLextractCols(){
	FILESRC=$1
	PAHTDESTLOG=$2
	FILENAME=$(basename $1)
	FILENAMESSEXT=$(basename $1 | cut -f1 -d '.' )
	# Chemin du dossier FORMATTE
	PATHSRCFICFT=$3
	# Chemin et Nom du fichier de destination formatte
	FILEDST="$PATHSRCFICFT/$FILENAMESSEXT.extractCols.sql"
	TABLENAME=$4
	echo "$DATELOG ---------------------------" #>> "$PAHTDESTLOG"
	echo "$DATELOG   CREATION SQL EXTRACTION DU NOM DES COLONNES A IMPORTER	  " #>> "$PAHTDESTLOG"
	echo "$DATELOG ---------------------------" #>> "$PAHTDESTLOG"
	
	echo "SET SERVEROUTPUT ON;"																				> $FILEDST
	echo "EXEC DBMS_OUTPUT.PUT_LINE(' -- ---------   EXTRACT NOM DE COLONNE A IMPORTER   ----------- ');" 	>> $FILEDST
	echo "SELECT CONCAT(NVL(PKG_PROMOPERF_SPEC.FV_GET_COLNAME_RETAIL(COLUMN_NAME),''),',')"					>> $FILEDST
	echo "FROM user_tab_cols"																				>> $FILEDST
	echo "INNER JOIN PP_MAPPING_COL_TAB"																	>> $FILEDST
	echo "	ON user_tab_cols.COLUMN_NAME=PP_MAPPING_COL_TAB.MAPC_NIELSEN"									>> $FILEDST
	echo "WHERE TABLE_NAME='"$TABLENAME"';"																	>> $FILEDST
	echo "/"																								>> $FILEDST
	echo "quit;"																							>> $FILEDST
	
	check_RESULT=`checkPathFile "$FILEDST"  "$FILENAMESSEXT.extractCols.sql"`
	echo $check_RESULT
	echo "$DATELOG - $check_RESULT" >> "$PAHTDESTLOG"		
}
# createSQLcreateTable [FILESRC] [PAHTDESTLOG] [PATHSRCFICFT] [PATHSRCAWK] [TABLENAME]
createSQLcreateTable(){
	FILESRC="$1"
	PAHTDESTLOG=$2
	FILENAME=$(basename "$1")
	FILENAMESSEXT=$(basename "$1" | cut -f1 -d '.' )
	# Chemin du dossier FORMATTE
	PATHSRCFICFT=$3
	# Chemin et Nom du fichier de destination formatte
	FILEDST="$PATHSRCFICFT/$FILENAMESSEXT"
	PATHSRCAWK=$4
	TABLENAME=$5
	
	#defaut tabulation
	SEPARATEUR="\t"
	#taille du fichier
	fic_TAILLE=`du -hs "$FILESRC"`
	#Nombre de ligne total
	fic_NB_TOTAL_LIGNE=`awk 'END {print NR }' "$FILESRC" `	
	#Affiche le Nombre champs
	fic_NB_TOTAL_COL=`awk '{cnt=0 ; for(i=1; i<=NF; i++) {if($i != "") {cnt++}} {if (cnt > 2 && NR == 1) {print cnt}} }' FS=$SEPARATEUR "$FILESRC"`
	
	#Generation à partir des entetes de colonne du fichier sql create table
	gawk -v newNB_TOTAL_COL=$fic_NB_TOTAL_COL -v newFILENAME=$FILENAMESSEXT -v newTABLENAME=$TABLENAME -v newDATE="$(date '+%d/%m/%Y %H:%M:%S')" -f $PATHSRCAWK/createSQLcreateTable.awk "$FILESRC" > $FILEDST.sql
	check_RESULT=`checkPathFile "$FILEDST.sql"  "$FILENAMESSEXT.sql"`
	echo $check_RESULT
	echo "$DATELOG - $check_RESULT" >> "$PAHTDESTLOG"		
}

# createSQLloadData [FILESRCENTETE] [PAHTDESTLOG] [PATHSRCFICFT] [PATHSRCAWK] [FILESRCDATA] [TABLENAME]
createSQLloadData(){
	FILESRC=$1	
	PAHTDESTLOG=$2
	FILENAME=$(basename $1)
	FILENAMESSEXT=$(basename $1 | cut -f1 -d '.' )
	# Chemin du dossier FORMATTE
	PATHSRCFICFT=$3
	# Chemin et Nom du fichier de destination formatte
	FILEDST="$PATHSRCFICFT/$FILENAMESSEXT"
	PATHSRCAWK=$4
	FILESRCDATA=$5
	TABLENAME=$6
	
	#defaut tabulation
	SEPARATEUR="\t"
	#taille du fichier
	fic_TAILLE=`du -hs "$FILESRC"`
	#Nombre de ligne total
	fic_NB_TOTAL_LIGNE=`awk 'END {print NR }' "$FILESRC" `	
	#Affiche le Nombre champs
	fic_NB_TOTAL_COL=`awk '{cnt=0 ; for(i=1; i<=NF; i++) {if($i != "") {cnt++}} {if (cnt > 2 && NR == 1) {print cnt}} }' FS=$SEPARATEUR "$FILESRC"`
	echo " -> CHEMIN DES DATA :  $FILESRC.data"
	echo " -> CHEMIN DU FICHIER DE CONTROLE :  $FILEDST.load.ctl"
	#Generation à partir des entetes de colonne du fichier sql create table
	gawk -v newNB_TOTAL_COL=$fic_NB_TOTAL_COL -v newTABLENAME=$TABLENAME -v newPATHFILENAME=$FILESRCDATA -f $PATHSRCAWK/createSQLloadData.awk "$FILESRC" > $FILEDST.load.ctl
	check_RESULT=`checkPathFile "$FILEDST.load.ctl"  "$FILENAMESSEXT.load.ctl"`
	echo $check_RESULT
	echo "$DATELOG - $check_RESULT" >> "$PAHTDESTLOG"		
}

#fonction de creation de fichier sql avec template et remplacement de variable
# createSqlFile [VARSRC] [VARDST] [FILESQLNAMESRC] [FILESQLNAMEDST] [FILESQLPATHSRC] [FILESQLPATHDST] 
createSqlFile(){
	#variable source a modifier
	VARSRC="$1"	
	#valeur de remplacement 
	VARDST="$2"
	#nom du fichier de destination
	FILESQLNAMESRC="$3"
	#nom du fichier de destination
	FILESQLNAMEDST="$4"
	#chemin du fichier source
	FILESQLPATHSRC="$5"
	#chemin du fichier de destination
	if [ $6 ]; then
			FILESQLPATHDST="$6"
		else
			FILESQLPATHDST="$FILESQLPATHSRC"
		fi
	# Execution de la substitution
	sed "s/$VARSRC/$VARDST/g" "${FILESQLPATHSRC}/template/$FILESQLNAMESRC" > "${FILESQLPATHDST}/$FILESQLNAMEDST"
	# test du resultat de la fusion
	checkPathFile "${FILESQLPATHDST}/$FILESQLNAMEDST"  "$FILESQLNAMEDST"
}

#fonction de creation de fichier sql avec template et remplacement de variable dans le dossier template
# createSqlFileInDir [PAHTDESTLOG] [FILESQLPATHSRC] [FILESQLPATHDST] 
createSqlFileInDir(){
	#chemin des logs
	PATHDESTLOG="$1"
	#chemin du fichier source
	FILESQLPATHSRC="$2"
	#chemin du fichier de destination
	if [ $3 ]; then
			FILESQLPATHDST="$3"
		else
			FILESQLPATHDST="$FILESQLPATHSRC"
		fi
		
	# Creation d un boucle ls pour traiter tous les fichiers
	cnt=1
	printMessageTo "[INFO][PATH] $FILESQLPATHSRC" "2"
	ls "$FILESQLPATHSRC" | while read i
	do
		FILENAME=$(basename $i)
		if [ ! -f "$FILESQLPATHSRC/$i" ]
		then		
			printMessageTo "[INFO][FILE] $FILENAME : Fichier inexistant" "2"	
		else
			# Execution de la substitution des separateurs, et nom de schema dans le fichier template et creation des fichiers sql a executer
			sed "s/\${VAL_SEPARATEUR}/$VAL_SEPARATEUR/g" "${FILESQLPATHSRC}/$FILENAME" |  sed "s/\${VAL_SCHEMA}/$VAL_SCHEMA/g" | sed "s/\${VAL_SCHEMA_USER}/$VAL_SCHEMA_USER/g"  > "${FILESQLPATHDST}/${FILENAME}fusion.sql"
			# test du resultat de la fusion
			checkPathFile "${FILESQLPATHDST}/${FILENAME}fusion.sql"  "${FILENAME}fusion.sql"			
		fi
		cnt=$(($cnt+1))
	done
	
}
###################################################################################################################
#
# GESTION BDD ORACLE
#
###################################################################################################################
# fonction requete oracle 
#--> execReqOracle [Nom du fichier sql a executer] [Nom du fichier d export]
# execReqOracle $SQLFILEIN $FILEOUT1
execReqOracle(){
	SQLFILEIN=$1
	FILEOUT1=$2
	
	check2ParamOk $SQLFILEIN $FILEOUT1	
	# $bdd_login/$bdd_motdepass@$bdd_host:$bdd_port/$bdd_name
	sqlplus -s $bdd_login/$bdd_motdepass@$bdd_host:$bdd_port/$bdd_name	@$SQLFILEIN >> $FILEOUT1	;
	retval=$?
	checkPathFile "$FILEOUT1"  "$FILEOUT1"
	return $retval
}
 
# fonction loader oracle 
#--> execLoadOracle [Nom du fichier sql a executer] [Nom du fichier d export]
execLoadOracle(){
	SQLFILEIN=$1
	FILEOUT1=$2
	# on recupere le nom du fichier avec extension
	FILENAME=$(basename $1)
	# on recupere le nom du fichier sans extension
	FILENAMESSEXT=$(basename $1 | cut -f1 -d '.' )
	# on recupere le chemin du fichier en parametre SQLFILEIN
	FILEPATH=$(dirname $1)
	# on cree le chemin et le debut du nom de fichier de log
	FILELOGOUT=$FILEPATH/$FILENAMESSEXT	
	# Fichier de log general
	FILELOGOUT_GEN="$FILEPATH/$FILENAMESSEXT.load-log.log"
	#Fichier des mauvais enregistrements
	FILELOGOUT_BAD="$FILEPATH/$FILENAMESSEXT.load-bad.log"
	#Fichier des enregistrements ecartes
	FILELOGOUT_DIS="$FILEPATH/$FILENAMESSEXT.load-discard.log"
	#Nettoyage fichier de log
	deleteFile $FILELOGOUT_GEN
	deleteFile $FILELOGOUT_BAD
	deleteFile $FILELOGOUT_DIS
	checkPathFile "$FILEOUT1"  "$FILEOUT1"
	checkPathFile "$SQLFILEIN"  "Fichier de controle"
	check2ParamOk $SQLFILEIN $FILEOUT1	
	sqlldr $bdd_login/$bdd_motdepass@$bdd_host:$bdd_port/$bdd_name control=$SQLFILEIN log=$FILELOGOUT_GEN bad=$FILELOGOUT_BAD skip=0 discard=$FILELOGOUT_DIS direct=y errors=10000 >> $FILEOUT1	;
	checkPathFile "$FILEOUT1"  "$FILEOUT1"
	checkPathFile "$SQLFILEIN"  "Fichier de controle"
	checkPathFile "$FILELOGOUT_GEN"  "Fichier de log general"
	checkPathFile "$FILELOGOUT_BAD"  "Fichier des mauvais enregistrements"
	checkPathFile "$FILELOGOUT_DIS"  "Fichier des enregistrements ecartes"
}

# execReqParamOracle $SQLQUERY $FILEOUT $MESSAGE
execReqParamOracle(){
	SQLQUERY="$1"
	FILEOUT="$2"
	if [ "$3" ]
	then
		echo "---------------------------------------------------------------"
		echo "$3"
		echo "---------------------------------------------------------------"
	fi
	if [ "$1" ]
	then
		printMessageTo "parameter 1 : $1" "2" "2" "$PATHDEST_FICLOG"
	fi
	if [ "$2" ]
	then
		printMessageTo "parameter 2 : $2" "2" "2" "$PATHDEST_FICLOG"
	fi
	check2ParamOk $SQLQUERY $FILEOUT	
	ACTIONSQL=`sqlplus $bdd_login/$bdd_motdepass@$bdd_host:$bdd_port/$bdd_name << EOF
	whenever sqlerror exit failure
	$SQLQUERY
	EOF >> $FILEOUT	`
	retval=$?
	checkPathFile "$FILEOUT" "$FILEOUT"
	return $retval
}

###################################################################################################################
#
# GESTION BDD MYSQL
#
###################################################################################################################

#fonction de creation d'un tunnel SSH pour mysql
pr_mysql_ssh(){
	ssh -l "$ssh_my_login" "$ssh_my_host" -p "$ssh_my_port" -i "$ssh_my_key" -N -f -C -L "$ssh_my_from_port":"$ssh_my_host_bdd":"$ssh_my_dest_port"
}

#fonction d'initialisation des parametres de connexion mysql
pr_mysql_login(){
	mysql_config_editor set --login-path="$bdd_my_login_path" --host="$bdd_my_host" --port="$bdd_my_port" --user="$bdd_my_login" --password
}

#fonction d'initialisation des parametres de connexion mysql
execDumpMysql(){
		#fichier de la liste des schemas bdd 		
		checkPathFile "${PATHFICSCHEMASQL}"  "FICHIER LISTE DES SCHEMAS BDD"
		if [ $? = 1 ]; then
			NB_TOTAL_SCHEMA=`awk 'END {print NR }' "${PATHFICSCHEMASQL}" `	
			if [ $NB_TOTAL_SCHEMA -gt 0 ]; then		
					printMessageTo "[INFO][SCHEMA] $NB_TOTAL_SCHEMA Schemas à traiter"	"1"
					#printMessageTo "${PATHFICSCHEMASQL}"   "2" 
					chkLigne=0
					while read ligne
					do  
							chkLigne=1
						   	printMessageTo "[INFO][SCHEMA] TRAITEMENT $ligne "  "2" 
						   	#chemin de destination du dump
							PATH_FILE_DMP=${PATHSRCSQL_DDLSTR}/${ligne}.dmp
							checkPathDst "${PATHSRCSQL_DDLSTR}" "${PATHSRCSQL_DDLSTR}"
						    mysqldump --login-path=$bdd_my_login_path -d -u  $bdd_my_login  $ligne > $PATH_FILE_DMP					    
						    if [ $? = 2 ]; then
						    	printMessageTo "[ERROR][MYSQL]  ci dessus" "2"
						    fi 
							checkPathFile "$PATH_FILE_DMP"  "$PATH_FILE_DMP"											
					done < "${PATHFICSCHEMASQL}"	
					#test du retour chariot dans le fichier
				   	if [ $chkLigne -eq 0 ]; then
						printMessageTo "[ERROR][SCHEMA] Impossible de lire le nom du schema : vérifier le retour chariot en fin de ligne dans le fichier ${PATHFICSCHEMASQL}  ! "	  "2" 
					else
						printMessageTo "[INFO][SCHEMA] FIN DE TRAITEMENT  "  "2" 
						return 1				
					fi
			else
				printMessageTo "[ERROR][SCHEMA] Pas de Schema à traiter"  "2" 
				return 0	
			fi	
		else
			#printMessageTo "[ERROR][SCHEMA] FICHIER DE LISTE DE SCHEMA INTROUVABLE : vérifier le ${PATHFICSCHEMASQL}"
			return 0	
		fi
}
# fonction requete mysql --> execReqMysql [Nom du fichier sql a executer] [Nom du fichier d export] [H :format html, SC : sans entete]
execReqMysql(){
	SQLFILEIN=$1
	FILEOUT=$2
	if [ ! -r "$SQLFILEIN" ]
	then		
		printMessageTo "[ERROR][FILE] $SQLFILEIN : KO " "2"
		return 1
	fi
	if [ $4 ]; then
		if [ $4 = "NODB"  ]
		then
			BDDCHOICE=""
		else
			BDDCHOICE="$4"
		fi
	else		
		BDDCHOICE="$bdd_my_name"
	fi
	if [ $3 ]; then
		if [ $3 = "H"  ]
		then
			#printMessageTo "html" "2"
			TYPEFILEOUT="--html"
		elif [ $3 = "SC"  ]
		then
			#printMessageTo "sans colonne"  "2" 
			TYPEFILEOUT="--skip-column-names"
		fi
	else
		#printMessageTo "no-html" "2"
		TYPEFILEOUT=""
	fi
	check2ParamOk "$SQLFILEIN" "$FILEOUT"	
	printMessageTo "COMMANDE : mysql $TYPEFILEOUT -h $bdd_my_host --port=$bdd_my_port -u $bdd_my_login -p$bdd_my_motdepass  $BDDCHOICE < $SQLFILEIN  >> $FILEOUT ;  " "2"	
	mysql --login-path=$bdd_my_login_path $TYPEFILEOUT -u $bdd_my_login --default-character-set=utf8 $BDDCHOICE < "$SQLFILEIN"  >> "$FILEOUT" 2>&1;  
	#checkPathFile "$FILEOUT"  "$FILEOUT"
	return $?
}

# fonction requete mysql --> execReqParamMysql [requete sql a executer] [Nom du fichier d export] 
execReqParamMysql(){	
	SQLQUERY="$1"
	FILEOUT="$2"
	if [ $4 ]; then
		if [ $4 = "NODB"  ]
		then
			BDDCHOICE=""
		else
			BDDCHOICE="$4"
		fi
	else		
		BDDCHOICE="$bdd_my_name"
	fi
	if [ $3 ]; then
		if [ $3 = "H"  ]
		then
			#printMessageTo "html" "2"
			TYPEFILEOUT="--html"
		elif [ $3 = "SC"  ]
		then
			#printMessageTo "sans colonne" "2"
			TYPEFILEOUT="--skip-column-names"
		fi
	else
		#printMessageTo "no-html" "2"
		TYPEFILEOUT=""
	fi
	if [ "$1" ]
	then
		printMessageTo "parameter 1 : $1" "2"
	fi
	if [ "$2" ]
	then
		printMessageTo "parameter 2 : $2" "2"
	fi
	
	check2ParamOk "$SQLQUERY" "$FILEOUT"		
	mysql --login-path=$bdd_my_login_path $TYPEFILEOUT -u $bdd_my_login --database=$BDDCHOICE -e  "$SQLQUERY" ;
	# checkPathFile "$FILEOUT"  "$FILEOUT"
	return $?
}


