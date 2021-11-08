# MIPS-BomberMap
A MIPS assembly version of the popular game "Bomber Man".
> [Short Demo](https://youtu.be/DhHCndkfiD8)

## Usage
* You will need to download [this](https://jarrettbillingsley.github.io/teaching/classes/cs0447/software/Mars_2211_0822.jar) modified version of the MARS MIPS simulator. [Here](https://jarrettbillingsley.github.io/teaching/classes/cs0447/software.html) is the list of changes.
* Clone the repository to your machine. Open `main.asm`.
* Make sure `Settings->Assemble all files in directory` is enabled. Click on ![Screen Shot 2021-11-07 at 11 19 01 PM](https://user-images.githubusercontent.com/71403728/140683759-b142dc00-ef92-4f5f-a6ff-72555310c210.png) to assemble the program.
* Click on `Tools->Keypad and LED Display Simulator`. Click the `Connect to MIPS` button. 
* Run the program by clicking ![Screen Shot 2021-11-07 at 11 21 53 PM](https://user-images.githubusercontent.com/71403728/140683946-3c67985c-e6de-4758-b9cd-fc4edfc2e511.png).

---
## Controls
* Press `C` to start the game
* At any point, press `X` to quit the game. Reassemble and run to play again.
* Use the arrow keys to move the character around. Press `B` to drop a bomb at your current location.
* The bomb will explode after a short delay for 3 blocks in 4 directions (N,S,E,W). There is a short cooldown between bomb placements. If you get hit by the explosion, you lose. If you touch an enemy, you lose. If you hit all three enemies, you win. If the yellow/orange blocks are hit by a an explosion, they will be destroyed, and will stop the propagation of the explosion. Pink/purple blocks will stop the propagation of an explosion, but are indestructible.
