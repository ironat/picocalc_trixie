# picocalc_trixie

This installation is a Terminal only, no Wayland or X11.

Thanks to wasdwasd0105 for initial design for the Connection the keyboard driver and the simple audio solution!
This project uses partly the https://github.com/wasdwasd0105/picocalc-pi-zero-2 project.(Keyboard and audio)


* TOC
  {:toc}


## Step 1

# Install Trixie 32 Bit Lite with Raspberry Pi Imager. 

<img width="307" height="206" alt="image" src="https://github.com/user-attachments/assets/cdde44a4-9957-4e8a-b1b4-3ccfd1f240b8" />
<img width="320" height="233" alt="image" src="https://github.com/user-attachments/assets/fd81771e-8fb5-40fa-bab7-68d8a0293ea6" />

# Set your Username and Wifi credentials:

<img width="276" height="309" alt="image" src="https://github.com/user-attachments/assets/b258ae46-d174-4195-b1f1-cce4bb51e3a6" />

# Enable SSH:

<img width="259" height="110" alt="image" src="https://github.com/user-attachments/assets/296ff83e-b6d3-4b61-8bda-c6ff84ee73b7" />

Burn the Image.

## Step 2
Log into you Raspberry PI

You have two possibilities:

1.) Connect it to a monitor and use a Keyboard.

2.) Use the monitor to check for ip or use the set hostname (does not work in my network) or check the router for the IP and then use ssh(Putty) to connect.


## Step 3
Get Repository
When you logged in then execute:
```
sudo apt update
sudo apt install git
```
Get this repository:

```
git clone https://github.com/ironat/picocalc_trixie
```
## Step 4
Install Display
```
cd picocalc_trixie
sudo cp picomipi.bin /lib/firmware/.
```
Update /boot/firmware/config.txt

Uncomment:
```
dtparam=spi=on
```
Copy the text below into the File
```
dtoverlay=mipi-dbi-spi,spi0-0,speed=70000000
dtparam=compatible=picomipi\0panel-mipi-dbi-spi
dtparam=width=320,height=320,width-mm=43,height-mm=43
dtparam=reset-gpio=25,dc-gpio=24
dtparam=backlight-gpio=18
dtparam=clock-frequency=50
```
Edit /boot/firmware/cmdline.txt and added
```
fbcon=map:1 fbcon=font:MINI4x6
```
at the end.
It should look like this (one Line!):
```
console=serial0,115200 console=tty1 root=PARTUUID=568f209b-02 rootfstype=ext4 fsck.repair=yes rootwait cfg80211.ieee80211_regdom=AT fbcon=map:1 fbcon=font:MINI4x6
```
Reboot
```
sudo reboot
```
Your display should now working.

## Step 5
Install Keyboard

Before you execute the setup_keyboard.sh script ensure to set two parameters for apt.
Create the file /etc/apt/apt.conf.d/99local 

Content:
```
APT::Install-Suggests "false";
APT::Install-Recommends "false";
```
This reduce the runtime of the next step dramatically.

Now execute the script.
```
cd picocalc_trixie
chmod +x setup_keyboard.sh
sudo ./setup_keyboard.sh
```
Check /boot/firmware/config.txt. It should contain:
```
#FOR KEYBOARD
dtparam=i2c_arm=on
dtoverlay=picocalc_kbd
```
If everthing went fine and you have no errors then you should have a keyboard after reboot.

## Step 6
Install audio.
Add to /boot/firmware/config.txt following line after dtparam=audio=on
```
dtoverlay=audremap,pins_12_13
```

## Step 7
Switch off device on sudo poweroff
Create script:

/usr/local/bin/picopoweroff
```
#!/bin/sh
i2cset -yf 1 0x1f 0x8e 0x00
```
Create Service:
/usr/lib/systemd/system/picopoweroff.service
```
[Unit]
Description=shutdown picocalc
DefaultDependencies=no
After=shutdown.target
Requires=shutdown.target

[Service]
Type=oneshot
RemainAfterExit=true
ExecStart=/usr/local/bin/picopoweroff

[Install]
WantedBy=shutdown.target
```
Reboot and check status:
```
root@zerocalc:/home/iron# systemctl status picopoweroff
○ picopoweroff.service - shutdown picocalc
     Loaded: loaded (/usr/lib/systemd/system/picopoweroff.service; enabled; preset: enabled)
     Active: inactive (dead)
```
(Of course it is inactive (dead) because it only starts on shutdown)
If not enabled then enable it with:
```
systemctl enable picopoweroff
```

If you now execute 
```
sudo poweroff
```
picocalc should automatically switch off.

## Step 8
So you are basically done.
From here you can make it your own.
For an Example:

For fun you may install sdl2:
```
sudo apt install libsdl2-2.0-0
sudo apt install libgles2
sudo apt install libegl-dev
```
and pygame
```
sudo apt install python3-pygame
```

Pico 8 should also work.
Tmux would be helpful.

## Install FBTERM

Install:
```
sudo apt install fbterm
```
Start with:
```
 FRAMEBUFFER=/dev/fb1 fbterm
```

## Install tmux


Install:
```
sudo apt install tmux
```
Start with:
```
 tmux
```
Battery:

generate a file in
mkdir bin
nano ~/bin/battery
```
#!/bin/python3
import subprocess

result=subprocess.check_output(["cat","/sys/firmware/picocalc/battery_percent"]).decode('utf-8')
percent = int(result)
if (percent > 100):
        print('C'+str(percent-128) + '%  ')
else:
        print(' ' + str(percent) + '%  ')
```
Make it executeable
```
chmod +x ~/bin/battery
```
nano .tmux.conf
```
set-option -ag status-right "#[fg=red,dim,bg=default]#(~/bin/battery) "
```

## Issues
If you get an locales error execute:
```
sudo dpkg-reconfigure locales
```
and set it to --> en_GB.utf-8

## Future Roadmap or what I like to look into:
* Add a Battery status with Termux or byobu
* Poweroff automatically over STM32
* Connect a thermal camera to the back of the Picocalc (GPIOs from Pi Zero are accessable)

