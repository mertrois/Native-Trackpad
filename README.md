<div align="center">

**Plugin seems to be broken.**

**Looking for maintainers of this repository!**

<img src="res/logo.png" width="256"/>

# Native Trackpad Gestures<br/>for Autodesk Fusion 360

Changes trackpad gestures in Autodesk Fusion 360 on macOS.
Replacing Fusion's gesture recognizer with macOS native recognizer.

</div>

## Features

- Changes two finger pan gesture and adds inertia.
- Changes pinch to zoom gesture.
- Rotate view is shift + two finger.
- Zoom to fit is double two finger tap.
- You can't no longer scroll in Data panel, in order to scroll hold Command key.
- Navigation with perspective camera can be very slow in certain situations,
  using orthographic camera fixes this issue, you can check [code that causes this issue]
  (https://github.com/pravdomil/Native-Trackpad/blob/563fc1f69e3eb2f6dbee136feb9e3b52e439e907/NativeTrackpad.mm#L56)
  .

## Links

- [**How to video**](https://www.youtube.com/watch?v=7M2McvpOL90).
- [Todos](https://github.com/pravdomil/Native-Trackpad/search?q=todo).
- [Issues](https://github.com/pravdomil/Native-Trackpad/issues).
- [IdeaStation](https://forums.autodesk.com/t5/ideastation-request-a-feature-or/use-native-trackpad-gesture-recognition-on-macos/idi-p/7018667).
- [**Donate**](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=BCL2X3AFQBAP2&item_name=NativeTrackpad%20beer).

## How to Install

- [Download latest release](https://github.com/pravdomil/Native-Trackpad/releases/download/0.13/NativeTrackpad.zip).
- Unzip.
- Go to Fusion → Scripts and Add-ins → Press green **+**.
- Select unzipped folder.
- In Fusion make sure to turn on `Use gesture-based view navigation`.
  There is no special needs to configure your Trackpad in System Preferences.
  What I personaly do is set Tracking speed to maximum to have panning even faster.

![manual install](res/install.png)
