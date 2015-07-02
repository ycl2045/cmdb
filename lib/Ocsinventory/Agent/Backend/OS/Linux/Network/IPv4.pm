package Ocsinventory::Agent::Backend::OS::Linux::Network::IPv4;

sub check {
  return unless can_run ("ifconfig");
  1;
}

# Initialise the distro entry
sub run {
  my $params = shift;
  my $common = $params->{common};
  my @ip;
  foreach (`ifconfig`){
    #if(/^\s*inet\s*(\S+)\s*netmask/){
    if(/^\s*inet add?r\s*:\s*(\S+)/ || /^\s*inet\s+(\S+)/){
      ($1=~/127.+/)?next:push @ip, $1
    };
  }

  my $ip=join "/", @ip;

  $common->setHardware({ipaddr => $ip});
}

1;
