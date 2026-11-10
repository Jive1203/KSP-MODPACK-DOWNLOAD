# KSP 2 dans KSP 1 — le modpack

Kerbal Space Program 1 à la façon de KSP 2 : planètes et graphismes refaits, systèmes stellaires de Debdeb et de Tuun, sol creusable partout, vrais gisements à prospecter, usines, colonies modulaires et partie en ligne à tour de rôle.

Le guide complet, bloc par bloc : **[Guide_du_modpack.pdf](Guide_du_modpack.pdf)**.

## Installer (Windows)

Il faut : **Kerbal Space Program 1.12** (Steam), avec le DLC Breaking Ground si vous l'avez, **25 Go libres**, et 30 à 60 minutes la première fois.

1. **[Télécharger le modpack](https://github.com/Jive1203/KSP-MODPACK-DOWNLOAD/archive/refs/heads/main.zip)**, puis clic droit sur le fichier, **Extraire tout**.
2. Dans le dossier extrait, double-cliquez sur **`INSTALLER.cmd`**.
3. Appuyez sur Entrée pour accepter le dossier proposé, puis attendez la fin.

L'installeur :
- trouve votre jeu Steam et en fait une **copie réservée au pack**, « KSP MODPACK », à côté du jeu : votre partie habituelle n'est pas touchée ;
- télécharge [CKAN](https://github.com/KSP-CKAN/CKAN) (l'outil officiel d'installation de mods) et installe les 133 mods du pack, **toujours aux mêmes versions**, pour que tout le monde ait exactement le même jeu ;
- ajoute les mods propres au pack (dossier `GameData` de ce dépôt) ;
- met un raccourci **KSP MODPACK** sur le Bureau.

Le premier lancement est long (jusqu'à 10 minutes) : le jeu prépare les textures. Si Parallax parle du réglage du terrain : **Paramètres**, **Graphismes**, **Détail du terrain** sur **High**, puis redémarrez.

## Mettre à jour

Téléchargez de nouveau le modpack et relancez `INSTALLER.cmd` en choisissant le même dossier « KSP MODPACK ».

## Jouer ensemble

Tout se fait dans la fenêtre **Partie en ligne** du menu principal : qui héberge, **Rejoindre** ou **Héberger et jouer**. Le mode d'emploi est dans `GameData/PartieEnLigne/PluginData/LISEZMOI.txt`. Tous les joueurs doivent avoir la même version du jeu et du pack.

## En cas de problème

Envoyez `KSP.log` (dossier du pack) ou `Player.log` (`%USERPROFILE%\AppData\LocalLow\Squad\Kerbal Space Program`), et `installation_ckan.log` (dossier du pack) si l'installation a échoué.

## Contenu de ce dépôt

| Élément | Rôle |
|---|---|
| `INSTALLER.cmd`, `installeur/` | l'installeur en un clic |
| `ksp2-dans-ksp1.ckan` | la liste exacte des mods et de leurs versions, lue par CKAN |
| `GameData/Chantiers` | minage, sol creusable, gisements, prospection, usines, colonies |
| `GameData/PartieEnLigne` | partie en ligne à tour de rôle, avec le serveur Luna Multiplayer modifié |
| `GameData/VerrouKonstructs` | bloque l'éditeur de bases de Kerbal Konstructs |
| `GameData/zzz_KSP2dansKSP1` | correctifs du pack |

Les mods des autres auteurs ne sont pas copiés ici : CKAN les télécharge depuis leurs sources officielles.
