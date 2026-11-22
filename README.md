# Corsa Alta

Le prototype Windows propose une épingle de 280 m sur le plat et une rampe rectiligne de 240 m à 10 %, praticable en montée comme en descente.

## Lancer le prototype sur Windows

- **Depuis un export Windows**, double-cliquer sur `CorsaAlta.exe`. Sur le poste de développement, il se trouve dans le dossier `build`.
- **Depuis les sources GitHub**, cloner ou télécharger le dépôt, ouvrir le gestionnaire de projets de [Godot 4.7.2 standard](https://godotengine.org/download/archive/4.7.2-stable/), importer [prototype/project.godot](prototype/project.godot), ouvrir le projet et appuyer sur **F5**.

## Comparer la montée et la descente

À l’accueil, choisir **F2** pour partir du pied de la rampe ou **F3** pour partir du sommet, puis **Entrée**. Accélérer avec **Z**. Au niveau des deux poteaux bleus, à mi-parcours, relâcher **Z** et maintenir **S**. Refaire le passage dans l’autre sens en visant la même vitesse au repère. Pour changer de parcours pendant un essai, passer d’abord en pause avec **Échap**. **F1** ramène à l’épingle plate.

À 80 km/h sur asphalte sec, le test automatisé mesure 23,71 m en montée, 26,08 m sur le plat et 29,28 m en descente. Les distances sont mesurées le long de la chaussée à partir de l’appui sur le frein.

## Essayer l’épingle plate

1. Appuyer sur **Entrée** et attendre la fin du décompte. Accélérer avec **Z**, freiner avec **S** et tourner avec **Q** ou **D**. Maintenir la touche de direction pour augmenter progressivement le braquage.
2. Au premier passage, freiner avant l’épingle, tourner à droite et rejoindre la ligne d’arrivée. Noter le chrono et appuyer sur **Entrée** pour repartir.
3. Au deuxième passage, freiner plus tard. Observer où la voiture élargit sa trajectoire et si une correction au clavier permet de la ramener. Pour essayer l’herbe, engager le centre de la voiture sur le bas-côté.

**Échap** met en pause ou reprend la conduite. Depuis la pause, **R** recommence au départ. Pour reculer, arrêter la voiture, relâcher **S**, puis appuyer de nouveau sur **S**. **F10** quitte le jeu.

Pour faire un retour, préciser l’endroit, les touches utilisées, le comportement attendu et celui observé. La [note technique](docs/decisions/0001-moteur-et-rendu.md) décrit aussi le test automatisé, l’export Windows et la mesure de performance.
