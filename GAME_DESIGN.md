# Corsa Alta — Spécification des exigences logicielles

| Champ | Valeur |
| --- | --- |
| Version du document | 0.4 |
| Statut | Référence de travail validée pour le prototype de faisabilité |
| Date de validation | 21 novembre 2026 |
| Périmètre | Première version jouable |
| Référentiel | [ISO/IEC/IEEE 29148:2018](https://www.iso.org/standard/72089.html), structure adaptée au projet |

## 1. Objet et périmètre

Corsa Alta est un jeu de course automobile en 3D pour Windows 11. Toutes les épreuves relient deux points distincts, du départ A à l’arrivée B. La première se déroule sur une route de montagne. Le joueur cherche à améliorer son temps en travaillant ses freinages et ses trajectoires. Le réalisme du comportement de la voiture guide les réglages de conduite au clavier.

| Terme | Définition |
| --- | --- |
| Tentative | Un essai sur le trajet de A à B, qui se termine à l’arrivée ou par un abandon. |
| Record personnel | Meilleur temps final du joueur parmi ses courses terminées sur le même trajet. |

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
| CA-011 | B-02 | Chaque tentative partie de A doit se terminer dès que la voiture atteint B. Tout trajet ainsi terminé compte pour le record, quel que soit le chemin emprunté. | Rejoindre B après une sortie de route et vérifier que le jeu enregistre le temps total et le traite comme celui d’une course terminée sur la chaussée. |
| CA-012 | B-02 | À l’arrivée, le jeu doit afficher le temps final et le record personnel à jour. Il doit afficher « Nouveau record » lorsque le joueur établit ou améliore ce record. | Finir une première course, améliorer le temps, puis l’égaler. Vérifier les deux temps affichés dans chaque cas et la mention de record lors des deux premières arrivées. |
| CA-013 | B-02 | Le jeu doit permettre de relancer une tentative depuis le résultat. | Depuis l’affichage du temps final, relancer l’épreuve et vérifier que le chrono repart de zéro. |
| CA-014 | B-03 | Le joueur doit pouvoir tenir la trajectoire d’une épingle en freinant avant l’entrée. Une vitesse d’entrée excessive doit élargir la trajectoire. Une perte d’adhérence modérée doit être récupérable au clavier par la direction et le dosage de l’accélérateur. | Dans la même épingle, comparer une entrée trop rapide et une entrée précédée d’un freinage. Reproduire ensuite une glissade modérée et vérifier que les corrections avec ZQSD permettent de stabiliser la voiture. |

### 3.3 Chronométrage du trajet et record personnel

| ID | Besoin | Exigence | Critère de vérification |
| --- | --- | --- | --- |
| CA-016 | B-04 | La première course terminée doit établir le record personnel du trajet. | Partir sans record, terminer une course et vérifier que son temps final devient le record. |
| CA-017 | B-04 | Pendant la conduite, le temps écoulé depuis le départ doit être la seule information de chronométrage affichée. | Avec un record déjà enregistré, vérifier du départ à l’arrivée que seul le chrono de la tentative est affiché comme information de temps. |
| CA-018 | B-04 | Toute course terminée avec un temps strictement inférieur au record doit le remplacer. | Établir un record, l’améliorer après un contact avec une glissière, puis finir à égalité et avec un temps plus lent. Vérifier la valeur du record après chaque arrivée. |

### 3.4 Conditions de course et conduite

| ID | Besoin | Exigence | Critère de vérification |
| --- | --- | --- | --- |
| CA-019 | B-02 | Le premier trajet doit viser une durée de 3 à 5 minutes pour une bonne tentative. | En essai de conduite, chronométrer un parcours complet et maîtrisé, sans pause ni incident, et comparer sa durée à la plage cible. |
| CA-020 | B-02 | La première épreuve doit se courir avec une voiture à boîte automatique, sur asphalte sec et de jour. | Depuis une nouvelle partie, parcourir le tracé avec la voiture prévue, observer les conditions de route et vérifier que les rapports passent automatiquement. |
| CA-021 | B-03 | En marche avant, un appui sur `S` doit freiner jusqu’à l’arrêt. Un nouvel appui à l’arrêt doit enclencher la marche arrière. | Maintenir `S` jusqu’à l’immobilisation, vérifier que la voiture reste arrêtée, puis relâcher et appuyer à nouveau pour reculer. |
| CA-022 | B-03 | Le joueur doit se dégager en manœuvrant lui-même le véhicule. Toute commande de remise en piste est exclue. | Immobiliser la voiture face à une glissière, contrôler les actions disponibles en conduite et en pause, puis se dégager en marche arrière. |
| CA-023 | B-02 | Le départ doit être arrêté, avec un décompte 3–2–1. Au signal de départ, le jeu doit libérer la voiture et lancer le chrono simultanément. | Maintenir l’accélérateur pendant le décompte. Vérifier que la voiture et le chrono restent à l’arrêt jusqu’au signal. |
| CA-024 | B-03 | Un choc doit produire des effets physiques immédiats selon l’impact, tels qu’une perte de vitesse, une déviation ou une rotation. Une fois la voiture stabilisée, ses capacités mécaniques doivent être celles d’avant le choc. | Comparer l’accélération, le freinage et la réponse de la direction dans les mêmes conditions avant et après un impact. Vérifier la réaction à l’impact puis le retour aux performances initiales. |
| CA-025 | B-03 | Pendant la conduite, le jeu doit afficher la vitesse et le chrono. Le joueur doit lire les virages sur la route, sans annonce visuelle ou sonore du virage à venir. | Parcourir plusieurs virages, vérifier la lisibilité de la vitesse et du temps ainsi que l’absence d’annonce anticipée. |
| CA-031 | B-03 | L’herbe doit ralentir la voiture par rapport à l’asphalte. | À pente, vitesse d’entrée et commandes identiques, parcourir la même distance sur les deux surfaces et vérifier que le passage sur l’herbe prend plus de temps. |
| CA-032 | B-02 | La géométrie et les abords de chaque tracé doivent empêcher de gagner du temps en coupant la route. | Repérer les épingles et les portions de route proches. Pour chaque coupe possible, comparer les meilleurs passages reproductibles entre les mêmes repères, à conditions d’entrée identiques, jusqu’à un repère en aval qui tient compte de la vitesse de sortie. Si la coupe est plus rapide, corriger le tracé et refaire l’essai. |

### 3.5 Pause, abandon et résultats

| ID | Besoin | Exigence | Critère de vérification |
| --- | --- | --- | --- |
| CA-026 | B-02 | La touche `Échap` ou la perte de focus de la fenêtre doit suspendre la simulation et le chrono. | Essayer chaque déclencheur en mouvement. Après quelques secondes, reprendre et vérifier que la voiture et le chrono repartent de leur état à la mise en pause. |
| CA-027 | B-02 | Le joueur doit pouvoir abandonner et recommencer depuis la pause. | Relancer depuis la pause. Vérifier que le décompte recommence en A et que le record appartient toujours à la même tentative terminée. |
| CA-028 | B-04 | Le jeu doit sauvegarder localement le record et inscrire uniquement les courses terminées dans l’historique, avec leur date, le statut « Terminée » et le temps final. | Terminer deux courses et en abandonner une troisième. Relancer le jeu et vérifier que l’historique contient deux entrées datées avec leur statut et leur temps, et que le record est le meilleur des deux temps. |

### 3.6 Maintenabilité et extension

| ID | Besoin | Exigence | Critère de vérification |
| --- | --- | --- | --- |
| CA-029 | B-05 | L’architecture doit isoler la définition des véhicules et des tracés des règles de chronométrage et de classement. | Lors d’un essai de développement, intégrer un véhicule puis un tracé de test par les points d’extension documentés. Rejouer les vérifications du chronométrage et du record avec les mêmes règles. |

### 3.7 Performance en course

| ID | Besoin | Exigence | Critère de vérification |
| --- | --- | --- | --- |
| CA-030 | B-01 | Sous Windows 11, le jeu doit maintenir 60 images/s en 1920 × 1080 avec les réglages bas sur la GeForce GT 740 de recette. De rares dépassements du budget de 16,67 ms par image sont admis. | Sur un trajet complet sans pause, relever la cadence moyenne, la proportion d’intervalles de rendu dépassant 16,67 ms et le plus long intervalle. Consigner la version du jeu, le pilote et la configuration utilisée. |

### Choix de la carte de recette

La carte retenue est la **MSI GeForce GT 740 N740-2GD3, 2 Go DDR3**. Cette référence précise la variante mémoire pour reproduire l’essai. NVIDIA a publié un pilote Windows 11 pour la GT 740. [Fiche MSI](https://www.msi.com/Graphics-Card/N740-2GD3/Specification) · [Pilote NVIDIA](https://www.nvidia.com/en-us/geforce/drivers/details/228836/)

Les moyennes G3D Mark consultées sont de 1 416 points pour la famille GT 740 et de 1 585 pour la Quadro K2000, soit environ 11 % de moins. Ce résultat synthétique motive le choix de la carte. La cadence effective devra être mesurée sur le jeu. [PassMark GT 740](https://www.videocardbenchmark.net/gpu.php?gpu=GeForce+GT+740&id=2883) · [PassMark Quadro K2000](https://www.videocardbenchmark.net/gpu.php?gpu=Quadro+K2000&id=2446)

## 4. Points à vérifier sur le prototype

- Régler et essayer sur une épingle le freinage, la perte d’adhérence, sa récupération au clavier et l’effet de l’herbe.
- Pour quantifier les dépassements « rares » de CA-030, le seuil proposé est d’au moins 99 % des intervalles de rendu à 16,67 ms ou moins sur un trajet complet. Confirmer ce seuil avec les premières mesures et examiner les saccades les plus longues.

Les dégâts mécaniques persistants sont reportés à une version ultérieure.
