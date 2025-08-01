# ASCII Roguelike in Love2D

A classic ASCII-based roguelike game built with the Love2D game engine. Features procedural room generation, modular architecture, colored text markup system, health management, enemy AI, combat mechanics, comprehensive ASCII-based UI, and a professional pause menu system.

## Features

- ✅ **Player-Editable Configurations** - Customize game balance via CSV files in appdata
- ✅ **Dynamic Configuration System** - Add new config types without code changes
- ✅ **Configuration Validation** - Comprehensive error checking with fallback to defaults
- ✅ **Integrated Font System** - No external font installation needed
- ✅ **Color Markup System** - Rich colored text with `[color]text[/color]` syntax
- ✅ **Health Management** - Visual health bar with damage/healing mechanics
- ✅ **Enemy AI System** - Multiple enemy types with different behaviors
- ✅ **Combat Mechanics** - Turn-based combat with damage and health systems
- ✅ **Pause Menu System** - In-game pause with semi-transparent overlay
- ✅ **Game Over Screen** - Statistics display with retry/quit options
- ✅ **Modular Architecture** - Clean, organized code structure
- ✅ **ASCII-based UI** - Dedicated panels for logging, controls, and status
- ✅ **Room Generation** - Procedural rooms with corridors
- ✅ **Player Movement** - Grid-based movement with collision detection
- ✅ **Real-time Logging** - Timestamped game events with color coding
- ✅ **Game State Management** - Seamless transitions between menu, gameplay, and pause

## Installation & Setup

