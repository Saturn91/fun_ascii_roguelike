# ASCII Roguelike - Love2D

A classic ASCII-style roguelike game built with Love2D (LÖVE).

## Font Recommendations

For the best ASCII roguelike experience, consider using one of these fonts:

### Best Options for Authentic Feel:
1. **CP437 (Codepage 437)** - The original IBM PC font
2. **Perfect DOS VGA 437** - Authentic DOS-era bitmap font
3. **MS DOS Font** - Classic DOS appearance

### Modern Alternatives:
1. **Iosevka** - Modern monospace with excellent ASCII support
2. **Source Code Pro** - Clean and readable
3. **Fira Code** - Great monospace option
4. **JetBrains Mono** - Designed for developers
5. **Terminus** - Bitmap font for pixel-perfect display

## Font Installation

✅ **White Rabbit Font Installed!**
The classic "White Rabbit" font by Matthew Welch is now installed in your project at:
`assets/fonts/whitrabt.ttf`

This font is perfect for ASCII roguelikes with its clean, monospace design that makes ASCII art look crisp and authentic.

### If you want to use a different font:
1. Download your preferred font (TTF or OTF format)
2. Place the font file in `assets/fonts/`
3. Update the font path in `main.lua`:
   ```lua
   local fontPath = "assets/fonts/your-font-name.ttf"
   ```

## Where to Get Fonts

### Free Options:
- **Google Fonts**: Source Code Pro, JetBrains Mono
- **The Ultimate Oldschool PC Font Pack**: Perfect DOS VGA 437, More Perfect DOS VGA 437
- **Iosevka**: Available on GitHub
- **GNU FreeFont**: FreeMono

### Font Websites:
- [The Ultimate Oldschool PC Font Pack](https://int10h.org/oldschool-pc-fonts/)
- [Google Fonts](https://fonts.google.com/)
- [Iosevka GitHub](https://github.com/be5invis/Iosevka)

## Running the Game

1. Install Love2D from [love2d.org](https://love2d.org/)
2. Either:
   - Drag the game folder onto the Love2D executable
   - Or run from command line: `love .` (in the game directory)

## Controls

- **Arrow Keys** or **WASD**: Move player
- **Escape**: Quit game

## Current Features

- ✅ Basic ASCII grid rendering with White Rabbit font
- ✅ Player movement (@) with collision detection
- ✅ **Walls and rooms system**
- ✅ **Multiple interconnected rooms with corridors**
- ✅ **ASCII-based UI system with dedicated panel**
- ✅ **In-game logger with timestamps**
- ✅ **Real-time player info display**
- ✅ **Modular code structure (Room + Player + UI modules)**
- ✅ Grid-based movement system constrained to game area

## Code Structure

```
fun_ascii_roguelike/
├── main.lua           # Main game loop and Love2D functions
├── conf.lua           # Love2D configuration
├── game/
│   ├── room.lua       # Room generation and layout functions
│   ├── player.lua     # Player creation and movement logic
│   └── ui.lua         # UI system and logger
└── assets/
    └── fonts/
        └── whitrabt.ttf # White Rabbit font
```

## UI System

The game now features a dedicated ASCII UI panel on the right side (25% of screen width):

### **Logger Panel** (Top Right)
- Timestamped messages replace console output
- Scrolling message history (20 messages max)
- Game events and player actions logged in real-time

### **Info Panel** (Bottom Right)
- Real-time player position
- Control instructions
- Game status information

### **Visual Elements**
- ASCII borders (`|`, `-`, `+`) separate game area from UI
- **Clean black background** in UI areas for better readability
- Color-coded sections for easy reading
- All UI elements rendered using ASCII characters
- No visual clutter - only relevant UI elements are drawn

## Next Steps

- [ ] Implement enemies
- [ ] Add items and inventory
- [ ] Create procedural dungeon generation
- [ ] Add combat system
- [ ] Implement line of sight/fog of war

## Font Configuration

The game automatically calculates character dimensions and adjusts the grid size based on your chosen font. The current setup supports:

- Fallback font system (custom → default monospace → system)
- Automatic grid sizing based on character dimensions
- Consistent character spacing for perfect ASCII alignment

Recommended font size: 14-18px for best readability.
