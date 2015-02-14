#!/usr/bin/env bash


# nameless bash doedel thingy
# =============================================
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# Supported Operating Systems: CentOS 6.*/7.*, in the future maybe
#  Ubuntu server 12.04/14.04 32bit and 64bit
#
#  Author Ron-e (mail@auxio.eu)
#  With huge portions taken from the Sentora installer made by 
#  Pascal Peyremorte (ppeyremorte@sentora.org).
#  Also a big thanks to all those who participated to this script.
#  Thanks to all.

echo "Checking if you are logged in as 'root' user..."
if [ $UID -ne 0 ]; then
    echo "fail: you must be logged in as 'root'."
    echo "Use command 'sudo -i', then enter root password and then try again."
    exit 1
fi
echo "You are logged in as "root" user."

echo "Checking if your OS is supported by this script..."
if [ -f /etc/centos-release ]; then
    OS="CentOs"
    VERFULL=$(sed 's/^.*release //;s/ (Fin.*$//' /etc/centos-release)
    VER=${VERFULL:0:1} # return 6 or 7
else
    echo "Sorry, this OS is not supported by this script." 
    exit 1
fi
echo "Your OS is supported by this script."

echo "Checking if your OS version is supported by this script..."
if [[ "$OS" = "CentOs" && ("$VER" = "6" || "$VER" = "7" ) ]] ; then 
    echo "Ok."
else
    echo "Sorry, this OS version is not supported by this script."  
    exit 1
fi
echo "Your OS is supported version by this script."

echo "Checking if your OS architecture supported by this script...";
if [[ "$ARCH" == "i386" || "$ARCH" == "i486" || "$ARCH" == "i586" || "$ARCH" == "i686" ]]; then
	ARCH="i386"
elif [[ "$ARCH" != "x86_64" ]]; then
    echo "Sorry, this OS architecture is not supported by this script." 
    exit 1
fi
echo "Your OS is supported architecture by this script."

echo "Checking for some common control panels including Sentora and Zpanel..."
if [ -e /etc/sentora ] ||  [ -e /etc/zpanel ] ||  [-e /usr/local/cpanel ] || [ -e /usr/local/directadmin ] || [ -e /usr/local/solusvm/www ] || [ -e /usr/local/home/admispconfig ] || [ -e /usr/local/lxlabs/kloxo ] ; then
    echo "It appears that a control panel is already installed on your server."
    echo "This script is designed to work on an clean installed OS."
    echo -e "\nPlease re-install your OS before attempting to restart this script."
    exit 1
fi
echo "Your OS has not common control panel installed."


if [[ "$OS" = "CentOs" ]] ; then
	
	echo "Downloading minimal package list..."
	while true; do
		wget -nv -O minimal_packages.txt https://raw.githubusercontent.com/auxio/XXX/master/centos/$VER/minimal_packages.txt
		if [[ -f sentora_core.zip ]]; then
			break;
		else
			echo "Failed to download minimal package list from Github."
		exit 1
		fi 
	done
	echo "The minimal package list has been downloaded."
	
	echo "getting installed list..."
	INSTALLED_PACKAGES="$(yum list installed | awk 'split($1,a,".") { if (NR>2){ print a[1] } }')"
	echo "$INSTALLED_PACKAGES" >> /root/installed_packages.txt 
	
	echo "Compare lists..."
	cd /root/
	REMOVE_PACKAGES="grep -Fxvf  minimal_packages.txt installed_packages.txt"
	echo "$REMOVE_PACKAGES" >> /root/remove_packages.txt
	
	echo "All list are stored as text files in your root folder."
	echo "List of packages that has to be removed:"
	echo "$REMOVE_PACKAGES"
	echo ""
	echo "#########################################################";
	echo "# !! WARNING WARNING WARNING WARNING WARNING WARNING !! #"
	echo "#########################################################"
	echo "#                                                       #"
	echo "#    You are about to automatically remove packages     #"
	echo "#              and you must be fully aware              #"
	echo "#            of the risk of this procedure.             #"
	echo "#    For more information check the Sentora Forums.     #"
	echo "#              http://forums.sentora.org/               #"
	echo "#                                                       #"
	echo "#########################################################"
	echo "# THE SCRIPT IS DISTRIBUTED IN THE HOPE THAT IT WILL BE #" 
	echo "#USEFUL, IT IS PROVIDED 'AS IS' AND WITHOUT ANY WARRANTY#"
	echo "#########################################################"
	echo ""
	read -e -p "Do you want to automaticly remove these packages now (y/n)? " yn
	case $yn in
		[Yy]* ) break;;
		[Nn]* ) exit;;
	esac
	
	while read line; do 
		echo "Removing package: $line..." 
		yum remove -y $line
		echo "$line has been removed."
	done < /root/remove_packages.txt
	yum clean all
	echo "All packages from the remove list are removed."
	
	
	echo -e "\n-- Updating+upgrading system, it may take some time..."
	if [[ "$OS" = "CentOs" ]]; then
	    yum -y update
	    yum -y upgrade
	elif [[ "$OS" = "Ubuntu" ]]; then
	    apt-get -yqq update
	    apt-get -yqq upgrade
	fi
	
	
	
	
