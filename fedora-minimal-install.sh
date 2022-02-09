
if [ $(whoami) = "root" ]
then
        echo "Welcome to fedora minimal desktop installer"
else
	echo "Please execute this script as root"
	echo "use : sudo fedora-minimal-install.sh"
	echo "or use your root account"
	exit 1
fi

echo "Would you like to optimize DNF with fastestmirror and max_parallel_download ?"
echo "(Downloading rpms will be faster)"
echo "1 = yes 0 = no"
opti=1
read opti

echo "Would you like to enable flathub repo?"
echo "(More apps are avalible on flathub)"
echo "1 = yes 0 = no"
flathub=1
read flathub

echo "Would you like to enable nvidia proprietary driver?"
echo "NVIDIA GPU ONLY GTX600+"
echo "1 = yes 0 = no"
nvidia=0
read nvidia

echo "Would you like to use XanMod Kernel ?"
echo "A custom kernel with F-Sync and other optimisations"
echo "1 = yes 0 = no"
xanmod=1
read xanmod


##Nvidia
if [ $nvidia = "1" ]
then
	dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm -y
	dnf install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y
	sudo echo "blacklist nouveau" >> /etc/modprobe.d/blacklist.conf
	sudo dnf install xorg-x11-drv-nvidia xorg-x11-drv-nvidia-libs akmod-nvidia kmod-nvidia --allowerasing -y
	sudo dnf remove xorg-x11-drv-nouveau -y
else
	echo ""
fi


##Download optimisations
if [ $opti = "1" ]
then
	echo 'fastestmirror=1' >> /etc/dnf/dnf.conf
	echo 'max_parallel_downloads=10' >> /etc/dnf/dnf.conf
else
	echo ""
fi


##Installing core apps
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y
dnf install gnome-shell gdm gnome-terminal firefox nautilus gnome-software gnome-tweaks chrome-gnome-shell gdouros-symbola-fonts wget liberation-sans-fonts liberation-fonts liberation-serif-fonts liberation-narrow-fonts liberation-mono-fonts liberation-fonts-common google-noto-cjk-fonts google-noto-cjk-fonts-common google-noto-cjk-fonts-common -y
##enableing GDMfix
rm -rf /etc/systemd/system/enablegdmfix.service
systemctl disable gdm.service
touch /etc/systemd/system/enablegdmfix.service
echo "[Unit]" >> /etc/systemd/system/enablegdmfix.service
echo "Description=GDMfixFedora" >> /etc/systemd/system/enablegdmfix.service
echo "" >> /etc/systemd/system/enablegdmfix.service
echo "[Service]" >> /etc/systemd/system/enablegdmfix.service
echo "User=root" >> /etc/systemd/system/enablegdmfix.service
echo "WorkingDirectory=/" >> /etc/systemd/system/enablegdmfix.service
echo "ExecStart=systemctl start gdm" >> /etc/systemd/system/enablegdmfix.service
echo "Restart=always" >> /etc/systemd/system/enablegdmfix.service
echo "" >> /etc/systemd/system/enablegdmfix.service
echo "[Install]" >> /etc/systemd/system/enablegdmfix.service
echo "WantedBy=multi-user.target" >> /etc/systemd/system/enablegdmfix.service
systemctl enable enablegdmfix.service

##flatpak support
if [ $flathub = "1" ]
then
	flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
	flatpak remote-add flathub-beta https://flathub.org/beta-repo/flathub-beta.flatpakrepo 
else
	echo ""
fi

##Xanmod
if [ $xanmod = "1" ]
then
	dnf copr enable rmnscnce/kernel-xanmod -y
	dnf install kernel-xanmod-edge kernel-xanmod-edge-headers -y
	echo 'exclude=kernel' >> /etc/dnf/dnf.conf
else
	echo ""
fi

##reboot prompt
echo "Would you like to restart your system now ?"
echo "If no you can use your system in CLI until you reboot."
echo "1 = yes 0 = no"
restart=1
read restart
if [ $restart = "1" ]
then
	reboot
else
	echo "You can restart using the reboot command"
	echo "(reboot) or (systemctl reboot)"
fi

