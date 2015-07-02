package Ocsinventory::Agent::Backend::OS::Linux::Distro::NonLSB::VmWare;
use strict;

sub check { -f "/etc/vmware-release" }

####
sub findRelease {
  my $v;

  open V, "</etc/vmware-release" or warn;
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
      osname => findRelease(),
      oscomments => "$OSComment"
    });
}



1;