elif [[ "$OS" = "Ubuntu" ]]; then
   
	### UBUNTU IS NOT TESTED, IT'S COPY PASTED FROM CENTOS WITH YUM CHANGED TO APT-GET... NOTING MORE ON THIS MOMENT!!!1
	echo "Downloading minimal package list..."
	while true; do
		wget -nv -O minimal_packages.txt https://raw.githubusercontent.com/auxio/XXX/master/centos/$VER/minimal_packages.txt
		if [[ -f sentora_core.zip ]]; then
			break;
		else
			echo "Failed to download minimal package list from Github."
		exit 1
		fi 
	done
	echo "The minimal package list has been downloaded."
	
	echo "getting installed list..."
	INSTALLED_PACKAGES="$(apt-get list installed | awk 'split($1,a,".") { if (NR>2){ print a[1] } }')"
	echo "$INSTALLED_PACKAGES" >> /root/installed_packages.txt 
	
	echo "Compare lists..."
	cd /root/
	REMOVE_PACKAGES="grep -Fxvf  minimal_packages.txt installed_packages.txt"
	echo "$REMOVE_PACKAGES" >> /root/remove_packages.txt
	
	echo "All list are stored as text files in your root folder."
	echo "List of packages that has to be removed:"
	echo "$REMOVE_PACKAGES"
	echo ""
	echo "#########################################################";
	echo "# !! WARNING WARNING WARNING WARNING WARNING WARNING !! #"
	echo "#########################################################"
	echo "#                                                       #"
	echo "#    You are about to automatically remove packages     #"
	echo "#              and you must be fully aware              #"
	echo "#            of the risk of this procedure.             #"
	echo "#    For more information check the Sentora Forums.     #"
	echo "#              http://forums.sentora.org/               #"
	echo "#                                                       #"
	echo "#########################################################"
	echo "# THE SCRIPT IS DISTRIBUTED IN THE HOPE THAT IT WILL BE #" 
	echo "#USEFUL, IT IS PROVIDED 'AS IS' AND WITHOUT ANY WARRANTY#"
	echo "#########################################################"
	echo ""
	read -e -p "Do you want to automaticly remove these packages now (y/n)? " yn
	case $yn in
		[Yy]* ) break;;
		[Nn]* ) exit;;
	esac
	
	while read line; do 
		echo "Removing package: $line..." 
		apt-get remove -y $line
		echo "$line has been removed."
	done < /root/remove_packages.txt
	apt-get clean all
	echo "All packages from the remove list are removed."
	
	echo -e "\n-- Updating+upgrading system, it may take some time..."
	apt-get -yqq update
	apt-get -yqq upgrade
fi



