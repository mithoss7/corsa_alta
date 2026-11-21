# Corsa Alta

Le prototype « Épingle d’essai » est un contre-la-montre en 3D au clavier. Son parcours de 280 m permet d’essayer le freinage et le braquage dans une épingle à droite.

## Lancer le prototype sur Windows

- **Depuis un export Windows**, double-cliquer sur `CorsaAlta.exe`. Sur le poste de développement, il se trouve dans le dossier `build`.
- **Depuis les sources GitHub**, cloner ou télécharger le dépôt, ouvrir le gestionnaire de projets de [Godot 4.7.2 standard](https://godotengine.org/download/archive/4.7.2-stable/), importer [prototype/project.godot](prototype/project.godot), ouvrir le projet et appuyer sur **F5**.

## Faire un essai

1. Appuyer sur **Entrée** et attendre la fin du décompte. Accélérer avec **Z**, freiner avec **S** et tourner avec **Q** ou **D**. Maintenir la touche de direction pour augmenter progressivement le braquage.
2. Au premier passage, freiner avant l’épingle, tourner à droite et rejoindre la ligne d’arrivée. Noter le chrono et appuyer sur **Entrée** pour repartir.
3. Au deuxième passage, freiner plus tard. Observer où la voiture élargit sa trajectoire et si une correction au clavier permet de la ramener. Pour essayer l’herbe, engager le centre de la voiture sur le bas-côté.

**Échap** met en pause ou reprend la conduite. Depuis la pause, **R** recommence au départ. Pour reculer, arrêter la voiture, relâcher **S**, puis appuyer de nouveau sur **S**. **F10** quitte le jeu.

Pour faire un retour, préciser l’endroit, les touches utilisées, le comportement attendu et celui observé. La [note technique](docs/decisions/0001-moteur-et-rendu.md) décrit aussi le test automatisé, l’export Windows et la mesure de performance.
