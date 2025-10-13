#!/bin/bash
set -e

MODULE_NAME=picocalc_kbd
SRC_DIR=./picocalc_kbd
DTBO_DIR=./picocalc_kbd/dts
KO_FILE=${MODULE_NAME}.ko
DTBO_FILE=${MODULE_NAME}.dtbo

echo "🔧 Step 1: Installing dependencies..."
sudo apt update
sudo apt install -y \
    build-essential \
    kernel-package \
    device-tree-compiler \
    git

echo "🔧 Step 2: Building kernel module in ${SRC_DIR}..."
make -C /lib/modules/$(uname -r)/build M=$(realpath ${SRC_DIR}) modules

echo "📁 Step 3: Installing kernel module to system..."
sudo mkdir -p /lib/modules/$(uname -r)/extra
sudo cp ${SRC_DIR}/${KO_FILE} /lib/modules/$(uname -r)/extra/
sudo depmod

echo "📄 Step 4: Installing DTBO to /boot/firmware/overlays/..."
sudo cp ${DTBO_DIR}/${DTBO_FILE} /boot/firmware/overlays/

echo "📝 Step 5: Updating /boot/firmware/config.txt..."
CONFIG=/boot/firmware/config.txt

grep -q "^dtoverlay=${MODULE_NAME}" $CONFIG || {
    sudo sed -i "1i dtoverlay=${MODULE_NAME}" $CONFIG
}

grep -q "^dtparam=i2c_arm=on" $CONFIG || {
    sudo sed -i "1i dtparam=i2c_arm=on" $CONFIG
}

echo "✅ Installation complete."
echo "🔁 Reboot now to activate the driver:"
echo "    sudo reboot"
