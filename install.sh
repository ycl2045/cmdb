#!/bin/bash

IDCOS_HOME="/home/ap/idcos/"
#config env 

if [ ! -d $IDCOS_HOME ];then
    mkdir -p /home/ap/idcos
fi

#mkdir bin
mkdir /home/ap/idcos/{bin,ocsinventory-agent}

cp -rf lib $IDCOS_HOME/ocsinventory-agent
cp -rf cmd/ocsinventory-agent  $IDCOS_HOME/bin


echo "export PATH=$PATH:$IDCOS_HOME/bin" >> ~/.bash_profile

. ~/.bash_profile
