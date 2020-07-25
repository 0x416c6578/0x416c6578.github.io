# Getting compilation working on Linux
#### These steps will show how to get ATCWatch compiling on Linux
## Prerequisites:
- The Windows portable Arduino version from here: https://atcnetz.de/downloads/D6Arduino.rar
- A fresh copy of Arduino from https://arduino.cc

## Steps
1. Extract both archives.
2. Open the fresh copy of the Arduino IDE. If you have your own copy of the IDE on your system, make sure to create a directory called `portable` in the directory where all the Arduino files are (called `arduino-1.8.12` for me) BEFORE opening for the first time. This will ensure that you won't mess up your libraries that you may already have installed, since all new libraries installed from the fresh copy will be put in the `portable` directory rather than your main sketchbook.
3. Open Preferences and add https://atc1441.github.io/D6Library/package_nRF5_boards_index.json as an additional board manager URL. Go into Tools-Board-Boards Manager and install the D6 tracker board files.
4. Copy all the newly installed files from the `packages` directory in the `portable` directory to a safe location. This will contain the Linux toolchain for compilation, but will not yet contain the correct files for the P8 smartwatch. This is the last time you need to use the new Arduino copy. Strictly speaking you could do this on your main Arduino install but just to be safe I did the work on a portable installation. 
5. Remove the D6 board from the boards manager. Close the IDE.
6. Open D6Arduino from the other extracted archive. Copy the directory `sandeepmistry` from `portable/packages` to the portable IDE installation `portable/packages`. Now delete everything in the `tools` directory in your new installation since this is the Windows toolchain and will not run on Linux. 
7. From the backup you made in step 4 copy the directories in `tools` (`gcc-arm-none-eabi` and `openocd`) to the equivalent directory in the portable installation (`arduino-1.8.12/portable/packages/sandeepmistry/tools`). You are replacing the Windows toolchain with the Linux one.
8. Copy the files: `library_index.json`, `package_index.json`, `package_index.json.sig`, `package_nRF5_boards_index.json`, `package_nRF5_boards_index.json.sig`, `preferences.txt` from the D6Arduino `portable` directory to the new installation `portable` directory. This will make sure Arduino IDE thinks you installed the libraries correctly.
9. Copy the 3 directories in `D6Arduino/portable/sketchbook/libraries` into the corresponding directory in the portable installation
10. Open `platform.txt` in the new portable installation `packages/sandeepmistry/hardware/nRF5/0.6.0/` and under Compiler Variables, add `compiler.libraries.ldflags=/path/to/HRS3300-Arduino-Library-master/src/cortex-m4/libheart.a` with the correct absolute path. Also to the end of the line `recipe.c.combine.pattern=` add `{compiler.libraries.ldflags}` as an option.
11. Use pip to install the packaging utility: `pip3 install --user adafruit-nrfutil`
12. Edit the line `recipe.objcopy.zip.pattern=` in `platform.txt` to get rid of the absolute path to the executable `adafruit-nrfutil.exe` and just leave it as `...pattern="adafruit-nrfutil" dfu genpkg...`. Make sure this executable is in your `$PATH` (it should be after installing through pip)
13. Edit `boards.txt` in the same directory and change the two lines in the section with S132 to s132 (Linux is case sensitive, Windows isn't):
```
p8watch.menu.softdevice.stockFW=Only Softdevice for Flashing via SWD
p8watch.menu.softdevice.stockFW.flashVariantFile=sd.hex
p8watch.menu.softdevice.stockFW.softdeviceversion=2.0.1
p8watch.menu.softdevice.stockFW.softdevice=s132 //THIS LINE S132 -> s132
p8watch.menu.softdevice.onlySoftDevice=Back To Stock Firmware
p8watch.menu.softdevice.onlySoftDevice.flashVariantFile=flashP8.bin
p8watch.menu.softdevice.onlySoftDevice.softdeviceversion=2.0.1
p8watch.menu.softdevice.onlySoftDevice.softdevice=s132 //THIS LINE S132 -> s132
```
14. Copy the `SoftDeviceFiles` directory from the `D6Arduino` directory to the directory where all the Arduino files are (called `arduino-1.8.12` for me).
15. You should now be able to run the portable Arduino installation to compile for the P8. Select `DaFit Watch Bootloader 23` under boards, then compile. Make sure to turn on verbose logging in preferences so that you can see where the `.ino.zip` is stored since it might change from system to system. 
- That should be everything. If you still get errors, leave an issue and I will follow up since I may well have forgotten something.
- Huge thanks to Aaron Christophel for his work