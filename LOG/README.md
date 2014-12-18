LOG
==========

# Définition
Script Shell sous Linux pour informer :
  - Affichage dans la console
  - Ecriture dans les logs
 
Lancement du script :
 ```shell
 ./printMessage.sh
```
# Pré-requis
La librairie des fonctions est requise
```shell
 #CHEMIN RACINE
 PATHROOT="$PWD"
 # RECUPERATION DES FONCTIONS
 . $PATHROOT/../lib/functions.sh
```
Le fichier de config est requis
```shell
 #RECUPERATION DES PROPERTIES
 . $PATHROOT/../config/config.sh
```
Il contient la définition de `$PATHDEST_FICLOG` (nom et chemin de fichier de log)

 


# Contenu
### J'affiche uniquement sur l'écran
Syntaxe  :
```shell
printMessageTo "Message à afficher"
```

### J'affiche avec un style de formattage uniquement sur l'écran
Syntaxe  :
```shell
printMessageTo "Message à afficher" "2"
```

### J'affiche uniquement dans le fichier de log $PATHDEST_FICLOG
Syntaxe  :
```shell
printMessageTo "Message à afficher" "0" "1" "$PATHDEST_FICLOG"
```

### J'affiche avec un style de formattage uniquement dans le fichier de log  $PATHDEST_FICLOG
Syntaxe  :
```shell
printMessageTo "Message à afficher" "2" "1" "$PATHDEST_FICLOG" "$PATHDEST_FICLOG"
```

### J'affiche à l'écran et dans le fichier de log $PATHDEST_FICLOG
Syntaxe  :
```shell
printMessageTo "Message à afficher" "0" "2" "$PATHDEST_FICLOG"
```

### J'affiche avec un style de formattage à l'écran et dans le fichier de log  $PATHDEST_FICLOG
Syntaxe  :
```shell 
printMessageTo "Message à afficher" "2" "2" "$PATHDEST_FICLOG"
```
