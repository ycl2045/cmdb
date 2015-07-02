package Ocsinventory::Agent::Backend::OS::Linux::Distro::NonLSB::Slackware;
use strict;

sub check {-f "/etc/slackware-version"}

#####
sub findRelease {
  my $v;

  open V, "</etc/slackware-version" or warn;
  chomp ($v=<V>);
  close V;
  $v;
}

sub run {
  my $params = shift;
  my $common = $params->{common};

  my $OSComment;
  chomp($OSComment =`uname -v`);

  $common->setHardware({ 
      OSNAME => findRelease(),
      OSCOMMENTS => "$OSComment"
    });
}


1;
