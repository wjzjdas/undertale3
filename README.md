# undertale3
Undertale 3 is a thrilling, 2D RPG-style adventure where the player, represented by a red heart, faces off against the formidable boss, Brother Ma. To emerge victorious, you’ll dodge a relentless onslaught of bullets, traps, and unique attacks inside a three-by-three grid arena. Each second is crucial, as Brother Ma’s health bar gradually depletes over time—yet to win, you’ll need to survive the countdown before losing all three of your lifes.

# How to Use
## 1. Creation of .mif files (If you wish to modify this project)
.mif file (in this project, specifically image.colour.mif) is used to generate the background (start screen) on the VGA screen. To convert your image into .mif files, refer to this project: [imgtomif](https://github.com/stefanstancu/imgtomif)
## 2. Environment Setup
Our project is originally compiled on quartus prime, the top file being undertale3.v. 
<br>
Display: 160 X 120 VGA screen. 
<br>
Board: Altera Cyclone V DE1-SoC
## 3. How to play: 
1) Make sure keyboard, VGA Display is properly connected to board
2) On the start screen: Push SW5+SW6 up, then push SW6 down (leaving SW5 up)
3) Use WSAD to control the player
