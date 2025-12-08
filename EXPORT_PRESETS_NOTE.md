# Export Presets Migration for Godot 4.x

## Important Note

The `export_presets.cfg` file from Godot 3.x is **not compatible** with Godot 4.x. You will need to recreate your export presets in the Godot 4 editor.

## Export Templates

The existing presets were for:
1. **Android** - Mobile build
2. **Linux/X11** - Desktop Linux
3. **HTML5** - Web export (now called "Web" in Godot 4)

## How to Recreate Export Presets

1. Open the project in Godot 4 editor
2. Go to `Project → Export...`
3. Click "Add..." to add a new preset
4. Select your target platform

### Android Export Preset

Key settings to configure:
- **Package Name**: `org.godotengine.miffangryaliens` (or your custom package name)
- **Version Code**: 1
- **Version Name**: 1.0
- **Min SDK**: 21 (Android 5.0)
- **Target SDK**: 33 (Android 13)
- **Architectures**: Enable arm64-v8a and armeabi-v7a
- **Screen Orientation**: Sensor Landscape (for best mobile experience)
- **Permissions**: Only enable what you need (none required for this game)
- **Keystore**: Configure for release builds

#### Mobile-Specific Settings
- **Immersive Mode**: true (full-screen experience)
- **Support Tablet**: true
- **OpenGL Version**: GLES3 or Vulkan Mobile

### Linux/X11 Export Preset

Key settings:
- **64-bit**: true
- **Embed PCK**: false (keep separate for easier updates)
- **Runnable**: true

### Web Export Preset

In Godot 4, HTML5 export is now called "Web":
- **VRAM Texture Compression**: For Desktop
- **Thread Support**: true (if supported by your target browsers)
- **Export Type**: Regular
- **Custom HTML Shell**: (optional, for custom branding)

## Mobile Testing

Before deploying to mobile:

1. **Test on Desktop First**
   - Use the "Remote Debug" option
   - Enable "Emulate Touch from Mouse" in Project Settings

2. **Deploy to Device**
   - Connect Android device via USB
   - Enable USB Debugging on device
   - Use "One-Click Deploy" in Godot editor

3. **Performance Testing**
   - Monitor FPS with the built-in profiler
   - Test on lower-end devices if possible
   - Check memory usage

## Graphics Settings for Mobile

Make sure these are set in Project Settings:
- **Rendering/Renderer**: gl_compatibility (for widest compatibility)
- **Rendering/Textures/VRAM Compression**: Import ETC2 ASTC
- **Display/Window/Stretch/Mode**: 2d
- **Display/Window/Stretch/Aspect**: expand

## Build Commands (for CI/CD)

Once presets are configured, you can export from command line:

```bash
# Android
godot4 --headless --export-release "Android" builds/game.apk

# Linux
godot4 --headless --export-release "Linux/X11" builds/game.x86_64

# Web
godot4 --headless --export-release "Web" builds/index.html
```

## Signing Android Builds

For release builds, you'll need to configure a keystore:

1. Generate keystore:
   ```bash
   keytool -genkey -v -keystore release.keystore -alias mygame -keyalg RSA -keysize 2048 -validity 10000
   ```

2. Configure in export preset:
   - Keystore Path: path/to/release.keystore
   - Keystore User: mygame (your alias)
   - Keystore Password: (your password)

## Additional Resources

- [Godot 4 Export Documentation](https://docs.godotengine.org/en/stable/tutorials/export/index.html)
- [Android Export Guide](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html)
- [Web Export Guide](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html)
