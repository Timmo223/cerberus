#!/bin/bash

# ncmpc over ssh tunnel
#======================

ssh-copy-id pi@volumio.local

# you should now be able to ssh into the pi using ssh keys
ssh pi@volumio.local

# secure ssh to only allow ssh keys 
#==================================

# no root log in via ssh, no password logins only ssh keys

sudo nano /etc/ssh/sshd_config

PermitRootLogin no
ChallengeResponseAuthentication no
PasswordAuthentication no
UsePAM no


# ssh tunnel(local)
ssh -L 6601:localhost:6600 pi@volumio.local 

# ssh tunnel(remote)
ssh -L 6601:localhost:6600 pi@your-ip-address

# ncmpc over ssh tunnel
ncmpc -h localhost -p 6601 -f ~/.ncmpc/rpi-config 
