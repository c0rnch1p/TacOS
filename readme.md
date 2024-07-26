### TacOS [[v1.5.0 ISOs Available, ](https://app.mediafire.com/y9ongymscl0ag)[Etcher USB Formatter, ](https://etcher.balena.io)[HowTo](https://youtu.be/GWZvGu8LjNc?si=vDeoD4UX1xw45h8T)]
###### Details
- **Arch**: Linux x86_64
- **Disk Size**: 48GB
- **ISO Size**: 6G (Squashfs)
- **Vers**: v1.5
###### Weblinks
- **Arch Linux**: https://archlinux.org
- **Archiso**: https://wiki.archlinux.org/title/Archiso
- **Arco Linux**: https://arcolinux.com
- **Awesome**: https://awesomewm.org
- **Pacman**: https://wiki.archlinux.org/title/Pacman
- **X.org**: https://www.x.org/wiki
###### General
TacOS is a custom Linux build based on Arch and Arco Linux, it features a streamlined
installation process using Calamares and multiple bootloader configurations. Users can
build an ISO using the provided script, run it in a virtual machine, or flash it to a USB
drive to use live. Building TacOS on a distro based on something other than Arch will be
problematic, because `build_iso.sh` depends on Pacman. Special thanks to the developers of
the software that made this project possible by making their code open source.
### Installation
###### Installing Arch
- **Arch Wiki**: https://wiki.archlinux.org/title/Installation_guide
- **Phoenixnap**: https://phoenixnap.com/kb/arch-linux-install
###### Depends
- **archiso**: Tools for creating arch Linux ISO images
- **pacman**: Library based package manager with dependency support
- **reflector**: Python script to retrieve and filter pacman mirror lists
###### Building TacOS
Open a terminal or TTY and clone this repo:
```shell
git clone 'https://github.com/c0rNCh1p/tacOS.git' ||
git clone 'https://gitlab.com/c0rNCh1p/tacOS.git'
```
Change to the build directory, make sure the script is executable and run it:
```shell
cd 'TacOS' && chmod 764 'build_iso.sh' && ./'build_iso.sh'
```
###### Flashing
A script to make the flashing process easier is included in the scripts folder:
```shell
cd 'TacOS' && chmod 764 'flash_iso.sh' && ./'flash_iso.sh'
```
Be sure to unplug and reinsert the USB otherwise it wont be detected in the BIOS after
its ejected.
###### Booting
1. Reboot the machine.
2. Access the boot menu (UEFI, BIOS etc), requires pressing a specific key on powerup
   (usually F12, F11, Esc, or Del), before anything else starts loading.
3. Go to the boot options tab, a list of available boot devices will be displayed.
4. Choose the one that corresponds to the live media (e.g. somebrand-USB or liveiso-DVD).
5. Go to the final tab, save the changes and reboot again.
### Notes
###### No Login Manager
There is no login manager installed to the ISOs by default, nor is any extra support for
login managers included in the base filesystem. Upon booting into the live environment,
the user is dropped into TTY1 and a welcome message is displayed. The message advises
users to run the setup scripts with `01_run_all`. Some of the scripts require an active
internet connection, so if the machine isnt connected via Ethernet, just run `nmtui`.
###### No Netinstall
The Calamares configuration settings and modules included in the ISO are not intended for
installing the system over a connection and instead are optimized for offline usage.
Sometimes a completely offline installation is impossible, but being less dependent on
the network while using Calamares results in fewer errors overall when installing TacOS.
###### No Symlinks
There are no symlinks in this repo, everything that would usually use a symlink during
the boot process of an operating system is done using a script or configured manually. As
a result, when booting into the live environment there is a point where the kernel may
ask for an input variable. This is just the timezone which is entered in `Region/Zone`
format (where region is the country and zone is the city or town) or skipped with `nter`.
###### No LTS
The Linux long-term-support packages arent included in the builds by default or supported
in any of the bootloader configs (GRUB, systemd-boot and syslinux). If the LTS package is
required, it can be added to the package lists and whatever bootloader config is in use. It
could also be installed on the existing system, eg. for grub GRUB on Arch:
```shell
sudo pacman -S linux-lts linux-lts-headers && sudo grub-mkconfig -o '/boot/grub/grub.cfg'
```
###### No Nouveau
The nvidia-nouveau package is not included in TacOS by default due to compatibility and
stability issues with certain Nvidia graphics cards. Users who need Nvidia support should
install the external Nvidia drivers post-installation:
```shell
sudo pacman -S nvidia nvidia-utils nvidia-settings
```
Followed by updating the GRUB configuration and rebooting the system:
```shell
sudo grub-mkconfig -o '/boot/grub/grub.cfg' && systemctl reboot
```
###### First Login
After installing TacOS, please note that the autologin will no longer match the liveuser
account because it wont exist. This means the shell is manually logged into at startup
and should be reloaded before running `startx` to launch the graphical environment or
before continuing with server configuration. This is done using the `bash` command or the
builtin `reload` alias.
###### Sudoers File
Like any fresh install the first thing a new user would do is add their username into the
`/etc/sudoers` file and reboot. This isnt necessarilly done with `visudo`, its just as
easy if not easier to do it by logging straight into the root shell and running:
```
nano /etc/sudoers
```
Nano has a builtin system config on TacOS, once open the find and replace option can simply
be triggered with `Ctrl+r` and the string `liveuser` can be changed.
### Repo Links
###### Dotfiles & Bin Scripts
- [Skel Config](https://gitlab.com/c0rNCh1p/tacos/-/tree/master/tacos/airootfs/etc/skel/.config)
- [Skel Bash Config](https://gitlab.com/c0rNCh1p/tacos/-/tree/master/tacos/airootfs/etc/skel/.local/bin)