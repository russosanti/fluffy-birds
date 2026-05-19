# Fluffy Bird

A Flappy Bird-inspired game developed in Lua using LÖVE2D as part of Harvard's CS50 Game Development course.

## Overview

This project expands the classic Flappy Bird gameplay with additional mechanics and progression systems.

The main focus of the project was to practice:

- Procedural obstacle generation
- Difficulty scaling
- Collision handling
- Game state management
- UI and feedback systems
- Pause systems and audio control

## Features

### Dynamic Vertical Gaps

The vertical gap between pipes is randomly generated.

As the player progresses through the level, the gap size gradually decreases until reaching a minimum threshold, increasing the game's difficulty over time.

### Randomized Horizontal Spacing

The horizontal distance between pipes is randomized with a minimum spacing limit.

This prevents impossible or overlapping pipe generations while keeping gameplay unpredictable.

### Modified Floor Collision

Unlike the original Flappy Bird behavior, touching the floor does not instantly cause the player to lose.

This creates a slightly more forgiving gameplay experience.

### Medal System

Implemented a progression-based medal system depending on the final score.

Available medals:

- Iron
- Copper
- Bronze
- Silver
- Gold
- God

The game also displays:

- How many points were needed to earn the first medal
- Or how many points were missing to reach the next medal tier

### Pause System

Implemented a pause system directly inside `PlayState`.

Instead of creating a separate pause state, the game uses an internal pause variable to stop gameplay and music.  
For this project, this approach simplified the implementation and state management.

## Technologies

- Lua
- LÖVE2D
