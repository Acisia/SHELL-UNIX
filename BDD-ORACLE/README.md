BDD-ORACLE
==========

# Définition
Script Shell sous Linux pour tester :
  - executer des requetes dans une base oracle

 
Lancement du script :
 ```shell
 ./bddOracle.sh
```
# Pré-requis
La librairie des fonctions et le fichier de config.sh sont requis
 ```shell
#CHEMIN RACINE
PATHROOT="$PWD"
# RECUPERATION DES FONCTIONS
. $PATHROOT/../lib/functions.sh
#RECUPERATION DES PROPERTIES
. $PATHROOT/../config/config.sh
```
# Contenu

### Tester le retour d'une requete
Syntaxe  :
 ```shell
execReqOracle "SELECT * FROM TABLE;" "$PATHDESTLOG"
retval=$?
if [ $retval -eq 0 ]
	then
		printMessageTo "$(date +%d/%m/%Y-%H:%M:%S) - TRAITEMENT OK" "2" "2" "$PATHDEST_FICLOG"	
	else
		printMessageTo "$(date +%d/%m/%Y-%H:%M:%S) - TRAITEMENT KO" "2" "2" "$PATHDEST_FICLOG"		
fi
```

### Tester le retour en erreur d'une requete
Syntaxe  :
 ```shell
if [ $retval -ne 0 ]; then
  exit 1
fi
```