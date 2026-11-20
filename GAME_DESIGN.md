# Corsa Alta — Spécification des exigences logicielles

| Champ | Valeur |
| --- | --- |
| Version du document | 0.1 |
| Statut | Projet de spécification |
| Périmètre | Première version jouable |
| Référentiel | [ISO/IEC/IEEE 29148:2018](https://www.iso.org/standard/72089.html), structure adaptée au projet |

## 1. Objet et périmètre

Corsa Alta est un jeu de course automobile en 3D pour PC Windows. Le joueur dispute un contre-la-montre en solo sur une route de montagne. Il cherche à améliorer son temps en travaillant ses points de freinage et ses trajectoires. D’autres types de circuits pourront être envisagés après la première version.

| Terme | Définition |
| --- | --- |
| Tentative | Une épreuve jouée du départ à l’arrivée. Le terme « tour » désigne ici ce parcours unique. |
| Temps de passage | Temps écoulé depuis le départ jusqu’à la fin d’un secteur. |
| Référence personnelle | Tentative terminée la plus rapide du joueur, avec son temps final et ses temps de passage. |

## 2. Besoins du joueur

| ID | Besoin |
| --- | --- |
| B-01 | Installer le jeu sur un PC Windows et y jouer au clavier. |
| B-02 | Disputer en solo un tour chronométré sur une route de montagne, avec une caméra derrière la voiture, puis pouvoir rejouer immédiatement après le résultat. |
| B-03 | Gagner du temps en améliorant ses freinages et ses trajectoires avec les commandes `ZQSD`. |
| B-04 | Savoir où l’on gagne ou perd du temps par rapport à sa meilleure tentative. |

## 3. Exigences et vérification

Chaque exigence porte un identifiant stable et renvoie au besoin qu’elle couvre. « Doit » indique une exigence de la première version. Les critères ci-dessous servent à vérifier le jeu sur une version jouable.

### 3.1 Plateforme et commandes

| ID | Besoin | Exigence | Critère de vérification |
| --- | --- | --- | --- |
| CA-001 | B-01 | Le jeu doit pouvoir être installé sur un PC Windows. | Installer le jeu sur une version de Windows prise en charge, puis le lancer depuis cette installation. |
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
| CA-011 | B-02 | Le jeu doit chronométrer un seul tour par tentative. | Lancer une tentative et vérifier que le chrono couvre le trajet du départ à l’arrivée. La tentative se termine au premier passage valide à l’arrivée. |
| CA-012 | B-02 | À l’arrivée, le jeu doit afficher le temps final de la tentative. | Terminer une tentative et vérifier que le résultat affiche le temps écoulé du départ à l’arrivée. |
| CA-013 | B-02 | Le jeu doit permettre de relancer une tentative depuis le résultat. | Depuis l’affichage du temps final, relancer l’épreuve et vérifier que le chrono repart de zéro. |
| CA-014 | B-03 | Le temps de passage dans un virage doit dépendre du point de freinage et de la trajectoire suivie. | Dans un même virage, à conditions d’entrée équivalentes, comparer des passages en faisant varier le point de freinage puis la trajectoire. Vérifier que chaque variation peut modifier le temps jusqu’à un même point de sortie. |

### 3.3 Chronométrage par secteur et record personnel

| ID | Besoin | Exigence | Critère de vérification |
| --- | --- | --- | --- |
| CA-015 | B-04 | Le jeu doit relever le temps de passage à la fin de chaque secteur. | Vérifier, sur une tentative terminée, que chaque secteur est associé à un temps cumulé depuis le départ. |
| CA-016 | B-04 | Le jeu doit utiliser la première tentative terminée comme référence personnelle initiale. | Partir sans référence, terminer une tentative, puis vérifier que son temps final et ses temps de passage servent de référence. |
| CA-017 | B-04 | Si une référence personnelle existe, le jeu doit afficher à la fin de chaque secteur l’écart en secondes entre le temps de passage courant et celui de la référence au même point. | Pour un temps de référence de 30 s au point de passage, vérifier qu’un passage à 28 s indique 2 s d’avance, qu’un passage à 32 s indique 2 s de retard et qu’un passage à 30 s indique un écart nul. |
| CA-018 | B-04 | Le jeu doit remplacer la référence personnelle uniquement lorsqu’une tentative terminée améliore le temps final de référence. | Après une tentative plus rapide, vérifier que ses temps de passage servent aux comparaisons suivantes. Après une tentative plus lente ou à égalité, vérifier que la référence précédente est conservée. |

## 4. Décisions ouvertes

- Forme du tracé et emplacement des secteurs.
- Conditions exactes de déclenchement du chrono et de validation de l’arrivée.
- Réglage de la conduite et du braquage progressif.
- Versions de Windows prises en charge et format d’installation.
- Conservation du record personnel entre deux lancements du jeu.
