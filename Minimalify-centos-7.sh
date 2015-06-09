echo "Downloading minimal package list..."
while true; do
	wget -nv -O minimal_packages.txt https://raw.githubusercontent.com/Ron-e/Minimalify/master/OS/CentOS/7/minimal_packages.txt
	if [[ -f minimal_packages.txt ]]; then
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