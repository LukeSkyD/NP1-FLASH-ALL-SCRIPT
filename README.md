FLASH-ALL-SCRIPT
=
Script to flash full zip os to your NP1

**Special thanks to [Reindex-OT](https://reindex-ot.github.io/)** for the full zip roms and all their work on NP1!

Prerequisites
-
- [ADB & FASTBOOT](https://developer.android.com/studio/releases/platform-tools.html) installed and added to your path
- [FULL ZIP / FASTBOOT ROMS](https://reindex-ot.github.io/) Downloaded and extracted to a folder

Usage
-
- Download the script and place it in the same folder as your extracted rom
- Open a command prompt in the folder
- Run the script with `flash-all.bat` or `flash-all.sh` depending on your OS
- Follow the on screen instructions

**NOTE:** If you are on Windows and get an error about the script not being able to run, you may need to run `Set-ExecutionPolicy Unrestricted` in an elevated powershell window. This will allow you to run the script. You can then run `Set-ExecutionPolicy Restricted` to set it back to normal.

**NOTE:** If you are on Linux and get an error about the script not being able to run, you may need to run `chmod +x flash-all.sh` to make the script executable. You can then run the script with `./flash-all.sh`

LINUX VERSION STILL IN DEVELOPMENT
