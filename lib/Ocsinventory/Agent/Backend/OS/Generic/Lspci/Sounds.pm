package Ocsinventory::Agent::Backend::OS::Generic::Lspci::Sounds;
use strict;

sub run {
  my $params = shift;
  my $common = $params->{common};

  foreach(`lspci`){

    if(/audio/i && /^\S+\s([^:]+):\s*(.+?)(?:\(([^()]+)\))?$/i){

      $common->addSound({
	  'description'  => $3,
	  'manufacturer' => $2,
	  'name'     => $1,
	});
    
    }
  }
}
1
