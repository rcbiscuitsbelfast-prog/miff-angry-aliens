
# Angry Aliens (Miff Angry Aliens - Toppler Edition)

![optimized](https://user-images.githubusercontent.com/6860637/79353473-60ad7580-7f3b-11ea-8bc7-411bab23032e.gif)

> **Note**: This project has been migrated to **Godot 4.x** with enhanced mobile support and new features.

**Angry Aliens** is an open source game originally made with Godot Engine 3.2.1, now updated to Godot 4.x.

This fork includes the "Toppler" game mode - a unique blend of destruction and platforming gameplay.

Source code is MIT licensed. Feel free to read it, modify it and reuse it in your projects.

Gameplay is inspired by *Angry Birds* with platforming elements.

## 🎮 What's New in Toppler Edition

### Face Projectile System
- Launch your custom face as a projectile
- Realistic squash/stretch physics on impact
- Face capture and customization

### Traversal Platformer
- Play as a stick figure clone
- Platform across destroyed rubble
- Climb and traverse destruction

### Room-Based Progression
- Multiple themed rooms (Cafeteria, Office, etc.)
- Destructible props with multi-stage damage
- Exit doors that unlock after destruction

### Customization
- Face capture with point detection
- Cosmetic system (hats, glasses, wigs, moustaches)
- Emotion system for expressions

## 🚀 Getting Started

### Prerequisites

- **Godot 4.x** (download from [godotengine.org](https://godotengine.org/))
- Basic understanding of Godot Engine
- For mobile development:
  - Android SDK (for Android builds)
  - Connected Android device or emulator

### Opening the Project

1. Clone this repository
2. Open Godot 4.x
3. Click "Import"
4. Navigate to the project folder and select `project.godot`
5. Let Godot convert any remaining scene files
6. Click "Import & Edit"

### First Run

1. Press F5 or click the Play button
2. The main menu should load
3. Test the customization features
4. Start playing in a room

## 📱 Mobile Support

This project is optimized for mobile devices with:
- Touch input for slingshot mechanics
- Responsive UI scaling
- Performance optimizations
- GL Compatibility renderer for wide device support

### Testing on Mobile

1. Enable USB debugging on your Android device
2. Connect device via USB
3. In Godot, go to Project → Export
4. Create/configure Android export preset
5. Click "Export & Run"

For detailed mobile setup, see [EXPORT_PRESETS_NOTE.md](EXPORT_PRESETS_NOTE.md)

## 🔧 Migration from Godot 3.2.x to 4.x

This project has been fully migrated from Godot 3.2.x to 4.x. Key changes include:

- GDScript syntax updates (@export, @onready, signals)
- CharacterBody2D migration
- New Tween API
- Texture2D updates
- Mobile optimization

For complete migration details, see [MIGRATION_NOTES.md](MIGRATION_NOTES.md)

## 📖 Documentation

- **[QUICK_START.md](QUICK_START.md)** - Get up and running quickly
- **[QUICK_ROOM_CREATION.md](QUICK_ROOM_CREATION.md)** - Create custom rooms
- **[TESTING_GUIDE.md](TESTING_GUIDE.md)** - Comprehensive testing documentation
- **[TESTING_CHECKLIST.md](TESTING_CHECKLIST.md)** - Migration testing checklist
- **[PHASE3_FEATURES_GUIDE.md](PHASE3_FEATURES_GUIDE.md)** - Advanced features guide
- **[SOUND_INTEGRATION_GUIDE.md](SOUND_INTEGRATION_GUIDE.md)** - Audio setup guide

## 🎯 Game Architecture

### Core Systems

1. **FaceProjectile** - Player-customized projectile with physics
2. **DestructibleProp** - Multi-stage destructible objects
3. **RubbleChunk** - Walkable debris from destruction
4. **StickClone** - Platformer character for traversal
5. **RoomBase** - Modular room system
6. **RageSystem** - Combo and scoring system

### Project Structure

```
├── Assets/          # Graphics, audio, and other assets
├── Globals/         # Autoload singletons
├── Objects/         # Reusable game objects
├── Scenes/          # Game scenes and levels
└── Documentation/   # Guides and documentation
```

## 🧪 Testing

Before building for production:

1. Run through [TESTING_CHECKLIST.md](TESTING_CHECKLIST.md)
2. Test on multiple devices
3. Verify touch input works correctly
4. Check performance metrics

## 🎨 Credits

### Original Angry Aliens
- **Kenney** for most game assets - https://www.kenney.nl/
- **Hanabi** for slingshot sprites
- **Crystal Bit** for original project and tutorials

### Toppler Edition
- Enhanced gameplay mechanics
- Face capture and customization system
- Room-based progression
- Platforming integration

## 📜 License

MIT License - See LICENSE.md for details

## 🙏 Thanks

- Crystal Bit community for the original project
- Gameloop.it community for the Harvard CS50 gamedev course
- [YouAreUto](http://youareuto.com/) game & team
- [Godot Engine Italia](https://godotengineitalia.com/)
- Godot Engine contributors

## 🐛 Known Issues

- Scene files may need one-time conversion in Godot 4 editor
- Export presets need to be recreated for Godot 4
- Some animations may need fine-tuning after migration

## 🤝 Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues.

Areas where help is appreciated:
- iOS/macOS testing and support
- Additional room designs
- Performance optimizations
- Bug fixes
- Documentation improvements

## 📞 Support

For issues related to:
- **Migration**: See [MIGRATION_NOTES.md](MIGRATION_NOTES.md)
- **Gameplay**: See [QUICK_START.md](QUICK_START.md)
- **Mobile**: See [EXPORT_PRESETS_NOTE.md](EXPORT_PRESETS_NOTE.md)
- **Testing**: See [TESTING_CHECKLIST.md](TESTING_CHECKLIST.md)

## Original Tutorial Series

The original Godot 3.2 version included video tutorials in Italian:
- [YouTube Playlist](https://www.youtube.com/playlist?list=PLaCq3HqKQR6rNyqulBsbca-6wzxp8H52r)

Note: These tutorials are for Godot 3.2 and may need adaptation for Godot 4.x

## Version History

- **v1.0** - Original Godot 3.2.1 release
- **v2.0** - Toppler Edition with enhanced features
- **v3.0** - Migration to Godot 4.x with mobile optimization

---

Made with ❤️ using [Godot Engine](https://godotengine.org/)
