#!/bin/bash

export LC_ALL=C
sudo apt-get install etckeeper -y

echo "
VCS="git"

GIT_COMMIT_OPTIONS=""
HG_COMMIT_OPTIONS=""
BZR_COMMIT_OPTIONS=""
DARCS_COMMIT_OPTIONS="-a"
HIGHLEVEL_PACKAGE_MANAGER=apt
LOWLEVEL_PACKAGE_MANAGER=dpkg
" > /etc/etckeeper/etckeeper.conf

echo "
if [ -d /root/etckeeper ] ; then
        for s in /root/etckeeper/*.sh ; do
                . \$s
        done
fi
" >> ~/.bashrc

git config --global user.email "you@example.com"
git config --global user.name "ELK user"

cd /etc
etckeeper init
git add .
etckeeper commit 'initial commit'