1. **Install Love2D** from [love2d.org](https://love2d.org/)
2. **Run the game**:
   - **Windows**: Open PowerShell/Command Prompt in the game directory and run:
     ```
     & "C:\Program Files\LOVE\love.exe" .
     ```
   - **Alternative**: Drag the game folder onto the Love2D executable
   - **General**: Run `love .` if Love2D is in your system PATH

**No additional setup required!** The game comes with an integrated DejaVu Sans Mono font system.

## Controls

- **Arrow Keys** or **WASD**: Move player / Attack enemies (move into them)
- **H**: Test damage (decreases health)
- **J**: Test healing (increases health)
- **Escape**: Pause game (during gameplay) / Resume game (in pause menu) / Quit game (from main menu)

### Main Menu Controls
- **Arrow Keys** or **W/S**: Navigate menu options
- **Enter** or **Space**: Select option
- **Escape**: Quit game

### Pause Menu Controls
- **Arrow Keys** or **W/S**: Navigate menu options
- **Enter** or **Space**: Select option
- **Escape**: Resume game

### Pause Menu Options
- **Resume**: Continue exactly where you left off
- **New Game**: Start a fresh game session
- **Main Menu**: Return to the main menu
- **Close**: Quit the application

### Game Over Screen Controls
- **Arrow Keys** or **W/S**: Navigate menu options
- **Enter** or **Space**: Select option
- **Escape**: Return to main menu

### Game Over Screen Options
- **Retry**: Start a new game immediately
- **Main Menu**: Return to the main menu
- **Quit**: Exit the application

### Game Statistics
When you die, the game over screen displays:
- **Cause of death** (e.g., "Combat")
- **Enemies defeated** during the session
- **Time survived** in MM:SS format

## Color Markup System

The game features a sophisticated color markup system for enhanced visual feedback:

### Available Colors
- **Basic**: `red`, `green`, `blue`, `yellow`, `cyan`, `magenta`, `white`, `black`
- **Extended**: `orange`, `purple`, `pink`, `lime`, `brown`, `gray`, `darkgray`, `lightgray`
- **Game-specific**: `health`, `damage`, `warning`, `info`, `success`, `error`

### Usage Examples
```
[red]Damage taken![/red]
[health]Health restored[/health]
[warning]Be careful![/warning]
Welcome to the [green]ASCII Roguelike[/green]!
```

## Customizing Game Configuration

The game features a powerful **configuration system** that allows players to easily customize game balance, enemy stats, and player attributes without modifying the game code. All configuration files are stored in **CSV format** for easy editing.

### Configuration System Overview

- **📁 Location**: Configuration files are automatically created in your system's **appdata folder** under `config/`
- **📊 Format**: Human-readable **CSV files** that can be edited with any text editor or spreadsheet application
- **🔄 Auto-generation**: Default configuration files are created automatically on first game launch
- **✅ Validation**: All configuration changes are validated to ensure game stability
- **🎯 Hot-reloading**: Changes take effect the next time you start the game

### Configuration Files

#### **Player Configuration** (`player.csv`)

Controls player stats and attributes:

```csv
property,value
health,10
baseAttackDamage,2
char,@
color,yellow
```

**Editable Properties:**
- `health` - Starting player health (1-1000)
- `baseAttackDamage` - Player attack damage (1-100)
- `char` - Player character symbol (single character)
- `color` - Player color (see available colors below)

#### **Enemy Configuration** (`enemy.csv`)

Controls all enemy types and their stats:

```csv
id,char,color,health,damage,name,moveChance,aggroRange
goblin,g,green,3,1,Goblin,0.3,3
orc,O,brown,5,2,Orc,0.2,4
skeleton,s,white,2,1,Skeleton,0.4,2
```

**Editable Properties:**
- `id` - Unique enemy identifier (used internally)
- `char` - Enemy character symbol (single character)
- `color` - Enemy color (see available colors below)
- `health` - Enemy health points (1-1000)
- `damage` - Enemy attack damage (1-100)
- `name` - Display name for the enemy
- `moveChance` - Probability of movement per turn (0.0-1.0)
- `aggroRange` - Range at which enemy will chase player (1-50)

### Available Colors

All color values support these options:
- **Basic**: `red`, `green`, `blue`, `yellow`, `cyan`, `magenta`, `white`, `black`
- **Extended**: `orange`, `purple`, `pink`, `lime`, `brown`, `gray`, `darkgray`, `lightgray`
- **Game-specific**: `health`, `damage`, `warning`, `info`, `success`, `error`

### How to Customize

1. **Launch the game** - Configuration files are created automatically on first run
2. **Locate config folder** - Find the `config/` folder in your system's appdata directory:
   - **Windows**: `%APPDATA%/LOVE/fun_ascii_roguelike/config/`
   - **macOS**: `~/Library/Application Support/LOVE/fun_ascii_roguelike/config/`
   - **Linux**: `~/.local/share/love/fun_ascii_roguelike/config/`
3. **Edit files** - Open `player.csv` or `enemy.csv` with any text editor or spreadsheet application
4. **Save changes** - Save the file in CSV format
5. **Restart game** - Changes take effect on next game launch

### Example Customizations

#### **Creating a Powerful Player**
```csv
property,value
health,25
baseAttackDamage,5
char,@
color,gold
```

#### **Adding a New Enemy Type**
Add a new row to `enemy.csv`:
```csv
id,char,color,health,damage,name,moveChance,aggroRange
dragon,D,red,20,8,Dragon,0.1,6
```

#### **Making Enemies Faster**
Increase `moveChance` values:
```csv
id,char,color,health,damage,name,moveChance,aggroRange
goblin,g,green,3,1,Goblin,0.8,3
orc,O,brown,5,2,Orc,0.7,4
skeleton,s,white,2,1,Skeleton,0.9,2
```

### Configuration Validation

The system includes comprehensive validation to prevent game-breaking changes:

- **Range checking** - All numeric values are validated against safe ranges
- **Type validation** - Ensures proper data types (numbers, strings, etc.)
- **Required fields** - Verifies all essential properties are present
- **Character validation** - Ensures character symbols are single characters
- **Color validation** - Checks that color names are valid
- **Error handling** - Invalid configurations fall back to defaults with error logging

### Adding New Configuration Types

The configuration system is designed to be **easily extensible**. To add new config types:

1. **Create config module** - Add new `.lua` file in `game/config/`
2. **Define structure** - Create default configuration object
3. **Add validation** - Implement `validate(config)` function
4. **Register config** - Add entry to `configs` table in `configManager.lua`

**Example new config registration:**
```lua
WEAPONS = {
    csvName = "weapons",
    luaName = "game.config.weapons",
    isArray = true,
    idField = "id"
}
```

The system will automatically handle CSV generation, loading, saving, and validation for any new configuration type!

### Troubleshooting

**Configuration not loading?**
- Check that CSV files are properly formatted
- Ensure all required columns are present
- Verify that values are within valid ranges
- Check game log for validation error messages

**Invalid values?**
- The game will log specific validation errors
- Invalid configurations automatically fall back to safe defaults
- Fix the CSV file and restart the game

**Reset to defaults?**
- Delete the configuration files from the appdata folder
- The game will recreate them with default values on next launch

## Game Architecture

### Font System (`fonts.lua`)
- **Integrated DejaVu Sans Mono** - Bundled with game files
- **Automatic sizing** - Character dimensions calculated automatically
- **No external dependencies** - Works out of the box

### ASCII Grid System (`asciiGrid.lua`)
- **Grid initialization** - Handles window-to-grid dimension calculation
- **Cell management** - Functions for setting, getting, and checking grid cells
- **Rendering engine** - Optimized character-by-character drawing
- **Boundary checking** - Validates coordinates and walkable areas
- **Foreground layer system** - Supports overlays without modifying base grid (available for future features)
- **Modular interface** - Clean API for grid manipulation

### Color System (`Colors.lua`)
- **20+ predefined colors** - Including game-specific colors
- **Markup parser** - Processes `[color]text[/color]` syntax
- **Efficient rendering** - Character-by-character color support

### UI System (`game/ui/`)
The game features a modular UI with four main components:

#### **Title Section** (`titleSection.lua`)
- Game title and author information
- Centered display with color markup

#### **Log Panel** (`Log.lua`)
- **Colored message logging** with markup support
- **Scrolling history** (20 messages maximum)
- **Timestamped entries** for all game events
- **Word wrapping** with color preservation

#### **Controls Panel** (`controls.lua`)
- **Color-coded categories**: Movement, Actions, System
- **Dynamic display** of available controls
- **Organized sections** for easy reference

#### **Health Bar** (`healthBar.lua`)
- **ASCII visual health bar** using Unicode block characters
- **Centered over game area** with zero-padded display
- **Format**: `HP: 010/010 [██████████]`
- **Color-coded status** (green = healthy, red = critical)

### Game Logic (`game/`)

#### **Player System** (`player.lua`)
- **Grid-based movement** with collision detection
- **Combat mechanics** - Attack enemies by moving into them
- **Health management** with damage/healing mechanics
- **Colored log messages** for all player actions
- **Boundary checking** to keep player in game area

#### **Enemy System** (`enemy.lua`)
- **Multiple enemy types** - Goblins, Orcs, and Skeletons
- **Enemy management** - Creation, spawning, and lifecycle handling
- **Combat system** - Damage players when adjacent
- **Different stats** - Health, damage, movement patterns per type
- **Modular AI integration** - Uses dedicated AI module for behaviors

#### **Enemy AI System** (`enemy/ai.lua`)
- **Behavioral patterns** - Aggressive, defensive, and guard behaviors
- **Smart pathfinding** - A* approach with obstacle avoidance
- **Detection systems** - Line of sight and aggro range mechanics
- **Multiple AI types** - Different strategies per enemy type
- **Advanced behaviors** - Chase, flee, patrol, and group coordination

#### **Map Generation** (`mapGenerator.lua`)
- **Procedural room generation** - Creates non-overlapping rooms
- **Configurable parameters** - Room count, min/max sizes
- **Collision detection** - Ensures rooms don't overlap
- **Smart placement** - Automatic room positioning with buffer zones
- **Extensible design** - Ready for corridor generation and advanced features

#### **Controls System** (`controls.lua`)
- **Centralized input handling** - All keyboard controls in one module
- **Game state management** - Handles victory/defeat conditions
- **Turn-based mechanics** - Coordinates player and enemy actions
- **Modular design** - Easy to extend with new controls and features

#### **Menu System** (`menu/menu.lua`, `game/gameState.lua`)
- **Main menu interface** - Title screen with navigation options
- **Game state management** - Seamless transitions between menu, gameplay, and pause
- **Dynamic background** - Live animated world behind menu
- **Reusable components** - Modular design for future pause/options menus

#### **Pause Menu System** (`menu/pauseMenu.lua`)
- **In-game pause functionality** - Press Escape to pause during gameplay
- **Semi-transparent overlay** - Uses Love2D graphics for true transparency effect
- **Game state preservation** - Current game remains visible behind overlay
- **Menu navigation** - Resume, New Game, Main Menu, or Quit options
- **Non-destructive pausing** - Game continues exactly where you left off
- **Professional visual design** - Clean overlay with proper opacity and text rendering

#### **Game Over System** (`menu/gameOverScreen.lua`)
- **Death detection** - Automatically triggers when player health reaches zero
- **Game statistics display** - Shows enemies killed, time survived, and cause of death
- **Semi-transparent overlay** - Dark red tint for dramatic effect
- **Retry functionality** - Quick restart without returning to main menu
- **Statistics tracking** - Real-time tracking of game progress and performance
- **Professional presentation** - Clean layout with proper visual hierarchy

#### **Background Map System** (`menu/backgroundMap.lua`)
- **Animated world generation** - Procedural dungeons with moving enemies
- **Configurable opacity** - Adjustable background visibility
- **Reusable component** - Can be used in any menu (main, pause, etc.)
- **Performance optimized** - Efficient enemy movement and rendering

#### **Room System** (`room.lua`)
- **Map generator integration** - Uses procedural generation
- **Player placement** - Smart starting position selection
- **Room management** - Stores and manages generated rooms
- **Legacy compatibility** - Maintains existing interface

## Code Structure

```
fun_ascii_roguelike/
├── main.lua              # Main game loop and Love2D callbacks
├── conf.lua              # Love2D configuration settings
├── fonts.lua             # Integrated font management system
├── asciiGrid.lua         # ASCII grid rendering and management
├── Colors.lua            # Color palette and markup parser
├── LocalFileUtil.lua     # File operations for appdata storage
├── util/                 # Utility modules and helper functions
│   ├── _index.lua        # Utility module loader
│   ├── TextUtil.lua      # Text positioning and rendering utilities
│   ├── LocalFileUtil.lua # File operations and image saving utilities
│   └── CloneUtil.lua     # Deep object cloning utilities
├── sandbox/              # Security sandbox system
│   ├── Sandbox.lua       # Main sandbox initialization and restrictions
│   ├── SaveOs.lua        # OS command whitelist and protection
│   └── SaveIo.lua        # IO operation restrictions and logging
├── menu/                 # Menu system components
│   ├── menu.lua          # Main menu system
│   ├── pauseMenu.lua     # In-game pause menu system
│   ├── gameOverScreen.lua # Game over screen with statistics
│   └── backgroundMap.lua # Animated background world for menus
├── tests/                # Unit testing framework and test files
├── game/
│   ├── configManager.lua # Dynamic configuration management system
│   ├── config/           # Default configuration modules
│   │   ├── player.lua    # Default player configuration with validation
│   │   └── enemy.lua     # Default enemy configurations with validation
│   ├── dice.lua          # Dice rolling system with formula parsing
│   ├── room.lua          # Room system and player placement
│   ├── mapGenerator.lua  # Procedural dungeon generation
│   ├── player.lua        # Player creation, movement, and combat
│   ├── enemy.lua         # Enemy creation, management, and combat
│   ├── controls.lua      # Keyboard input and game controls
│   ├── gameState.lua     # Game state management (menu/playing/paused/game_over)
│   ├── enemy/
│   │   └── ai.lua        # Enemy AI behaviors and pathfinding
│   ├── ui.lua            # Main UI controller
│   └── ui/
│       ├── titleSection.lua   # Game title and info
│       ├── Log.lua         # Colored message logging
│       ├── controls.lua       # Control instructions
│       └── healthBar.lua      # ASCII health visualization
└── assets/
    └── fonts/
        └── DejaVuSansMono.ttf # Integrated monospace font
```

### Configuration System Architecture

The game features a **modular configuration system** located in `game/config/` and managed by `configManager.lua`:

#### **ConfigManager** (`game/configManager.lua`)
- **Dynamic loading** - Automatically loads and validates all configuration types
- **CSV handling** - Converts between Lua tables and human-readable CSV files
- **Validation integration** - Uses config-specific validation functions
- **Error handling** - Falls back to defaults when configurations are invalid
- **Extensible design** - Easy to add new configuration types

#### **Default Configurations** (`game/config/`)
- **player.lua** - Default player stats and validation rules
- **enemy.lua** - Default enemy configurations with comprehensive validation
- **Modular validation** - Each config includes its own `validate()` function
- **Type safety** - Ensures all configuration values are valid and within safe ranges

#### **User Configurations** (Appdata CSV Files)
- **player.csv** - User-editable player configuration
- **enemy.csv** - User-editable enemy configurations  
- **Auto-generated** - Created automatically with defaults if missing
- **Validated** - All user changes are validated against default rules

### Utility System Architecture

The game includes comprehensive utility modules for common operations:

#### **Utility Modules** (`util/`)
- **TextUtil.lua** - Text positioning, centering, and rendering utilities
- **LocalFileUtil.lua** - File operations, image saving, and appdata management
- **CloneUtil.lua** - Deep object cloning for data protection and copying
- **_index.lua** - Module loader for automatic utility imports

#### **Sandbox Security System** (`sandbox/`)
- **Sandbox.lua** - Main security initialization and global function restrictions
- **SaveOs.lua** - OS command whitelist and protection against harmful system calls
- **SaveIo.lua** - IO operation restrictions and logging for file access control
- **Extensible protection** - Modular security layers for different system access levels

## Development Features

#### **Modular Design**
- **Separation of concerns** - Each module handles specific functionality
- **Easy maintenance** - Add new features without affecting existing code
- **Reusable components** - UI modules can be easily extended
- **Clean architecture** - Logical organization across multiple directories

#### **Color-Coded Feedback**
- **Damage events** appear in red with damage markup
- **Healing events** appear in green with health markup
- **System messages** use appropriate warning/info colors
- **Enhanced readability** through consistent color usage

#### **Health System**
- **Visual health bar** with Unicode block characters
- **Zero-padded display** for consistent formatting
- **Color-coded status** indicating health condition
- **Real-time updates** as health changes

#### **Combat System**
- **Turn-based mechanics** - Player moves, then enemies act
- **Bump combat** - Attack by moving into enemies
- **Multiple enemy types** - Each with unique stats and behaviors
- **Victory/defeat conditions** - Clear objectives and game over states

#### **Game State Management**
- **Four distinct states** - Menu, Playing, Paused, and Game Over
- **Seamless transitions** - Smooth state changes without data loss
- **State preservation** - Perfect game state maintenance during pause
- **Clean separation** - Each state has dedicated rendering and input handling
- **Statistics tracking** - Real-time game performance monitoring

## Future Enhancements

- [x] ~~Enemy entities with AI behavior~~ ✅ **Implemented!**
- [x] ~~Combat mechanics with weapons/spells~~ ✅ **Basic combat implemented!**
- [x] ~~Pause menu system~~ ✅ **Professional pause menu implemented!**
- [x] ~~Game state management~~ ✅ **Complete state system implemented!**
- [x] ~~Game over screen~~ ✅ **Statistics-based game over screen implemented!**
- [x] ~~Costumizable configs~~ ✅ **config Manager which can read from costumizable files**
- [ ] Item and inventory system
- [ ] Extended procedural dungeon generation
- [ ] Advanced AI behaviors (group tactics, special abilities)
- [ ] Line of sight and fog of war
- [ ] Experience points and leveling system
- [ ] Save/load game functionality
- [ ] Sound effects and music
- [ ] Additional color themes
- [ ] Settings/options menu
- [ ] Multiple difficulty levels
- [ ] High score system

## Technical Notes

### Font Integration
The game uses an **integrated DejaVu Sans Mono font** approach, eliminating the need for:
- External font downloads
- Manual font installation
- Font fallback complexity
- Cross-platform font issues

### Color Performance
The color markup system is optimized for:
- **Real-time parsing** of markup tags
- **Efficient character rendering** with individual colors
- **Memory-conscious** color object reuse
- **Scalable markup** supporting nested and complex formatting

### Pause Menu Architecture
The pause menu system uses a **hybrid rendering approach**:
- **Love2D graphics overlay** - Semi-transparent rectangle for darkening effect
- **Direct text rendering** - Menu text drawn with Love2D's print functions
- **Non-destructive design** - Original game grid remains completely unmodified
- **True transparency** - Game state clearly visible behind overlay

### Performance Optimizations
- **Efficient grid rendering** - Only draws non-space characters
- **Smart enemy AI** - Optimized pathfinding and behavior calculations
- **Minimal memory usage** - Proper cleanup and resource management
- **Foreground layer system** - Available for future overlay features

### Love2D Configuration
- **Window title**: "ASCII Roguelike"
- **Resizable window**: Enabled for flexible gameplay
- **Console**: Disabled for release builds
- **High DPI**: Supported for modern displays

## Testing

The project includes a comprehensive unit testing framework to ensure code quality and functionality.

### Test Structure

- **Test Framework**: Custom Lua unit testing library located in `tests/unitTestLib/`
- **Test Files**: Individual test modules in `tests/unittests/tests/` covering core game functionality
- **Automated Testing**: Pre-commit hooks ensure tests pass before code changes

### Running Tests

To run the complete test suite:

```bash
lua tests/unitTestLib/main.lua
```

**Requirements**: Standard Lua interpreter (Love2D not required for tests)

### Test Coverage

The test suite includes comprehensive testing for:

- **Dice System**: Formula parsing, validation, and random roll range testing
- **Game Mechanics**: Various core game systems and utilities
- **Configuration Management**: Validation and error handling
- **Data Structures**: Array utilities and game logic components

### Test Features

- **Automated Test Discovery**: Tests are automatically found and executed
- **Detailed Reporting**: Clear pass/fail status with descriptive error messages  
- **Modular Design**: Easy to add new test files for additional functionality
- **Mock Systems**: Controlled testing environments for randomized components

### Pre-commit Testing

The repository includes Git pre-commit hooks that automatically run the test suite before allowing commits, ensuring code quality and preventing regressions.

## Contributing

This is a learning project demonstrating:
- Love2D game development patterns
- Modular Lua architecture
- ASCII art and text-based game design
- Color markup system implementation
- Integrated asset management
- Game state management systems
- Semi-transparent overlay techniques
- Professional pause menu implementation

### Project Highlights
- **Complete roguelike experience** with procedural generation
- **Professional UI systems** with colored text and visual feedback
- **Advanced enemy AI** with multiple behavior patterns
- **Clean modular architecture** enabling easy feature additions
- **Modern pause menu** with transparency effects
- **Comprehensive documentation** for learning and reference

Feel free to explore the code and adapt it for your own ASCII roguelike projects!
