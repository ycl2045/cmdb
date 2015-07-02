package Ocsinventory::Agent::Backend::OS::Solaris::Controllers;
use strict;

sub check { can_run ("cfgadm") }

sub run {
  my $params = shift;
  my $common = $params->{common};

  my $name;
  my $type;
  my $manufacturer;

  foreach(`cfgadm -s cols=ap_id:type:info`){
    next if (/^Ap_Id/); 	
    if(/^(\S+)\s+/){
      $name = $1;
    }
    if(/^\S+\s+(\S+)/){
      $type = $1;
    }
#No manufacturer, but informations about controller
    if(/^\S+\s+\S+\s+(\S+)/){
      $manufacturer = $1;
    }   			
    $common->addController({
	'NAME'          => $name,
	'MANUFACTURER'  => $manufacturer,
	'TYPE'          => $type,
	});
  }
}
1
