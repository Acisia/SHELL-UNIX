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
# printMessageToUser $MESSAGE
printMessageToUser(){
MESSAGE=$1
echo "$MESSAGE"
}
# printFormatMessageToUser $MESSAGE
printFormatMessageToUser(){
MESSAGE=$1
echo " |"
echo " |---> $MESSAGE"
echo " |"
}
#printMessageToLog $MESSAGE
printMessageToLog(){
MESSAGE=$1
echo "$MESSAGE"				>> "$PAHTDESTLOG"
}
# printFormatMessageToLog $MESSAGE
printFormatMessageToLog(){
MESSAGE=$1
echo " |"					>> "$PAHTDESTLOG"
echo " |---> $MESSAGE"		>> "$PAHTDESTLOG"
echo " |"					>> "$PAHTDESTLOG"
}
#printMessageToLogAndUser $MESSAGE
printMessageToLogAndUser(){
MESSAGE=$1
echo "$MESSAGE"
echo "$MESSAGE"				>> "$PAHTDESTLOG"
}
# printFormatMessageToLogAndUser $MESSAGE
printFormatMessageToLogAndUser(){
MESSAGE=$1
echo " |"
echo " |---> $MESSAGE"
echo " |"
echo " |"					>> "$PAHTDESTLOG"
echo " |---> $MESSAGE"		>> "$PAHTDESTLOG"
echo " |"					>> "$PAHTDESTLOG"
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
	PAHTDESTLOG=$2
	EXTENSION=$3
	SILENCEMODE=$4
	if [ ! -e "$CHEMINDOSSIER" ]
	then
		if [ ! "$SILENCEMODE" ]
			then
			printmessageToUser "[ERROR][DIRECTORY] $CHEMINDOSSIER : KO"
			printmessageToUser "[ERROR][DIRECTORY] $CHEMINDOSSIER : KO" >>  "$PAHTDESTLOG"
		else	
			echo 0
		fi		
	elif [ "$EXTENSION" ]
		then
		NB_FILE=`ls -A1 $CHEMINDOSSIER | grep $EXTENSION | wc -l`
		if [ ! "$SILENCEMODE" ]
			then
			printmessageToUser "Nombre de fichier $EXTENSION : $NB_FILE"
			printmessageToUser "Nombre de fichier $EXTENSION : $NB_FILE" >>  "$PAHTDESTLOG"
		else	
			echo $NB_FILE
		fi
		
	else		
		NB_FILE=`ls -A1 $CHEMINDOSSIER | wc -l`
		if [ ! "$SILENCEMODE" ]
			then
			printmessageToUser "Nombre de fichier : $NB_FILE"
			printmessageToUser "Nombre de fichier : $NB_FILE" >>  "$PAHTDESTLOG"
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

checkVarOk(){
	#Check if variable is ok or not
	printmessageToUser "[CHECK] result parameter..."
	if [ $# -eq 3 ]
	then
	    RESULT=1
		printmessageToUser "[OK] variable is ok"
	else    
		if [ $# -eq 2 ]
		then
			printmessageToUser "[ERROR] $1 is missing because $2 is unknown"
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
		printmessageToUser "[ERROR][PARAM] $0 arguments are required "
	fi

	#check the parameters 2
	if [ $# -eq 1 ]
	then
		printmessageToUser "[ERROR][PARAM]  2 arguments are required"
	fi
}

# fonction test du chemin --> checkPathDst [chemin de destination] [nom du chemin]
checkPathDst(){
	CHEMINDST=$1
	CHEMINNOM=$2
	if [ ! -e "$CHEMINDST" ]
	then
		printmessageToUser "[ERROR][DIRECTORY] $CHEMINNOM : KO"
		printmessageToUser "$CHEMINNOM : CREATION"
		mkdir "$CHEMINDST"
		chmod -R 755 "$CHEMINDST"
		printmessageToUser "$CHEMINNOM : OK"
	else
		printmessageToUser "$CHEMINNOM : OK"	
	fi
}

# fonction test du fichier 
# checkPathFile [chemin de destination] [nom du fichier]
checkPathFile(){
	CHEMINDST=$1
	CHEMINNOM=$2
	if [ ! -f "$CHEMINDST" ]
	then		
		printmessageToUser "[ERROR][FILE] $CHEMINNOM : KO : $CHEMINDST"		
	else
		chmod -R 755 "$CHEMINDST"
	    TAILLE=`du -hs $CHEMINDST`
		printmessageToUser "$CHEMINNOM : OK -> $TAILLE"	
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
		printmessageToUser "[ERROR][FILE] $CHEMINNOM : KO : $CHEMINDST"		
	else
		# si le dossier existe
		CHEMINFICBACKUP="$CHEMINDST/$FILENAME.backup"
		# on modifie les droits du dossier
		if [ ! -f "$CHEMINFICBACKUP" ]
			then
			# Copie du fichier 
			cp "$CHEMINSRC" "$CHEMINFICBACKUP"						
			TAILLE=`du -hs $CHEMINFICBACKUP`
			printmessageToUser "Copie du $CHEMINNOM : OK -> $TAILLE"	
		else
			printmessageToUser "Fichier de backup existe deja"	
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
###################################################################################################################
#
# GESTION DOSSIER FICHIER
#
###################################################################################################################
# Fonction statistique du fichier
# statFile [FILESRC] [PAHTDESTLOG] [SEPARATEUR]
getStatFile(){
	FILESRC=$1
	PAHTDESTLOG=$2
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
	echo  "---------------------------------------------------------------"
	echo  "   STATISTIQUE FICHIER		"
	echo  "---------------------------------------------------------------"		
	printmessageToUser "Nom du fichier : $FILENAME"
	printmessageToUser "Chemin du fichier : $FILESRC"
	printmessageToUser "Taille du fichier : $fic_TAILLE"
	printmessageToUser "Total ligne : $fic_NB_TOTAL_LIGNE"	
	printmessageToUser "Nb de colonne : $fic_NB_TOTAL_COL"	
	printmessageToUser "SEPARATEUR:----->$SEPARATEUR<-------"	
	#[LOG] Ecriture dans fichier de log
	echo "$DATELOG ---------------------------" >> "$PAHTDESTLOG"
	echo "$DATELOG   STATISTIQUE FICHIER	  " >> "$PAHTDESTLOG"
	echo "$DATELOG ---------------------------" >> "$PAHTDESTLOG"
	echo "$DATELOG - Nom du fichier : $FILENAME" >> "$PAHTDESTLOG"
	echo "$DATELOG - Chemin du fichier : $FILESRC" >> "$PAHTDESTLOG"
	echo "$DATELOG - Taille du fichier : $fic_TAILLE" >> "$PAHTDESTLOG"
	echo "$DATELOG - Total ligne : $fic_NB_TOTAL_LIGNE"	 >> "$PAHTDESTLOG"
	echo "$DATELOG - Nb de colonne : $fic_NB_TOTAL_COL" >> "$PAHTDESTLOG"	
	
}
# fonction suppression de fichier s'il est présent seulement
# deleteFile [chemin de destination] [nom du fichier]
deleteFile(){
	CHEMINDST="$1"
	CHEMINNOM="$2"
	FILENAME=$(basename $1)
	if [ ! -f "$CHEMINDST" ]
	then		
		printmessageToUser "[INFO][FILE] $FILENAME : Fichier inexistant"		
	else
		rm "$CHEMINDST"	    
		printmessageToUser "[DELETE][FILE] $CHEMINDST : SUPPRESSION $CHEMINNOM"	
	fi
}
# deleteFile [chemin de destination] [nom du fichier]
deleteFiles(){
	CHEMINDST="$1"
	CHEMINNOM="$2"
	# Creation d un boucle ls pour traiter tous les fichiers
		cnt=1
		printmessageToUser "[INFO][PATH] $CHEMINDST"
		ls $CHEMINDST | while read i
		do
			FILENAME=$(basename $i)
			if [ ! -f "$CHEMINDST/$i" ]
			then		
				printmessageToUser "[INFO][FILE] $FILENAME : Fichier inexistant"		
			else
				rm "$CHEMINDST/$i"	    
				printmessageToUser "[DELETE][FILE] $CHEMINDST/$i : SUPPRESSION $CHEMINNOM"	
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
		printmessageToUser "[INFO][ZIPFILE] $FILENAME : Fichier inexistant"		
	else
		cd $CHEMINDST		
		unzip -o "$CHEMINSRC"   
		cd $PATHROOT
		printmessageToUser "[INFO][ZIPFILE] $CHEMINSRC : DECOMPRESSEE DANS $CHEMINDST"	
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
		printmessageToUser "[ERROR][PATH] $CHEMINNOM : KO : $CHEMINDST"		
	else
		printmessageToUser "[OK][PATH] $CHEMINDST"	
		if [ -f "$CHEMINSRC" ]
			then
			# deplacement du fichier 
			mv "$CHEMINSRC" "$CHEMINDST"
			TAILLE=`du -hs $CHEMINFICBACKUP`
			printmessageToUser "[OK][FILE] Deplacement du $CHEMINNOM : OK -> $TAILLE"	
		else
			printmessageToUser "[ERROR][FIILE] Le fichier source n existe pas"	
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
	
	checkPathFile "$FILEOUT1"  "$FILEOUT1"
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
		printmessageToUser "parameter 1 : $1"
	fi
	if [ "$2" ]
	then
		printmessageToUser "parameter 2 : $2"
	fi
	check2ParamOk $SQLQUERY $FILEOUT	
	ACTIONSQL=`sqlplus $bdd_login/$bdd_motdepass@$bdd_host:$bdd_port/$bdd_name << EOF
	$SQLQUERY
	EOF >> $FILEOUT	`
	checkPathFile "$FILEOUT" "$FILEOUT"
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
			#printmessageToUser "html"
			TYPEFILEOUT="--html"
		elif [ $3 = "SCN"  ]
		then
			#printmessageToUser "sans colonne"
			TYPEFILEOUT="--skip-column-names"
		fi
	else
		#printmessageToUser "no-html"
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
		printmessageToUser "parameter 1 : $1"
	fi
	if [ "$2" ]
	then
		printmessageToUser "parameter 2 : $2"
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
