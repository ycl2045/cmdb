#!/usr/bin/env bash
#uninstall cmdb scripts

function rMf()
{
  [ -f $1 ] && rm $1
}

function rMd()
{
  [ -d $1 ] && rm $1
}

function uninstallCron()
{
  #rm crob cmdb
  rMf /etc/cron.d/ocsinventory-agent
}

function uninstallCmdb()
{
  #rm cmdb scripts
  rMd /home/ap/idcos/ocsinventory-agent
  #rm cmdb start script
  rMf /home/ap/idcos/bin/ocsinventory-agent
  #rm perl5
  rMd /home/ap/idcos/tool/per5
}

function clearProfile()
{
  [ -f ~/.bash_profile ] && sed -i '/idcos/d' ~/.bash_profile
}

function main()
{
  uninstallCron
  uninstallCmdb
  clearProfile
}
main
