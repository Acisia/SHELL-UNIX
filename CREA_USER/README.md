# Création d'utilisateur Linux

 1. Clonez ce repo avec l'utilisateur `root` dans `/root/projects`
 2. Déplacez vous dans le répertoire `shell-script/manage_user`
 3. Editez le fichier `crea_user.sh` pour remplacer les `PARAMETRES A MODIFIER`
 4. Enfin executez le script `./crea_user.sh`, votre utilisateur est créé !

Exemple de `PARAMETRES A MODIFIER` :

```shell
#PARAMETRES A MODIFIER
USER_NOM=NOM
USER_PRENOM=PRENOM
USER_ADRESSEMAIL=NOM.PRENOM@ext.com
USER_NUM_BUREAU="DSI"
USER_TEL_PRO="0711111111"
USER_TEL_PERSO="0600000011"
USER_AUTRE="utilisateur"
```

Le `USER_NOM`, `USER_PRENOM` et `USER_ADRESSEMAIL` sont obligatoires, le login et password sont autogénéré.

Le login se compose de la première lettre du prénom et du nom. Pour créer le user `master` par exemple, vous pouvez renseigner le nom / prénom de cette façon :

* Nom : ASTER
* Prénom : M
 
Le login sera : `master`

**N'oubliez pas de copier, coller le login password une fois l'utilisateur créé !**

