# mpv-send-to-pleco

This is an [mpv](https://mpv.io/) plugin which sends the current subtitle to
[Pleco](https://www.pleco.com/) on Android via
[ADB](https://developer.android.com/studio/command-line/adb). Requires ADB to be
installed on the same device as mpv, adb debugging to be enabled on the
connected Android device, and of course, for Pleco to be installed on the
Android device.

This should also work with an Android emulator, provided that it's compatible
with ADB.

This addon will automatically send any Chinese subtitles it detects to Pleco as
they appear. The default keybinding to disable this behavior is `Ctrl+a`. You
can also manually send the current subtitle to Pleco via `a`.
