#!/bin/bash
###################################################################################################################
# Author : Louis DAUBIGNARD
# Date   : 19/01/2015
#
# Description : Script pour :
#		- executer une requete oracle 
#
# Syntax : bddOracle.sh 
#
###################################################################################################################
#CHEMIN RACINE
PATHROOT="$PWD"
NOMPROJECTSCRIPT=" TEST REQUETE MYSQL"

#RECUPERATION DES FONCTIONS
. "$PATHROOT/../lib/functions.sh"
##################################################################################################################
# FONCTIONS SPECIALES
getMenu() {
	#choix du systeme
	printMessageTo  "    MENU	 " "3" 
	printMessageTo  "Faites votre choix dans la liste suivante : " "2" 
	printMessageTo  " 1 - Export	Schema Base de donnees" "21" 
	printMessageTo  " 2 - Import	Schema Base de donnees" "21" 
	printMessageTo  " h - Aide " "21" 
	printMessageTo  " q - Quitter " "21" 
	printMessageTo  "  " "21" 

}
lstFileInDir() {
	# Creation d un boucle ls pour traiter tous les fichiers
	cnt=1
	PATHDMP="$1"
	printMessageTo "[INFO][PATH] $PATHDMP" "2"
	ls "$PATHDMP" | while read i
	do
		FILENAME=$(basename $i)
		if [ ! -f "$PATHDMP/$i" ]
		then		
			printMessageTo "[INFO][FILE] $FILENAME : Fichier inexistant" "2"	
		else
			printMessageTo "	\033[35m[Fichier $cnt]\033[0m $FILENAME dans BDD ${FILENAME%%.*}" "21"			
		fi
		cnt=$(($cnt+1))
	done
}
##################################################################################################################

printMessageTo	"             $NOMPROJECTSCRIPT										" "1" 

##################################################################################################################
#TEST DE L ENVIRONNEMENT
if [ $1 ]
	then
		setEnvironment $1
	else
		setEnvironment
fi	
ret=$?
#RECUPERATION DES PROPERTIES
configEnvironment "$ret" "$PATHROOT/../config"
#CHECK DES LOGS
checkPathDst "$PATHDEST_REPLOG" "Chemin LOG"


##################################################################################################################
# TEST PRE-REQUIS
printMessageTo  "             CONTROLE APPLI										" "3" 
# Vérifier que l'utilisateur est root
# checkUserRoot
# Vérifier que perl est installé pour la gestion des mots de passe
checkAppli perl
##################################################################################################################
printMessageTo  "             EXECUTION REQUETE										" "3" 

# Question Export ou import

while true
do
	getMenu
	printMessageTo  " Que voulez-vous faire ? :"
	read reponse
	case "$reponse" in		 	
		 "1" )
		    ################################################################
			#		1 - Export	Schema Base de donnees
			################################################################
			printMessageTo  "    1 - Export	Schema Base de donnees " "3" 
			execReqParamMysql "show databases;"
			echo "Quel schema voulez-vous exporter ?"
			echo "(Tappez q pour quitter !)"
			while true
			do
				printMessageTo  " Entrer le nom du schéma a traiter:"
				read reponse
				case "$reponse" in		 	
					 "h" | "H" )
						printMessageTo  "    Liste des schemas	 " "3" 
						execReqParamMysql "show databases;"
					 ;;
					 "q" | "Q" )  
						echo "Au revoir...."
						exit 0
					 ;; 
					 * )
						printMessageTo  "    PROCESS 1: Export $reponse " "3" 
						mysqldump --login-path=$bdd_my_login_path -u  $bdd_my_login  "$reponse" > "$PATHROOT/dmp/$reponse.dmp"
						retval=$?
						if [ $retval -eq 0 ]
							then
								printMessageTo "$(date +%d/%m/%Y-%H:%M:%S) - TRAITEMENT OK" "2"
							else
								printMessageTo "$(date +%d/%m/%Y-%H:%M:%S) - TRAITEMENT KO" "2"
						fi
						checkPathFile "$PATHROOT/dmp/$reponse.dmp" "Fichier dump schema $reponse"			
					 ;; 
				esac
			done
			###############
		 ;;
		 "2" )
			################################################################
			#		2 - Import	Schema Base de donnees
			################################################################
			printMessageTo  "    2 - Import	Schema Base de donnees  " "3" 
			#show dmp
			lstFileInDir "$PATHROOT/dmp/"
			echo "Quel fichier voulez-vous importer ?"
			echo "(Tappez q pour quitter !)"
			while true
			do
				printMessageTo  " Entrer le nom du fichier a traiter:"
				read reponse
				case "$reponse" in		 	
					 "h" | "H" )
						printMessageTo  "    Liste des fichiers	 " "3" 
						lstFileInDir "$PATHROOT/dmp/"
					 ;;
					 "q" | "Q" )  
						echo "Au revoir...."
						exit 0
					 ;; 
					 * )
						printMessageTo  "    PROCESS 1: Import $reponse " "3" 
						mysql --login-path=$bdd_my_login_path -u  $bdd_my_login  "${reponse%%.*}" < "$PATHROOT/dmp/$reponse"
						retval=$?
						if [ $retval -eq 0 ]
							then
								printMessageTo "$(date +%d/%m/%Y-%H:%M:%S) - TRAITEMENT OK" "2"
							else
								printMessageTo "$(date +%d/%m/%Y-%H:%M:%S) - TRAITEMENT KO" "2"
						fi
						execReqParamMysql "use ${reponse%%.*};show tables;"
					 ;; 
				esac
			done
			##############
		 ;;
		 "h" )
			# Vérifier que perl est installé pour la gestion des mots de passe
			execReqParamMysql "use mysql; select user from user;"
			execReqParamMysql "show databases;"
		 ;;
		 "q" | "Q" )  
			echo "Au revoir...."
			exit 1
		 ;; 
		 * )
		    echo
		   printMessageTo "\033[31m[ERREUR]\033[0m mauvais choix" "2"		
		 ;; 
	esac
done





