<div align="center">

**[Look at common issues first](https://github.com/luclefleur/Native-Trackpad/issues).**

<img src="res/logo.png" width="256"/>

# Native Trackpad Gestures<br/>for Autodesk Fusion 360

Changes trackpad gestures in Autodesk Fusion 360 on macOS.  
Replacing Fusion's gesture recognizer with macOS native recognizer.

</div>

## Features

- Changes two finger pan gesture and adds inertia.
- Changes pinch to zoom gesture.
- Rotate is shift + two finger.
- Zoom to fit is double two finger tap.
- You can't no longer scroll in Data panel, in order to scroll hold Command key.
- Navigation with perspective camera can be very slow in certain situations,
  using orthographic camera fixes this issue.
  [Code that causes this issue](https://github.com/luclefleur/Native-Trackpad/blob/563fc1f69e3eb2f6dbee136feb9e3b52e439e907/NativeTrackpad.mm#L56).

## Links

- [Todos](https://github.com/luclefleur/Native-Trackpad/search?q=todo).
- [Issues](https://github.com/luclefleur/Native-Trackpad/issues).
- [IdeaStation](https://forums.autodesk.com/t5/ideastation-request-a-feature-or/use-native-trackpad-gesture-recognition-on-macos/idi-p/7018667).

## Installation

- [Download latest release](https://github.com/luclefleur/Native-Trackpad/releases/download/0.12/NativeTrackpad.zip).
- Unzip.
- Go to: Tools → Add-ins → Add-ins → Click ➕.
- Select unzipped folder.
- In Fusion make sure to turn on `Use gesture-based view navigation` (which is the default).

There is no special needs to configure your Trackpad in System Preferences.
What I personaly do is set Tracking speed to maximum to have panning even faster.

![manual install](res/install.png)

## Development

1. Build the add-in in xcode
2. Add the add-in at `<repo>/xcode/` to fusion360
3. The add-in dylib isn't automatically reloaded, so changes require restarting
   fusion360.
4. To enable debugging fusion360 with xcode debugger, you need to strip the
   hardened runtime code signature from the app. The actual fusion360 app that
   is codesigned is located in a non-standard directory.

  To check code signature:
   ```
   codesign -d -vvv ~/Library/ApplicationSupport/Autodesk/webdeploy/production/Autodesk\ Fusion\ 360.app
   ```

  To remove code signature:
   ```
   sudo codesign --remove-signature ~/Library/ApplicationSupport/Autodesk/webdeploy/production/Autodesk\ Fusion\ 360.app
   ```

5. Log values like so:

  ```
  std::string str = "TARGET: x: " + std::to_string(target->x()) + " y: " + std::to_string(target->y()) + " z: " + std::to_string(target->z());
  adsk::core::Application::log(str);
  ```
