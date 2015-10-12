#!/bin/bash
###################################################################################################################
# Author : Louis DAUBIGNARD
# Date   : 11/12/2014
#
# Description : Script pour :
#		- cree le user et l'environnement d un user linux
#
# Syntax : crea_user.sh 
#
###################################################################################################################
#CHEMIN RACINE
PATHROOT="$PWD"
#RECUPERATION DES PARAMETRES
. $PATHROOT/user_param.sh

#RECUPERATION DES FONCTIONS
. $PATHROOT/../lib/functions.sh

#RECUPERATION DES PROPERTIES
. $PATHROOT/../config/config.sh


echo  "--------------------------------------------------------------------------------------------------"
echo  "                   CREATION UTILISATEUR LINUX													"
echo  "--------------------------------------------------------------------------------------------------"


##################################################################################################################
# TEST PRE-REQUIS
# Vérifier que l'utilisateur est root
checkUserRoot
# Vérifie le dossier log
checkLog $PATHDEST_REPLOG $FICLOGNAME
# Vérifier que perl est installé pour la gestion des mots de passe
checkAppli perl
##################################################################################################################
# MISE EN PLACE DES VARIABLES
USER_NOM_COMPLET="$USER_PRENOM $USER_NOM"
USER_LOGIN=`getLoginName $USER_NOM $USER_PRENOM`
CREA_USER=$USER_LOGIN
CREA_GROUP=$USER_LOGIN
#DOSSIER
DIR_HOME=/home/$USER_LOGIN
DIR_MAIL=/var/mail
DIR_HOME_PROJECT=/home/$USER_LOGIN/projects
DIR_TPL=$PATHROOT/tpl
# Affichage des parametres
echo "     | ---------------------------------------------" 
echo "     |  - Nom : $USER_NOM"
echo "     |  - Prénom : $USER_PRENOM"
echo "     |  - Nom Complet : $USER_NOM_COMPLET"
echo "     |  - Login : $USER_LOGIN"
echo "     |  - Adresse email : $USER_ADRESSEMAIL"
echo "     |  - N° de bureau : $USER_NUM_BUREAU"
echo "     |  - Téléphone professionnel : $USER_TEL_PRO"
echo "     |  - Téléphone personnel  : $USER_TEL_PERSO" 
echo "     |  - Autre  : $USER_AUTRE" 
echo "     | ---------------------------------------------" 


# Deplacement dans le dossier personnel de l'utilisateur
cd ~

#Ajout du groupe utilisateur
#echo "     |  - AJOUT GROUP $CREA_GROUP" 
#if ! getent group "$CREA_GROUP" > /dev/null 2>&1 ; then
#	addgroup --system "$CREA_GROUP" --quiet
#fi

#Génération du mot de passe
USER_PASSWD=`getPasswd`

#Ajout de l utilisateur
	###########################################################
	# useradd 	[-c commentaire] [-d rép_perso]
    # 			[-e date_expiration] [-f temps_inactivité]
    # 			[-g groupe_initial] [-G groupe[,...]]
    # 			[-m [-k rép_squelette] | -M] [-p mot_de_passe crypté]
    # 			[-s shell] [-u uid [ -o]] [-n] [-r] login 
	# useradd	 -D [-g groupe_défaut] [-b rép_perso_défaut]
    # 			[-f inactivité] [-e date_expiration_défaut]
    # 			[-s shell_défaut] 
	###########################################################

egrep "^$CREA_USER" /etc/passwd >/dev/null
	if [ $? -eq 0 ]; then
		echo "[ERREUR] $CREA_USER exists!"
		exit 1
	else
		useradd -m -p $(openssl passwd -1 $USER_PASSWD)  -s /bin/bash -c "$USER_NOM_COMPLET,$USER_NUM_BUREAU,$USER_TEL_PRO,$USER_TEL_PERSO,$USER_AUTRE" -U $CREA_USER
		if [ $? -eq 0 ]; then
			echo -e "\033[32m[USER-ADD]\033[0m $CREA_USER a été ajouté au system!"
		else 
			echo -e "\033[31m[ERREUR]\033[0m Impossible d'ajouter l'utilisateur $CREA_USER!"
			exit 1
		fi
	fi


#Création de l'environnement
echo "     |  - CREATION ENVIRONNEMENT DOSSIER" 
mkdir -p "$DIR_HOME" "$DIR_HOME_PROJECT"  && chown "$CREA_USER":"$CREA_GROUP" "$DIR_HOME" "$DIR_HOME_PROJECT" 

echo "     |  - CREATION ENVIRONNEMENT FICHIER" 
#Création du fichier de bienvenue
touch "$DIR_HOME/Bienvenue_$CREA_USER" && chown "$CREA_USER":"$CREA_GROUP" "$DIR_HOME/Bienvenue_$CREA_USER"

#Création du fichier mail
echo "     |         | - CREATION FICHIER MAIL" 
touch "$DIR_MAIL/$CREA_USER" && chown "$CREA_USER":"$CREA_GROUP" "$DIR_MAIL/$CREA_USER"
#Création du fichier .vimrc
echo "     |         | - CREATION FICHIER VIMRC" 
getTplFic ".vimrc" "$CREA_USER" "$CREA_GROUP" "$DIR_HOME" "$DIR_TPL"
#Création du fichier .bash_aliases
echo "     |         | - CREATION FICHIER BASH_ALIASES" 
getTplFic ".bash_aliases" "$CREA_USER" "$CREA_GROUP" "$DIR_HOME" "$DIR_TPL"
#Création du fichier .gitconfig
echo "     |         | - CREATION FICHIER GITCONFIG" 
getTplFic ".gitconfig" "$CREA_USER" "$CREA_GROUP" "$DIR_HOME" "$DIR_TPL"
#Ajout du name et de l adresse mail git
echo "        name = $CREA_USER" >> "$DIR_HOME/.gitconfig"
echo "        email = $USER_ADRESSEMAIL" >> "$DIR_HOME/.gitconfig"
#creation des cle ssh
echo "     |         | - CREATION CLE SSH"
checkPathDst "$DIR_HOME/.ssh/" "Chemin Cle SSH"
chown -R "$CREA_USER:$CREA_USER" "$DIR_HOME"
ssh-keygen -C "$USER_ADRESSEMAIL" -t rsa -f "$DIR_HOME/.ssh/id_rsa" -q -N ""
chown -R "$CREA_USER:$CREA_USER" "$DIR_HOME"
#su -l "$CREA_USER" -c 'ssh-keygen -C "$USER_ADRESSEMAIL" -t rsa -f "$DIR_HOME/.ssh/id_rsa" -q -N ""'

# RECAP INFORMATION
echo "     | ---------------------------------------------" 
echo "     |  - USER : $CREA_USER" 
echo "     |  - PASSWD : $USER_PASSWD" 
echo "     |  - GROUP : $CREA_GROUP" 
echo "     |  - Dossier utilisateur : $DIR_HOME" 
echo "     |  - Dossier Git : $DIR_HOME_PROJECT" 
echo "     |  - Cle SSH : $DIR_HOME/.ssh/"
echo "     | ---------------------------------------------" 
cat $DIR_HOME/.ssh/id_rsa.pub
echo "     | ---------------------------------------------"
echo "     | "
echo "    FIN" 
