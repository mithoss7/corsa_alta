# ADR 0002 — Dynamique du véhicule sur route plane

Le premier essai au clavier a fait ressortir l’inertie à l’entrée de l’épingle. Le joueur privilégie un freinage et des trajectoires physiquement cohérents. Cette décision précise la mise en œuvre de CA-014 et CA-031. [Spécification](../../GAME_DESIGN.md)

## Décision

Le véhicule suit un modèle plan à deux essieux. Chaque essieu reçoit une force longitudinale et une force latérale qui dépend de la direction de déplacement du pneu par rapport à son orientation. Leur résultante est limitée à μ fois la charge verticale de l’essieu. Freiner et tourner sollicitent ainsi la même réserve d’adhérence. La somme des forces accélère le centre de masse suivant **F = ma**. Le moment des forces autour de ce centre détermine l’accélération en lacet suivant **M = Iα**. Le clavier règle progressivement l’angle des roues avant. [Modèle de référence à deux essieux](https://www.mathworks.com/help/driving/ref/bicyclemodel.html)

Le prototype précédent imposait la vitesse de rotation en fonction du braquage et autorisait une force latérale résiduelle au freinage maximal. Le nouveau modèle permet de vérifier séparément l’adhérence disponible et la réponse en rotation.

## Hypothèses de réglage

| Grandeur | Valeur du prototype |
| --- | --- |
| Masse et moment d’inertie en lacet | 1 200 kg et 1 950 kg·m² |
| Distance du centre de masse aux essieux avant et arrière | 1,20 m et 1,40 m |
| Coefficient d’adhérence, asphalte sec et herbe | 0,95 et 0,40 |
| Raideur de dérive, avant et arrière | 68 000 et 76 000 N/rad |

Ces paramètres décrivent une voiture fictive. La charge verticale est distribuée statiquement entre les essieux et la surface est échantillonnée au centre de la voiture. Le roulis, le transfert de charge et la suspension restent des simplifications du modèle plan. Godot traite les contacts avec les obstacles par glissement du corps cinématique.

## Vérification reproductible

Le test de conduite mesure l’arrêt depuis 80 km/h sur le plat, en ligne droite, puis compare les distances à **v²/(2μg)** avec une tolérance de 5 % pour la traînée et le pas de simulation. Les valeurs théoriques sont de 26,5 m sur asphalte et 62,9 m sur herbe. Sur une aire d’essai sèche, le test compare aussi le changement de direction du vecteur vitesse après 20 m à braquage identique, avec des entrées à 40 et 80 km/h. [Test de conduite](../../verification/essai_conduite.gd)

Sur un rayon constant de 19 m, la vitesse théorique en appui stabilisé vaut au plus **√(μgR)**, soit environ **48 km/h** sur l’asphalte du prototype. Ce repère suppose un sol horizontal et toute l’adhérence disponible pour tourner. La trajectoire choisie et un freinage en appui modifient la vitesse de passage.
