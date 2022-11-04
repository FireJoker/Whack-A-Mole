# Whack-A-Mole
This is a course project, a whack-a-mole game, written in assembly language.
The code is running on the Discovery kit with STM32F100RB MCU.

## How to play
1. Load files to the STM32VLDISCOVERY board.
2. Press the reset button (black pushbutton on the board) to start the program, you will see an LED pattern after resetting the game.
3. Press any pushbutton (red, black, blue, green) to start the game.
4. The user will have around 3 seconds (by default, change the difficulty by changing ReactTime) to press the right pushbutton in order to go to the next level.
5. The user has lost the game. By pressing the wrong color pushbutton or running out of time. The LED will show the current level you failed. Press any pushbutton or wait for 10 seconds to restart the game.
6. The user has won the game. After pressing the right pushbutton 15 times (by default, based on NumCycles), a different LED pattern will show. Press any pushbutton or wait for one minute to restart the game.
7. Repeat steps 3 to 6 to restart the game.

## How to adjust the game parameters
1.PrelimWait: The time waits for lighting a LED before every cycle, about half a second (it is better not to change).
2.LevelUp: The time reduction the ReactTime after every cycle (The larger the number, the more complex the game).
3.ReactTime: The time allowed the user to press the correct button to avoid terminating the game (at least 20 times of LevelUp. The larger the number, the easier the game). 
4.NumCycles: The number of cycles in a game (from 1 to 15).
5.WinningSignalTime: The time for controlling the frequency of the LEDs during the winning signal is on.
6.LosingSignalTime: The time for controlling the frequency of the LEDs while the losing signal is on.
7.DT_1_MIN: The time to wait for a restart during the winning signal is on.
8.DT_10_SEC: The time to wait for a restart during a losing signal is on.