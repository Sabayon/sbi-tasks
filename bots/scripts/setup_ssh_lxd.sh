#!/bin/bash
rm -rfv $HOME/.ssh || true
ln -s $(pwd)/storage $HOME/.ssh
mkdir -p ~/.config/
rm -rfv $HOME/.config/hub || true
ln -s $(pwd)/storage/hub $HOME/.config/hub
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa.pub
ssh-keyscan github.com >> ~/.ssh/known_hosts


