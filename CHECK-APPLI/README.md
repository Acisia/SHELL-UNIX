CHECK-APPLI
==========

# Définition
Script Shell sous Linux pour tester :
  - l'utilisateur ROOT
  - la présence d'une application
 
Lancement du script :
 ```shell
 ./checkRootAppli.sh
```
# Pré-requis
La librairie des fonctions est requise
 ```shell
#CHEMIN RACINE
PATHROOT="$PWD"
# RECUPERATION DES FONCTIONS
. $PATHROOT/../lib/functions.sh
```
# Contenu
### Tester les droits root pour lancer le script
Syntaxe  :
 ```shell
checkUserRoot
```

### Vérifier qu'une application est installée
Syntaxe  :
 ```shell
checkAppli "nomApplication"
```

Exemple avec l'applciation PERL: 
```shell
checkAppli "perl"
```