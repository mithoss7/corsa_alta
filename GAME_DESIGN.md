# Corsa Alta — Spécification des exigences logicielles

| Champ | Valeur |
| --- | --- |
| Version du document | 0.2 |
| Statut | Projet de spécification |
| Périmètre | Première version jouable |
| Référentiel | [ISO/IEC/IEEE 29148:2018](https://www.iso.org/standard/72089.html), structure adaptée au projet |

## 1. Objet et périmètre

Corsa Alta est un jeu de course automobile en 3D pour Windows 11. Toutes les épreuves relient deux points distincts, du départ A à l’arrivée B. La première se déroule sur une route de montagne. Le joueur cherche à améliorer son temps en travaillant ses freinages et ses trajectoires. Le réalisme du comportement de la voiture guide les réglages de conduite au clavier.

| Terme | Définition |
| --- | --- |
| Tentative | Un essai sur le trajet de A à B, qui se termine à l’arrivée ou par un abandon. |
| Secteur | Portion du trajet comprise entre deux points de chronométrage consécutifs. |
| Temps de passage | Temps écoulé depuis le départ jusqu’à la fin d’un secteur. |
| Référence personnelle | Tentative terminée la plus rapide du joueur, avec son temps final et ses temps de passage. |

### Configuration observée sur le PC du joueur

| Élément | Relevé PowerShell du 20 novembre 2026 |
| --- | --- |
| Processeur | Intel Core i5-6500 à 3,20 GHz |
| Mémoire | 15,9 Gio de RAM |
| Contrôleurs graphiques | NVIDIA Quadro K2000 et Intel HD Graphics 530 |
| Mode d’affichage | 1920 × 1080 à 60 Hz |

## 2. Besoins du joueur et de l’équipe de développement

| ID | Besoin |
| --- | --- |
| B-01 | Installer le jeu sur un PC Windows 11 et y jouer au clavier avec une animation fluide pendant toute la course. |
| B-02 | Disputer en solo un trajet chronométré sur une route de montagne, avec une caméra derrière la voiture, puis pouvoir rejouer immédiatement après le résultat. |
| B-03 | Gagner du temps en améliorant ses freinages et ses trajectoires avec les commandes `ZQSD`. |
| B-04 | Lire le temps écoulé pendant la tentative et retrouver ses résultats et son record personnel d’une session à l’autre. |
| B-05 | Faire évoluer le contenu et les fonctionnalités du jeu en préservant la maintenabilité du logiciel. |

## 3. Exigences et vérification

Chaque exigence porte un identifiant stable et renvoie au besoin qu’elle couvre. « Doit » indique une exigence de la première version. Les critères ci-dessous servent à vérifier le jeu sur une version jouable.

### 3.1 Plateforme et commandes

| ID | Besoin | Exigence | Critère de vérification |
| --- | --- | --- | --- |
| CA-001 | B-01 | Le jeu doit pouvoir être installé sur Windows 11. | Installer et lancer le jeu sur un PC Windows 11. |
| CA-002 | B-01 | Le jeu doit permettre de lancer, jouer et relancer une tentative au clavier. | Depuis l’écran d’accueil, lancer une tentative, la terminer et en relancer une au clavier. |
| CA-003 | B-03 | Le jeu doit commander l’accélérateur avec `Z`. | En ligne droite, appuyer sur `Z` et constater que la voiture prend de la vitesse. |
| CA-004 | B-03 | Le jeu doit commander le frein avec `S`. | En ligne droite, voiture en mouvement, appuyer sur `S` et constater le ralentissement. |
| CA-005 | B-03 | Le jeu doit commander la direction à gauche avec `Q`. | En roulant, appuyer sur `Q` et constater que la voiture tourne à gauche. |
| CA-006 | B-03 | Le jeu doit commander la direction à droite avec `D`. | En roulant, appuyer sur `D` et constater que la voiture tourne à droite. |
| CA-007 | B-03 | Lorsque `Q` ou `D` reste enfoncée, le braquage doit augmenter progressivement dans la direction choisie, jusqu’à sa limite. | Pour chaque direction, observer que l’angle de braquage augmente pendant le maintien de la touche avant d’atteindre sa limite. |

### 3.2 Conduite et déroulement de l’épreuve

| ID | Besoin | Exigence | Critère de vérification |
| --- | --- | --- | --- |
| CA-008 | B-02 | Le jeu doit rendre l’épreuve en 3D. | Inspecter la scène jouable et vérifier que la route, la voiture et le relief sont positionnés dans un espace à trois dimensions. |
| CA-009 | B-02 | Pendant l’épreuve, la caméra doit suivre la voiture depuis l’arrière. | Observer la position de la caméra par rapport à la voiture en ligne droite et en virage. |
| CA-010 | B-02 | Le jeu doit proposer un contre-la-montre en solo sur un tracé de montagne. | Lancer l’épreuve et vérifier qu’elle se déroule sur une route en relief montagneux, avec la voiture du joueur comme seule participante. |
| CA-011 | B-02 | Chaque épreuve doit relier un départ A et une arrivée B distincts en un seul trajet. | Sur chaque tracé, vérifier que la tentative se termine en B dès le premier passage valide et que B est distinct de A. |
| CA-012 | B-02 | À l’arrivée, le jeu doit afficher le temps final de la tentative. | Terminer une tentative et vérifier que le résultat affiche le temps écoulé du départ à l’arrivée. |
| CA-013 | B-02 | Le jeu doit permettre de relancer une tentative depuis le résultat. | Depuis l’affichage du temps final, relancer l’épreuve et vérifier que le chrono repart de zéro. |
| CA-014 | B-03 | Le temps de passage dans un virage doit dépendre du point de freinage et de la trajectoire suivie. | Dans un même virage, à conditions d’entrée équivalentes, comparer des passages en faisant varier le point de freinage puis la trajectoire. Vérifier que chaque variation peut modifier le temps jusqu’à un même point de sortie. |

### 3.3 Chronométrage par secteur et record personnel

| ID | Besoin | Exigence | Critère de vérification |
| --- | --- | --- | --- |
| CA-015 | B-04 | Le jeu doit relever le temps de passage à la fin de chaque secteur. | Vérifier, sur une tentative terminée, que chaque secteur est associé à un temps cumulé depuis le départ. |
| CA-016 | B-04 | Le jeu doit utiliser la première tentative terminée comme référence personnelle initiale. | Partir sans référence, terminer une tentative, puis vérifier que son temps final et ses temps de passage servent de référence. |
| CA-017 | B-04 | Pendant la conduite, le temps écoulé depuis le départ doit être la seule information de chronométrage affichée. | Effectuer un trajet avec un record déjà enregistré. Vérifier sur tout le parcours, y compris aux points intermédiaires, que le chrono reste affiché sans indication d’avance ou de retard. |
| CA-018 | B-04 | Le jeu doit remplacer la référence personnelle uniquement lorsqu’une tentative terminée améliore le temps final de référence. | Après une tentative plus rapide, vérifier que ses temps de passage servent aux comparaisons suivantes. Après une tentative plus lente ou à égalité, vérifier que la référence précédente est conservée. |

### 3.4 Conditions de course et conduite

| ID | Besoin | Exigence | Critère de vérification |
| --- | --- | --- | --- |
| CA-019 | B-02 | Le premier trajet doit viser une durée de 3 à 5 minutes pour une bonne tentative. | En essai de conduite, chronométrer un parcours complet et maîtrisé, sans pause ni incident, et comparer sa durée à la plage cible. |
| CA-020 | B-02 | La première épreuve doit se courir avec une voiture à boîte automatique, sur asphalte sec et de jour. | Depuis une nouvelle partie, parcourir le tracé avec la voiture prévue, observer les conditions de route et vérifier que les rapports passent automatiquement. |
| CA-021 | B-03 | En marche avant, un appui sur `S` doit freiner jusqu’à l’arrêt. Un nouvel appui à l’arrêt doit enclencher la marche arrière. | Maintenir `S` jusqu’à l’immobilisation, vérifier que la voiture reste arrêtée, puis relâcher et appuyer à nouveau pour reculer. |
| CA-022 | B-03 | Le joueur doit se dégager en manœuvrant lui-même le véhicule. Toute commande de remise en piste est exclue. | Immobiliser la voiture face à une glissière, contrôler les actions disponibles en conduite et en pause, puis se dégager en marche arrière. |
| CA-023 | B-02 | Le départ doit être arrêté, avec un décompte 3–2–1. Au signal de départ, le jeu doit libérer la voiture et lancer le chrono simultanément. | Maintenir l’accélérateur pendant le décompte. Vérifier que la voiture et le chrono restent à l’arrêt jusqu’au signal. |
| CA-024 | B-04 | Une collision ou des dégâts doivent laisser la tentative en cours admissible au record. | Heurter une glissière puis terminer le parcours en améliorant le record. Vérifier que le résultat est accepté comme nouvelle référence. |
| CA-025 | B-03 | Pendant la conduite, le jeu doit afficher la vitesse et le chrono. Le joueur doit lire les virages sur la route, sans annonce visuelle ou sonore du virage à venir. | Parcourir plusieurs virages, vérifier la lisibilité de la vitesse et du temps ainsi que l’absence d’annonce anticipée. |

### 3.5 Pause, abandon et résultats

| ID | Besoin | Exigence | Critère de vérification |
| --- | --- | --- | --- |
| CA-026 | B-02 | La touche `Échap` ou la perte de focus de la fenêtre doit suspendre la simulation et le chrono. | Essayer chaque déclencheur en mouvement. Après quelques secondes, reprendre et vérifier que la voiture et le chrono repartent de leur état à la mise en pause. |
| CA-027 | B-02 | Le joueur doit pouvoir abandonner et recommencer depuis la pause. | Relancer depuis la pause. Vérifier que le décompte recommence en A et que le record appartient toujours à la même tentative terminée. |
| CA-028 | B-04 | Le jeu doit conserver localement le record, ses temps de passage et un historique des essais entre deux lancements. | Terminer deux tentatives avec des temps différents. Fermer et relancer le jeu, retrouver les deux résultats et vérifier que le record sauvegardé correspond à la tentative la plus rapide. |

### 3.6 Maintenabilité et extension

| ID | Besoin | Exigence | Critère de vérification |
| --- | --- | --- | --- |
| CA-029 | B-05 | L’architecture doit isoler la définition des véhicules et des tracés des règles de chronométrage et de classement. | Lors d’un essai de développement, intégrer un véhicule puis un tracé de test par les points d’extension documentés. Rejouer les vérifications du chronométrage et du record avec les mêmes règles. |

### 3.7 Performance en course

| ID | Besoin | Exigence | Critère de vérification |
| --- | --- | --- | --- |
| CA-030 | B-01 | Sous Windows 11, le jeu doit maintenir 60 images/s stables en 1920 × 1080 avec les réglages graphiques bas, sur une carte graphique légèrement moins performante que la NVIDIA Quadro K2000. | Sur le PC de test, enregistrer les intervalles entre images du départ à l’arrivée. Comparer les intervalles mesurés au budget de 16,67 ms par image et relever la fréquence et la durée des dépassements. |

## 4. Décisions ouvertes

- Nombre et emplacement des points intermédiaires et détail du bilan à l’arrivée.
- Règle de classement en cas de raccourci ou de point de passage manqué. Les dégâts seuls préservent l’admissibilité au record.
- Effets des dégâts sur la conduite et valeurs de réglage du modèle physique.
- Contenu de l’historique pour les tentatives abandonnées.
- Modèle exact de carte graphique pour la recette de CA-030 et tolérance aux dépassements ponctuels du budget de 16,67 ms.
