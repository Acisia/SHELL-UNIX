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
			MESSAGE="\033[33m------------------------------------------------------------------------\n\t\t$MESSAGE\n------------------------------------------------------------------------\033[0m"
		# TEST 2=mise en avant
		elif [ $FORMATTAGE -eq 2 ]; then
			MESSAGE="\t\t\033[33m|\033[0m\n\t\t\033[33m|--\033[0m $MESSAGE\n\t\t\033[33m|\033[0m"
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
		printMessageTo "[ENV][INFO] Environnement de travail : $ENVSET"  "2" "2" "$PATHDEST_FICLOG"
		printMessageTo "[ENV][ERROR] Pas d environnement défini en parametre "  "2" "2" "$PATHDEST_FICLOG"
		printMessageTo "[ENV][INFO]      INT (pour l'integration)"	 "2" "2" "$PATHDEST_FICLOG"
		printMessageTo "[ENV][INFO]      REC (pour la recette)"	 "2" "2" "$PATHDEST_FICLOG"
		printMessageTo "[ENV][INFO]      PROD (pour la production)"	 "2" "2" "$PATHDEST_FICLOG"
		exit 1
	fi
	#test de l environnement
	if [ $ENVSET = "INT" ]; then
		#INTEGRATION : 1
		printMessageTo "[ENV][INFO] PARAMETRE : $ENVSET"  "2" "2" "$PATHDEST_FICLOG"
		return 1
		exit 1
	elif [ $ENVSET = "REC" ]; then
		#RECETTE : 2
		printMessageTo "[ENV][INFO] PARAMETRE : $ENVSET"  "2" "2" "$PATHDEST_FICLOG"
		return 2
		exit 1
	elif [ $ENVSET = "PROD" ]; then
		#PRODUCTION : 3
		printMessageTo "[ENV][INFO] PARAMETRE : $ENVSET"  "2" "2" "$PATHDEST_FICLOG"
		return 3
		exit 1
	else 
		printMessageTo "[ENV][ERROR] Parametre invalide : INT ou REC ou PROD"  "2" "2" "$PATHDEST_FICLOG"
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
	if [ ! -e "$CHEMINDST" ]
	then
		printMessageTo "[ERROR][DIRECTORY] $CHEMINNOM : KO"  "2" 
		printMessageTo "$CHEMINNOM : CREATION"  "2" 
		mkdir "$CHEMINDST"
		chmod -R 755 "$CHEMINDST"
		printMessageTo "$CHEMINNOM : OK"  "2" 
	else
		printMessageTo "$CHEMINNOM : OK" "2" 
	fi
}

# fonction test du fichier 
# checkPathFile [chemin de destination] [nom du fichier]
checkPathFile(){
	CHEMINDST=$1
	CHEMINNOM=$2
	if [ ! -f "$CHEMINDST" ]
	then		
		printMessageTo "[ERROR][FILE] $CHEMINNOM : KO : $CHEMINDST"	 "2" "2" "$PATHDEST_FICLOG"	
	else
		chmod -R 755 "$CHEMINDST"
	    TAILLE=`du -hs $CHEMINDST`
		printMessageTo "$CHEMINNOM : OK -> $TAILLE" "2" "2" "$PATHDEST_FICLOG"
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
			echo -e "\033[32m[CTRL-APPLI]\033[0m $1 : \033[32mOK\033[0m"
		else			
			echo -e "\033[31m[ERREUR]\033[0m $1 : \033[31mKO\033[0m"
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
# fonction requete mysql --> execReqMysql [Nom du fichier sql a executer] [Nom du fichier d export] [H :format html, SC : sans entete]
execReqMysql(){
	SQLFILEIN=$1
	FILEOUT=$2
	
	if [ $3 ]
	then
		if [ $3 = "H"  ]
		then
			#printMessageTo "html" "2" "2" "$PATHDEST_FICLOG"
			TYPEFILEOUT="--html"
		elif [ $3 = "SCN"  ]
		then
			#printMessageTo "sans colonne" "2" "2" "$PATHDEST_FICLOG"
			TYPEFILEOUT="--skip-column-names"
		fi
	else
		#printMessageTo "no-html" "2" "2" "$PATHDEST_FICLOG"
		TYPEFILEOUT=""
	fi
	check2ParamOk $SQLFILEIN $FILEOUT
	mysql $TYPEFILEOUT -u $bdd_login -p$bdd_motdepass  $bdd_name < $SQLFILEIN  >> $FILEOUT ; 
	checkPathFile "$FILEOUT"  "$FILEOUT"
}

#mysql -u  %MySqlUser% --password=%MySqlPwd% --default-character-set latin1 --host=%MySqlHost% mytest -e "drop table if exists temp_tdb_occ_occurence"
# fonction requete mysql --> execReqMysql [Nom du fichier sql a executer] [Nom du fichier d export] [H :format html, SC : sans entete]
execReqParamMysql(){	
	SQLQUERY="$1"
	FILEOUT="$2"
	if [ "$3" ]
	then
		echo  "---------------------------------------------------------------"
		echo  "$3"
		echo  "---------------------------------------------------------------"
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
	mysql -u $bdd_login -p$bdd_motdepass  --skip-column-names --host=$bdd_host $bdd_name -e  "$SQLQUERY"  >> "$FILEOUT" ; 
	checkPathFile "$FILEOUT"  "$FILEOUT"
}

# fonction export bdd mysql --> exportBddMysql [Nom de base de donnees] [Nom du fichier d export]
exportBddMysql(){
	DATABASESRCNOM=$1
	DATABASEFILENOM=$2
	
	check2ParamOk $DATABASESRCNOM  $DATABASEFILENOM 
	mysqldump --host=$bdd_host --user=$bdd_login --password=$bdd_motdepass --default-character-set=latin1 $DATABASESRCNOM > $PATHDESTBDD/$DATABASEFILENOM
	checkPathFile "$PATHDESTBDD/$DATABASEFILENOM"  "$DATABASEFILENOM"
}
