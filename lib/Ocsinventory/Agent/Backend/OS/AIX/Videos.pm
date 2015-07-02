package Ocsinventory::Agent::Backend::OS::AIX::Videos;
use strict;

sub check {can_run("lsdev")}

sub run {
  my $params = shift;
  my $common = $params->{common};

 for(`lsdev -Cc adapter -F 'name:type:description'`){
		if(/graphics|vga|video/i){
			if(/^\S+\s([^:]+):\s*(.+?)(?:\(([^()]+)\))?$/i){
				 $common->addVideo({
	  				'CHIPSET'  => $1,
	  				'NAME'     => $2,
				});
				
			}
		}
	}
}
1
