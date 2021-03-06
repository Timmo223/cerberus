#!/bin/bash

# unbound dns server arch linux install
#======================================

sudo pacman -S unbound expat ldns

# copy the sample config file
#=============================

sudo cp /etc/unbound/unbound.conf.example /etc/unbound/unbound.conf

# download roots hints
#=====================

# root hints

curl -o /etc/unbound/root.hints https://www.internic.net/domain/named.cache

# edit /etc/unbound/unbound.conf and add


root-hints: "/etc/unbound/root.hints"

# DNSSEC validation
#==================

# You will need the root server trust key anchor file.
# It is provided by the dnssec-anchors package (already installed as a dependency)
# however, unbound needs read and write access to the file. 

sudo mkdir /etc/unbound/keys
sudo cp /etc/trusted-key.key /etc/unbound/keys/dnssec-root-anchor.key
sudo chown -R unbound:unbound /etc/unbound/keys


# edit the unbound.conf file and uncomment auto trust and add the file path
#==========================================================================


sudo vim /etc/unbound/unbound.conf

server:
  auto-trust-anchor-file: "/etc/unbound/keys/dnssec-root-anchor.key"




# create /etc/resolv.conf.head
#=============================

sudo vim /etc/resolv.conf.head

nameserver 127.0.0.1


# /etc/dhcpcd.conf
#==================================

# dhcpcd's configuration file may be edited to prevent the dhcpcd daemon from overwriting /etc/resolv.conf. 
# To do this, add the following to the last section of /etc/dhcpcd.conf:
# nohook resolv.conf


sudo vim /etc/dhcpcd.conf

nohook resolv.conf

# Write-protect /etc/resolv.conf
#===============================

# protect your /etc/resolv.conf from being modified by anything is setting the immutable (write-protection) attribute:

sudo chattr +i /etc/resolv.conf




# adblocking
#================

cd ~/Desktop


# download adblocking list
#==========================


wget -q -O- --header\="Accept-Encoding: gzip" 'http://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&mimetype=plaintext' | \
gunzip | \
awk '/^127\./{
	print "local-zone: \"" $2 "\" redirect"
	print "local-data: \"" $2 " A 127.0.0.1\""
}' > unbound_ad_servers



# copy the adblocking list to the /etc/unbound directory
#========================================================

sudo cp unbound_ad_servers /etc/unbound


# change ownership on the unbound_ad_servers to give unbound access

sudo chown unbound:unbound /etc/unbound/unbound_ad_servers



# edit the unbound.conf file and include the unbound_ad_servers file
#===================================================================


sudo vim /etc/unbound/unbound.conf


server:
	# yoyo.pgl adblocking
	include: /etc/unbound/unbound_ad_servers



# start unbound dns server
#===================================================================


# start unbound

sudo systemctl start unbound.service


# enable unbound to start automatically

sudo systemctl enable unbound.service
