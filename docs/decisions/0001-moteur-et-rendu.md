# ADR 0001 — Moteur et rendu du prototype Windows

| Champ | Valeur |
| --- | --- |
| Date | 21 novembre 2026 |
| Décision | Godot 4.7.2 standard, GDScript, export Windows x86-64, rendu Compatibility avec le pilote OpenGL |
| Portée | Prototype de faisabilité de Corsa Alta |
| Exigences | CA-001, CA-007, CA-014, CA-029, CA-030 et CA-031 de la [spécification v0.4](../../GAME_DESIGN.md) |

## Justification

La Quadro K2000 du joueur et la MSI GT 740 de recette disposent chacune de 2 Go de mémoire vidéo et annoncent OpenGL 4.4. Le mode Compatibility de Godot demande OpenGL 3.3. L’édition standard permet de produire un exécutable Windows autonome. La version du moteur est fixée pour pouvoir comparer deux essais avec la même chaîne d’export. [Prérequis Godot](https://docs.godotengine.org/en/4.7/about/system_requirements.html) · [Distribution Windows](https://godotengine.org/download/archive/4.7.2-stable/) · [Fiche NVIDIA](https://www.nvidia.com/content/PDF/data-sheet/nv-ds-quadro-k2000-us.pdf) · [Fiche MSI](https://www.msi.com/Graphics-Card/N740-2GD3/Specification)

La scène d’essai utilise des matériaux opaques, une lumière directionnelle et un décor géométrique simple. Le script du véhicule applique le braquage progressif, une limite d’adhérence latérale et une résistance au roulement propre à chaque surface. Le tracé fournit la géométrie de la route et la position de l’arrivée. La session gère le départ, le chrono, la pause et le résultat.

## Essai de conduite

Le parcours d’environ 280 m comporte une ligne droite de 110 m, une épingle de rayon 19 m et une ligne d’arrivée sur le brin de retour. Une première tentative permet de repérer le virage. À la suivante, déplacer son point de freinage pour observer l’élargissement de la trajectoire. Refaire l’essai avec deux roues puis toute la voiture sur l’herbe pour apprécier le réglage simplifié de surface, déterminé au centre du véhicule.

Utiliser Entrée pour partir, Z pour accélérer, S pour freiner et Q/D pour tourner. À l’arrêt, relâcher S puis appuyer de nouveau pour reculer. Échap donne accès à la pause et R relance l’essai depuis la pause. F10 quitte le jeu.

## Reproduire les vérifications

Depuis la racine du dépôt, avec Godot 4.7.2 et ses modèles d’export de la même version, utiliser le binaire console sous le nom `godot` dans PowerShell.

```powershell
godot --headless --path prototype --import
godot --headless --path prototype --fixed-fps 60 --script ../verification/essai_conduite.gd
New-Item -ItemType Directory -Force build | Out-Null
godot --headless --path prototype --export-release "Windows Desktop"
.\build\CorsaAlta.exe
```

Pour isoler le rendu, le mode de mesure déplace la voiture le long de l’axe de la route à une vitesse reproductible avec la caméra arrière. Après trois secondes de chauffe, il relève pendant 24 secondes les intervalles réels entre appels de rendu, synchronisation verticale désactivée. Le journal donne le GPU effectivement utilisé, la résolution de fenêtre, la cadence moyenne, la part des intervalles dans le budget et l’intervalle maximal.

```powershell
Start-Process .\build\CorsaAlta.exe -WorkingDirectory (Resolve-Path build) -ArgumentList '--log-file','bench-gpu.log','--','--mesure' -Wait
Get-Content .\build\bench-gpu.log
```

### Résultat local du 21 novembre 2026

L’exécutable exporté avec Godot 4.7.2 (ed1daf0bf) a démarré en OpenGL 3.3 Compatibility sur la Quadro K2000. Le pilote a annoncé la version NVIDIA 353.30. À 1920 × 1080, le passage automatique a mesuré 7 647 intervalles en 24 secondes, soit **318,6 images/s en moyenne**, 100 % des intervalles à 16,67 ms ou moins et **7,39 ms au maximum**. La mesure porte sur la boucle de rendu de la scène courte, à cadence libre, sur le PC de développement.

L’essai automatique des commandes a exercé le départ, l’accélération, les deux directions, la pause, le freinage, la marche arrière, l’herbe, l’arrivée et le redémarrage. Le réglage de la conduite requiert un essai au clavier par le joueur. La recette de CA-030 portera sur un trajet complet de 3 à 5 minutes, avec la GT 740 de référence et un relevé des présentations d’images à l’écran.

Le prototype utilise [Godot Engine sous licence MIT](https://godotengine.org/license/).
