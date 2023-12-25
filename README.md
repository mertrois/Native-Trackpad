<div align="center">

<img src="res/logo.png" width="256"/>

# Native Trackpad Gestures<br/>for Autodesk Fusion 360

</div>


- Changes two finger pan gesture and adds inertia.
- Changes pinch to zoom gesture.
- Rotate is shift + two finger.
- Zoom to fit is double two finger tap.
- You can't no longer scroll in Data panel, in order to scroll hold Command key.
- Navigation with perspective camera can be very slow in certain situations,
  using orthographic camera fixes this issue.
  [Code that causes this issue](https://github.com/luclefleur/Native-Trackpad/blob/563fc1f69e3eb2f6dbee136feb9e3b52e439e907/NativeTrackpad.mm#L56).

## Links

- **[Common Issues](https://github.com/luclefleur/Native-Trackpad/issues)**
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
