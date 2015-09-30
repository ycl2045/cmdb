#!/bin/bash

export LANG=en_US.utf8
IDCOS_HOME="/home/ap/idcos/"
#config env


function installCmdb()
{
  if [ ! -d $IDCOS_HOME ];then
      mkdir -p /home/ap/idcos
  fi

  #mkdir bin
  mkdir /home/ap/idcos/{bin,ocsinventory-agent}

  cp -rf lib $IDCOS_HOME/ocsinventory-agent
  cp -rf cmd/ocsinventory-agent  $IDCOS_HOME/bin

  echo "export PATH=$PATH:$IDCOS_HOME/bin" >> ~/.bash_profile

  . ~/.bash_profile
}


# install independent perl
function installPerl()
{
  tar -xjf tool.tar.gz $IDCOS_HOME
  cd $IDCOS_HOME
  cp tool/per5/bin/perl bin/
}

# cron.b
function cronB()
{
  CTIME=$(date +%"M")
  cat <<EOF > ./ocsinventory-agent
  PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:${IDCOS_HOME}/bin
  ${CTIME} 22 * * * root ${IDCOS_HOME}/bin/ocsinventory-agent --devlib --local=/tmp > /dev/null 2>&1
EOF
}

function main()
{
  installCmdb
  installPerl
  cronB
}

main
