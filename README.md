# RuuviMenu
Small menubar utility for showing Ruuvi messages on macOS.

## Building

This project uses CMake to generate build files for Xcode.

First, create a build folder and run Cmake

    mkdir build && cd build
    cmake -G Xcode ..

then build the project with Xcode

    xcodebuild -project RuuviMenu.xcodeproj -configuration Release

the `build/Release` folder should now contain the application bundle.


## Ruuvi logs

In addition to showing temperature in the menubar this utility also logs all Ruuvi messages to the system log using the category `RuuviMsg` and the `info` log level.
In order to view the message you can use Console.app or stream them on the command line using the `log` command.

    log stream --style=compact --info --predicate='category="RuuviMsg"'

