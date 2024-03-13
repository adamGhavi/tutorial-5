## Preface
For this tutorial, I implemented a character using the Soldier spritesheet and gave it basic platformer controls.

## Added mechanics:
### 1. Double-Jump
The player is able to jump mid-air.

### 2. Better-Jump
The player is able to adjust their jump-arc by how long the jump button is held down. This mechanic gives the player a finer locus of control and a more precise platforming experience. One classic example of this mechanic's implementation is the original NES Super Mario Bros. Incidentally, there is no actual name for this mechanic. "Better-jump" is just what I personally refer to it as, because I originally found the technique from a Unity tutorial calling it such.

### 3. Slide
The player is able to perform a tactical slide which effectively functions as a dash mechanic.

### 4. Crouch
This mechanic is purely aesthetic, allowing the player to alter the character's sprite to the crouching position if the "down" button is held.

### 5. Acceleration & Deceleration
For a more refined movement system, I added subtle acceleration and deceleration to the player character's horizontal movement. I also decided to distinguish the acceleration experienced on-ground and mid-air, making the latter less easy to control as to add a trade-off to jumping and deepen the movement mechanics.

### 6. State Machine Implementation
To keep my code tidy, I decided to implement the player's movement as separate states, with an enum denoting each one.
