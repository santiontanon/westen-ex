## Westen House EX (MSX)

Code / Graphics: Santiago Ontañón
Music / SFX: Gryzor87
Cover / Box Art: Sirelion
Physical edition support: Pablibiris, Manuel Pazos
Beta testing: Jordi Sureda, Araubi, Manuel Pazos



Download latest compiled ROM from: ...

You will need an MSX emulator to play the game on a PC, for example OpenMSX: http://openmsx.org

<img src="https://github.com/santiontanon/westen-ex/blob/main/media/Portada-small.png?raw=true" alt="cover" width="600"/>


## Introduction

Westen House EX is an MSX1 game, in a 128KB ROM cartridge format. The game is an extended version of the original Westen House (https://github.com/santiontanon/westen), with a completed storyline, which should hopefully give you some extra hours of fun exploration. You can play in either 50Hz or 60Hz machines, but the game is a bit more enjoyable in 60Hz machines, as the player walks a bit faster. This extended version features amazing music by Gryzor87, and was originally distributed as a physical edition thanks to the beautiful art by Sirelion (see cover above). 

Westen House EX is an isometric adventure that has the goal of exploring the possibility of creating an isometric game for MSX1 that exploits hardware sprites to increase the colorfulness of the game. I grew up playing classics like Batman and Head over Heels, which were my favorite isometric games, and I have been wanting to make an isometric game for a very long time. I hope you  enjoy the game and the story!


## Screenshots

Screenshots:

<img src="https://github.com/santiontanon/westen-ex/blob/main/media/ss1.png?raw=true" alt="title" width="400"/> <img src="https://github.com/santiontanon/westen-ex/blob/main/media/ss2.png?raw=true" alt="in game 1" width="400"/>

<img src="https://github.com/santiontanon/westen-ex/blob/main/media/ss4.png?raw=true" alt="in game 2" width="400"/> <img src="https://github.com/santiontanon/westen-ex/blob/main/media/ss5.png?raw=true" alt="in game 3" width="400"/>



### Game Goal

You play as Professor Edward Kelvin, who has been asked to collect the research notes of his deceased colleague Jonathan Westen before Jonathan's family comes to take possession of the house. What Edward cannot imagine is that this seemingly inocent task might turn into one of his biggest adventures!


## Compatibility

The game was designed to be played on MSX1 computers with at least 16KB of RAM. I used OpenMSX v0.16 to make sure the game is compatible with lots of MSX models, but if you detect an incompatibility, please let me know!


## Notes:

Some notes and useful links I used when coding Westen House

* There is a "build" script in the home folder. Use it to re-build the game from sources. There is a collection of data files that are generated via a collection of Java scripts. Those are found in the "java" folder. You can re-generate all the data files by running the "Main.java" class (some of them take quite some time to run, so be patient! Also, you will need zx0 ( https://github.com/einar-saukas/ZX0 ) compiled for your operative system (not included) inside of the java folder as well). Also, notice newer versions of zx0 (after v2.0) have changed the data format, which will break the game. Use the ```-c``` flag with zx0 if you are using a newer version of zx0 (see the discussion here: https://msx.org/forum/msx-talk/software/my-latest-msx-game-westen-house?page=15 )
* I used my own MDL Z80 code optimizer to both assemble the game and to help me save a few bytes/cycles here and there: https://github.com/santiontanon/mdlz80optimizer
* PSG (sound) registers: http://www.angelfire.com/art2/unicorndreams/msx/RR-PSG.html
* Z80 user manual: http://www.zilog.com/appnotes_download.php?FromPage=DirectLink&dn=UM0080&ft=User%20Manual&f=YUhSMGNEb3ZMM2QzZHk1NmFXeHZaeTVqYjIwdlpHOWpjeTk2T0RBdlZVMHdNRGd3TG5Ca1pnPT0=
* MSX system variables: http://map.grauw.nl/resources/msxsystemvars.php
* MSX bios calls: 
    * http://map.grauw.nl/resources/msxbios.php
    * https://sourceforge.net/p/cbios/cbios/ci/master/tree/
* VDP reference: http://bifi.msxnet.org/msxnet/tech/tms9918a.txt
* VDP manual: http://map.grauw.nl/resources/video/texasinstruments_tms9918.pdf
* In order to compress data I used ZX0: https://github.com/einar-saukas/ZX0
