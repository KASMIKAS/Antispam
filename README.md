# Script de Classification d'Emails

**Réalisé par :** Mohamed Amine Kasmi

---

## Description

Ce script Bash permet de classer des fichiers emails dans trois catégories :

* **BLOCKED** : emails provenant d'expéditeurs bloqués.
* **SUSPECT** : emails dont l'objet contient des mots clés dépassant un seuil de poids.
* **CLEAN** : emails ne correspondant à aucun critère suspect ou bloqué.

Il utilise deux fichiers de configuration :

* `.expblo` : liste des expéditeurs bloqués.
* `.motsup` : liste de mots clés avec leurs poids associés.

---

## Fonctionnement

1. Vérifie l'existence des fichiers `.expblo` et `.motsup`.
2. Crée les répertoires `BLOCKED`, `SUSPECT` et `CLEAN` si nécessaire.
3. Pour chaque fichier email du répertoire courant :

   * Vérifie qu'il s'agit d'un email (première ligne `#email`).
   * Extrait l'expéditeur (2ᵉ ligne) et l'objet (3ᵉ ligne).
   * Classe l'email selon les critères définis.
   * Déplace l'email dans le répertoire correspondant.

---

## Usage

```bash
chmod +x script.sh
./script.sh
```

Assurez-vous que :

* Les fichiers `.expblo` et `.motsup` sont présents.
* Les fichiers emails respectent le format :

  ```
  #email
  expediteur@example.com
  Objet de l'email
  contenu...
  ```

---

## Structure des fichiers

* **.expblo** : un expéditeur par ligne.
* **.motsup** : chaque ligne contient `mot poids`, par exemple :

  ```
  urgent 30
  promotion 40
  ```

  Si la somme des poids des mots trouvés dans l'objet dépasse 60, l'email est suspect.

---

## Remarques

* Le script échoue si les fichiers de configuration sont absents.
* Les répertoires de destination sont créés automatiquement, sinon le script échoue.
* Ce script ne traite que les fichiers du répertoire courant.
