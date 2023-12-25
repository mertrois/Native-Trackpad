<div align="center">

<img src="res/logo.png" alt="Native Trackpad" width="256"/>

# Native Trackpad Gestures<br/>for Autodesk Fusion 360

</div>

- **Pan** - slide with two fingers
- **Zoom** - pinch with two fingers
- **Rotate** - shift + slide with two fingers
- **Zoom to Fit** - double tap with two fingers

## Be Aware

- You can't no longer scroll in Data panel, in order to scroll hold Command key.
- Navigation with perspective camera can be very slow in certain situations,
  using orthographic camera fixes this issue.
  [Code that causes this issue](https://github.com/luclefleur/Native-Trackpad/blob/563fc1f69e3eb2f6dbee136feb9e3b52e439e907/NativeTrackpad.mm#L56).
- [Common issues](https://github.com/luclefleur/Native-Trackpad/issues).

## Installation

- [Download latest release](https://github.com/luclefleur/Native-Trackpad/releases/download/0.14/NativeTrackpad.zip).
- Unzip.
- Go to: Tools → Add-ins → Add-ins → Click ➕.
- Select unzipped folder.
- In Fusion make sure to turn on `Use gesture-based view navigation` (which is the default).

There is no special needs to configure your Trackpad in System Preferences.
What I personally do is set Tracking speed to maximum to have panning even faster.

![manual install](res/install.png)

## Links

- [Todos](https://github.com/luclefleur/Native-Trackpad/search?q=todo).
- [Issues](https://github.com/luclefleur/Native-Trackpad/issues).
- [IdeaStation](https://forums.autodesk.com/t5/ideastation-request-a-feature-or/use-native-trackpad-gesture-recognition-on-macos/idi-p/7018667).
