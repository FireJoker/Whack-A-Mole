# Whack-A-Mole
This is a course project, a whack-a-mole game, written in assembly language.</br>
The code is running on the Discovery kit with STM32F100RB MCU.</br>
![STM32VLDISCOVERY board](https://user-images.githubusercontent.com/45953972/200090501-a1e636fb-3a8e-4fe0-a0ca-52ac999f9c47.jpg)

## How to play
- Load files to the STM32VLDISCOVERY board.
- Press the reset button (black pushbutton on the board) to start the program, you will see an LED pattern after resetting the game.
- Press any pushbutton (red, black, blue, green) to start the game.
- The user will have around 3 seconds (by default, change the difficulty by changing ReactTime) to press the right pushbutton in order to go to the next level.
- The user has lost the game. By pressing the wrong color pushbutton or running out of time. The LED will show the current level you failed. Press any pushbutton or wait for 10 seconds to restart the game.
- The user has won the game. After pressing the right pushbutton 15 times (by default, based on NumCycles), a different LED pattern will show. Press any pushbutton or wait for one minute to restart the game.
- Repeat steps 3 to 6 to restart the game.

## How to adjust the game parameters
- PrelimWait: The time waits for lighting a LED before every cycle, about half a second (it is better not to change).
- LevelUp: The time reduction the ReactTime after every cycle (The larger the number, the more complex the game).
- ReactTime: The time allowed the user to press the correct button to avoid terminating the game (at least 20 times of LevelUp. The larger the number, the easier the game). 
- NumCycles: The number of cycles in a game (from 1 to 15).
- WinningSignalTime: The time for controlling the frequency of the LEDs during the winning signal is on.
- LosingSignalTime: The time for controlling the frequency of the LEDs while the losing signal is on.
- DT_1_MIN: The time to wait for a restart during the winning signal is on.
- DT_10_SEC: The time to wait for a restart during a losing signal is on.
