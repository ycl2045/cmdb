package Ocsinventory::Agent::Backend::OS::AIX::Sounds;
use strict;

sub check {can_run("lsdev")}

sub run {
  my $params = shift;
  my $common = $params->{common};
  
	for(`lsdev -Cc adapter -F 'name:type:description'`){
		if(/audio/i){
			if(/^\S+\s([^:]+):\s*(.+?)(?:\(([^()]+)\))?$/i){
			 $common->addSound({
	  			'description'  => $3,
	  			'manufacturer' => $2,
	  			'name'     => $1,
			});
			}
		}
	} 
}
1
