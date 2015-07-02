package Ocsinventory::Agent::Backend::OS::AIX::Mem;
use strict;

sub check {
	return unless can_run("lsdev");
	return unless can_run("which");
	return unless can_run("lsattr");
	
}

sub run {
  my $params = shift;
  my $common = $params->{common};
  
  my $memory;
  my $swap;
  
  #Memory informations
  #lsdev -Cc memory -F 'name' -t totmem
  #lsattr -EOlmem0
  my (@lsdev, @lsattr, @grep);
  $memory=0;
  @lsdev=`lsdev -Cc memory -F 'name' -t totmem`;
  for (@lsdev){
  	@lsattr=`lsattr -EOl$_`;
	for (@lsattr){
	  if (! /^#/){
		/^(.+):(.+)/;
		$memory += $2;
	  }
	}
  }
  
  #Paging Space
  @grep=`lsps -s`;
  for (@grep){
    if ( ! /^Total/){
	  /^\s*(\d+)\w*\s+\d+.+/;
	  $swap=$1;
	}
  }
  
  $common->setHardware({
      MEMORY => $memory,
      SWAP => $swap 
    });

}

1
