Schwerkraft

Hey everyone, I'm Aahil, and this is a 3D parkour game I've been building in Godot.

I was messing around with a few different mechanics and ended up focusing entirely on movement and physics. The main gimmick of this game is that you can actually control gravity. If a gap is way too far to jump across normally, you don't just fall—you can flip gravity to the side and run along the wall, or fall upwards and walk on the ceiling to get around obstacles.
What's currently in the game:

    Gravity shifting: You can change the pull of gravity to go up, down, left, or right to solve the platforming puzzles.

    Level progression: I built a custom Finish Zone using Area3D. Once you reach the end of a stage, a "LEVEL COMPLETE" screen pops up, it pauses for a couple of seconds so you can actually enjoy the win, and then automatically loads the next level.

    Custom platforms: Different blocks do different things. For example, the green ones are bouncy and will launch you in the air.

    Clean camera controls: Pressing Left Ctrl locks the mouse to your camera so you can actually look around, and Esc frees it up if you need to click off the screen.

Controls

    W, A, S, D - Move around

    Spacebar - Jump

    Arrow Keys - Change the direction of gravity

    Left Ctrl - Lock mouse to game

    Esc - Unlock mouse

Running the project

If you want to poke around the source code or make your own levels, you'll need Godot 4.6.

Just clone the repo, open Godot, and import the project.godot file. To play, open level_1.tscn and hit F5.

If you want to build your own levels, just duplicate one of my level files. I set up the FinishZone node to be completely modular—just drag it to the end of your new level, click it, and assign the path for your next level in the Inspector so the game knows where to send the player next.
