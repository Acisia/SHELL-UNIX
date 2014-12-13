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
if [[ $EUID -ne 0 ]]; then
   echo "Ce script doit être lancé en root"
   exit 1
fi
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
echo "     |  - AJOUT GROUP $CREA_GROUP" 
if ! getent group "$CREA_GROUP" > /dev/null 2>&1 ; then
	addgroup --system "$CREA_GROUP" --quiet
fi

#Ajout de l utilisateur
echo "     |  - AJOUT USER $CREA_USER" 
if ! id $CREA_USER > /dev/null 2>&1 ; then
adduser --system --home $DIR_HOME \
--ingroup "$CREA_GROUP" \
--gecos "$USER_NOM_COMPLET,$USER_NUM_BUREAU,$USER_TEL_PRO,$USER_TEL_PERSO,$USER_AUTRE" --disabled-password --shell \
"$CREA_USER"
fi

#Ajout du mot de passe
USER_PASSWD=`getPasswd`
echo "$CREA_USER:$USER_PASSWD" | sudo chpasswd

#Création de l'environnement
echo "     |  - CREATION ENVIRONNEMENT DOSSIER" 
mkdir -p "$DIR_HOME" "$DIR_HOME_PROJECT"  && chown "$CREA_USER":"$CREA_GROUP" "$DIR_HOME" "$DIR_HOME_PROJECT" 

echo "     |  - CREATION ENVIRONNEMENT FICHIER" 
#Création du fichier de bienvenue
touch "$DIR_HOME/Bienvenue_$CREA_USER" && chown "$CREA_USER":"$CREA_GROUP" "$DIR_HOME/Bienvenue_$CREA_USER"

#Création du fichier mail
echo "     |         | - CREATION FICHIER VIMRC" 
touch "$DIR_MAIL/$CREA_USER" && chown "$CREA_USER":"$CREA_GROUP" "$DIR_HOME/$CREA_USER"
#Création du fichier .vimrc
echo "     |         | - CREATION FICHIER VIMRC" 
getTplFic ".vimrc" "$CREA_USER" "$CREA_GROUP" "$DIR_HOME" "$DIR_TPL"
#Création du fichier .bash_aliases
echo "     |         | - CREATION FICHIER BASH_ALIASES" 
getTplFic ".bash_aliases" "$CREA_USER" "$CREA_GROUP" "$DIR_HOME" "$DIR_TPL"
#Création du fichier .gitconfig
echo "     |         | - CREATION FICHIER GITCONFIC" 
getTplFic ".gitconfig" "$CREA_USER" "$CREA_GROUP" "$DIR_HOME" "$DIR_TPL"
#Ajout du name et de l adresse mail git
echo "        name = $CREA_USER" >> "$DIR_HOME/.gitconfig"
echo "        email = $USER_ADRESSEMAIL" >> "$DIR_HOME/.gitconfig"

# RECAP INFORMATION
echo "     | ---------------------------------------------" 
echo "     |  - USER : $CREA_USER" 
echo "     |  - PASSWD : $USER_PASSWD" 
echo "     |  - GROUP : $CREA_GROUP" 
echo "     |  - Dossier utilisateur : $DIR_HOME" 
echo "     |  - Dossier Git : $DIR_HOME_PROJECT" 
echo "     | ---------------------------------------------" 
echo "    FIN" 
