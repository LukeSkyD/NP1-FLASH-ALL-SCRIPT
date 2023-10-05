# NP-FLASH-ALL-SCRIPT - 2023-10-05 - Made by LukeSkyD
# This script will flash all the partitions of NP1/NP2.
# Bootloader and critical partitions need to be unlocked first.

# The program will check: if the phone is connected with fastboot, if the phone is a NP1 or NP2, if the bootloader is unlocked and if critical partitions are unlocked.

# The program will check if in the same folder there are the following files:
# This is the list of partition new to NP2
listNP2="aop_config multiimgqti recovery uefi vbmeta_vendor xbl_ramdump"
# vm-bootsys is a partition which is not used NOW (2023-10-05 aaaa-mm-gg notation) but could be in the future is im including it as optional
optionalNP2="vm-bootsys"
# This is the list of partition both for NP1 and NP2
list="abl aop bluetooth boot cpucp devcfg dsp dtbo featenabler hyp imagefv keymaster mdtp modem multiimgoem qupfw qweslicstore shrm super tz uefisecapp vbmeta vbmeta_system vendor_boot xbl xbl_config"
errorFiles=0

# If the files are not present, the program will exit.
echo "NP Flash All Script"
echo
echo "Platform-Tools must be installed."
echo "Bootloader and critical partitions needs to be unlocked first."
echo

echo "Checking that fastboot is working..."
if ! fastboot devices | grep -q "fastboot"
then
    echo "fastboot is not working"
    exit
fi

echo "Checking that the phone is a NP1 (Spacewar) or NP2 (Pong)..."
echo "If the program stops here, disconnect and reconnect the phone/check that drivers are installed correctly/restart the bootloader."
if ! fastboot getvar product 2>&1 | grep -q "Spacewar" && ! fastboot getvar product 2>&1 | grep -q "Pong"
then
    echo "The phone is not a NP1 (Spacewar) or NP2 (Pong)"
    exit
fi

echo "Checking that the bootloader is unlocked..."
if ! fastboot getvar unlocked 2>&1 | grep -q "yes"
then
    echo "The bootloader is not unlocked"
    exit
fi
echo "Checking that critical partitions are unlocked..."
# Check if bootloader and critical partitions are unlocked by fastboot oem device-info which returns multiple lines of text.
# Of all the lines of text, just two contains "unlocked: true": (bootloader) Device unlocked: true and (bootloader) Device critical unlocked: true.
# If the two lines are not present, the program will tell it and exit.
if ! fastboot oem device-info 2>&1 | grep -q "Device critical unlocked: true"
then
    echo "Critical partitions are not unlocked"
    exit
fi

# if the phone is NP2, listNP2 will be appended to list
if fastboot getvar product 2>&1 | grep -q "Pong"
then
    list="$list $listNP2"

    # if -o is present, optionalNP2 will be appended to list
    if [ "$1" == "-o" ]; then
        list="$list $optionalNP2"
    fi
fi

echo "Checking that all the files are present..."
for i in $list
do
    if [ ! -f "$i.img" ]; then
        echo "$i.img is missing"
        errorFiles=$((errorFiles+1))
    fi
done
if [ "$errorFiles" -gt 0 ]; then
    echo $errorFiles "file/s missing"
    exit
fi
echo "All the files are present"

# The program asks for which slot to flash the partitions.
# The program will check if the slot is a, b or auto (empty).
# If the slot is not a, b or auto, the program will tell it and exit.
# The slot will be appended to the fastboot command.
echo "Which slot do you want to flash the partitions? (a, b or auto)"
echo "If you don't know, type auto"
read slot
if [ "$slot" != "a" ] && [ "$slot" != "b" ] && [ "$slot" != "auto" ]; then
    echo "The slot is not a, b or auto"
    exit
fi

# The program will ask for confirmation.
# If the user types "y" or "yes", the program will continue.
# If the user types everything else, the program will exit.
echo "Are you sure you want to flash all the partitions? (y/n)"
read confirmation
if [ "$confirmation" != "y" ] && [ "$confirmation" != "yes" ]; then
    echo "The program will exit"
    exit
fi

# If the slot is a or b, the program will set the slot.
# If the slot is auto, the program will not set the slot.
if [ "$slot" == "a" ] || [ "$slot" == "b" ]; then
    fastboot set_active $slot
fi

# The program will flash all the partitions.
# If the slot is auto, the program will flash the partitions to both slots.
# If the slot is a or b, the program will flash the partitions to the selected slot.
echo "Flashing all the partitions..."
for i in $list
do
    echo "Flashing $i.img..."
    fastboot flash $i $i.img
done
echo "All the partitions have been flashed"

# Ask the user to wipe data
echo "Do you want to wipe (format) data? (y/n)"
read wipeData
if [ "$wipeData" == "y" ] || [ "$wipeData" == "yes" ]; then
    echo "Wiping data..."
    fastboot -w
    echo "Data has been wiped"
fi

# The program will ask to reboot the phone.
# If the user types "y" or "yes", the program will reboot the phone.
# If the user types everything else, the program will exit.
echo "Do you want to reboot the phone? (y/n)"
read reboot
if [ "$reboot" == "y" ] || [ "$reboot" == "yes" ]; then
    echo "Rebooting the phone..."
    fastboot reboot
    echo "The phone is rebooting"
    exit
fi
echo "The program will exit"
exit
