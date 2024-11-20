# undertale3
Undertale 3 is a thrilling, 2D RPG-style adventure developed for FPGA and VGA Display. The player, represented by a red heart, faces off against the formidable boss, Brother Ma. To emerge victorious, you’ll dodge a relentless onslaught of bullets, traps, and unique attacks inside a three-by-three grid arena. Each second is crucial, as Brother Ma’s health bar gradually depletes over time—yet to win, you’ll need to survive the countdown before losing all three of your lifes.

# How to Use
## 1. Creation of .mif files (If you wish to modify this project)
.mif file (in this project, specifically image.colour.mif) is used to generate the background (start screen) on the VGA screen. To convert your image into .mif files, refer to this project: [imgtomif](https://github.com/stefanstancu/imgtomif)
## 2. Environment Setup
Our project is originally compiled on quartus prime, the top file being undertale3.v. 
<br>
Display: 160 X 120 VGA screen. 
<br>
FPGA Board: Altera Cyclone V Soc FPGA DE1-SoC
### Notes Regarding Setup in Quartus Prime (Skip if you're familiar with this or different environment)
If you wish to modify this project, then here are some setup tips. Otherwise you can just use the output files we have.
<br>
Inside the program, go to __Assignments -> Settings__, make sure: 
1) __General -> Top-level entity__ is set to __undertale3__
2) __Libraries -> Project libraries__ includes __/undertale3/vga_adapter__
3) __Files -> Files__ includes all verilog (.v) files in this project
4) Don't forget to Import Pin Assignments for your FPGA board(For instanced we used DE1_SoC.qsf)
## 3. How to play: 
1) Make sure keyboard, VGA Display is properly connected to board
2) On the start screen: Push SW5+SW6 up, then push SW6 down (leaving SW5 up)
3) Use WSAD to control the player
