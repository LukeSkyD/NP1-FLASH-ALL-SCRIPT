:: NP1-FLASH-ALL-SCRIPT - 2023-07-07 - Made by LukeSkyD
:: This script will flash all the partitions of NP1.
:: Bootloader and critical partitions need to be unlocked first.

:: The program will check: if the phone is connected with fastboot, if the phone is a NP1, if the bootloader is unlocked and if critical partitions are unlocked.

:: The program will check if in the same folder there are the following files:
@echo off
set list=abl aop bluetooth boot cpucp devcfg dsp dtbo featenabler hyp imagefv keymaster mdtp modem multiimgoem qupfw qweslicstore shrm super tz uefisecapp vbmeta vbmeta_system vendor_boot xbl xbl_config
set errorFiles=0

:: If one of the files is missing, the program will tell all the missing ones and exit.
title NP1 Flash All Script
echo.
echo NP1 Flash All Script
echo.
echo Platform-Tools must be installed.
echo Bootloader and critical partitions needs to be unlocked first.
echo.
echo Checking that fastboot is installed...
:: If fastboot is not installed, the program will tell it and exit.
fastboot --version >nul
if errorlevel 1 (
    echo.
    echo ERROR: Fastboot is not installed.
    goto end
)
echo.
echo Fastboot is installed.
echo.
echo Checking that no files are missing...
:: If the files are missing, the program will tell all the missing ones and exit.
:: The missing files are appended to the missingFiles variable.
for %%i in (%list%) do (
    if not exist %%i.img (
        set /a errorFiles+=1
        echo %%i.img is missing.
    )
)
if not %errorFiles% == 0 (
    echo.
    echo ERROR: %errorFiles% file/s missing.
    goto end
)
echo.
echo All files are present.
echo.

:: Check if the phone is a NP1 by fastboot getvar product which returns a line of text: (bootloader) product: Spacewar. 
:: The return must be contains: product: Spacewar
echo Checking if the phone is a NP1...
for /f "delims=" %%a in ('fastboot getvar product 2^>^&1 ^| find /c "Spacewar"') do if not %%a == 1 (
    echo.
    echo ERROR: The phone is not a NP1.
    echo.
    echo Press any key to exit...
    pause >nul
    exit
)
echo.
echo The phone is a NP1.
echo.

:: Check if bootloader and critical partitions are unlocked by fastboot oem device-info which returns multiple lines of text.
:: Of all the lines of text, just two contains "unlocked: true": (bootloader) Device unlocked: true and (bootloader) Device critical unlocked: true.
:: If the two lines are not present, the program will tell it and exit.
echo Checking if the bootloader is unlocked...
for /f "delims=" %%a in ('fastboot oem device-info 2^>^&1 ^| find ^/c ^"unlocked: true^"') do if not %%a == 2 (
    echo.
    echo ERROR: Bootloader and/or critical partitions not unlocked.
    echo.
    echo Press any key to exit...
    pause >nul
    exit
)
echo.
echo Bootloader and critical partitions unlocked.
echo.

:: The program asks for which slot to flash the partitions.
:: The program will check if the slot is a, b or auto (empty).
:: If the slot is not a, b or auto, the program will tell it and exit.
:: The slot will be appended to the fastboot command.
echo Which slot do you want to flash the partitions?
echo.
echo a = Slot A
echo b = Slot B
echo auto = Slot with the most recent boot
echo (default: auto)
echo (type a, b or auto and press enter)
echo (press enter to use default)
echo.
set /p slot=Slot:
if "%slot%" == "" set slot=auto
if not "%slot%" == "a" if not "%slot%" == "b" if not "%slot%" == "auto" (
    echo.
    echo ERROR: Slot not valid.
    echo.
    echo Press any key to exit...
    pause >nul
    exit
)
echo.
echo Slot %slot% selected.
echo.

:: The program asks for the user confirmation.
:: If the user types "y" or "Y", the program will continue.
:: If the user types "n" or "N", the program will exit.
:: If the user types something else, the program will ask again.
echo Are you sure you want to flash all the partitions?
echo.
echo y = Yes
echo n = No
echo (default: n)
echo (type y or n and press enter)
echo (press enter to use default)
echo.
set /p confirm=Confirm:
if "%confirm%" == "" set confirm=n
if "%confirm%" == "y" goto flash
if "%confirm%" == "Y" goto flash
if "%confirm%" == "n" goto end
if "%confirm%" == "N" goto end
echo.
echo ERROR: Invalid input.
echo.
echo Press any key to exit...
pause >nul
exit

:flash
:: if the slot is a or else b, that slot will be set as the active slot with the fastboot command.
if not "%slot%" == "auto" (
    fastboot set_active %slot%
)

echo.
echo Flashing all the partitions...
echo.
:: The program will flash all the partitions.
:: If the program fails to flash a partition, it will tell it and exit.
for %%i in (%list%) do (
    echo Flashing %%i...
    fastboot flash %%i %%i.img
    if errorlevel 1 (
        echo.
        echo ERROR: Failed to flash %%i.
        echo.
        echo Press any key to exit...
        pause >nul
        exit
    )
    echo.
    echo %%i flashed.
    echo.
)
echo.
echo All partitions flashed.
echo.
:: Asks if the user wants to wipe the data.
:: If the user types "y" or "Y", the program will wipe the data.
:: If the user types "n" or "N", the program will exit.
:: If the user types something else, the program will ask again.
echo Do you want to wipe the data?
echo.
echo y = Yes
echo n = No
echo (default: n)
echo (type y or n and press enter)
echo (press enter to use default)
echo.
set /p wipe=Confirm:
if "%wipe%" == "" set wipe=n
if "%wipe%" == "y" goto wipe
if "%wipe%" == "Y" goto wipe
if "%wipe%" == "n" goto end
if "%wipe%" == "N" goto end
echo.
echo ERROR: Invalid input.
echo.
echo Press any key to exit...
pause >nul
exit

:wipe
echo.
echo Wiping the data...
echo.
:: The program will wipe the data.
:: If the program fails to wipe the data, it will tell it and exit.
fastboot -w
if errorlevel 1 (
    echo.
    echo ERROR: Failed to wipe the data.
    echo.
    echo Press any key to exit...
    pause >nul
    exit
)
echo.
echo Data wiped.
echo.

:end
:: asks if the user wants to reboot the phone.
:: If the user types "y" or "Y", the program will reboot the phone.
:: If the user types "n" or "N", the program will exit.
:: If the user types something else, the program will ask again.
echo Do you want to reboot the phone?
echo.
echo y = Yes
echo n = No
echo (default: n)
echo (type y or n and press enter)
echo (press enter to use default)

set /p reboot=Confirm:
if "%reboot%" == "y" if "%reboot%" == "Y" (
    echo.
    echo Rebooting the phone...
    echo.
    fastboot reboot
)
echo.
echo Press any key to exit...
pause >nul
exit

