
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


##Download optimisations
if [ $opti = "1" ]
then
	echo 'fastestmirror=1' >> /etc/dnf/dnf.conf
	echo 'max_parallel_downloads=10' >> /etc/dnf/dnf.conf
else
	echo ""
fi


##Installing core apps
dnf install gnome-shell gdm gnome-terminal firefox nautilus gnome-software gnome-tweaks chrome-gnome-shell gdouros-symbola-fonts wget liberation-sans-fonts liberation-fonts liberation-serif-fonts liberation-narrow-fonts liberation-mono-fonts liberation-fonts-common -y
##enableing GDMfix
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

##flatpak support
if [ $flathub = "1" ]
then
	flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
	flatpak remote-add flathub-beta https://flathub.org/beta-repo/flathub-beta.flatpakrepo 
else
	echo ""
fi
reboot
