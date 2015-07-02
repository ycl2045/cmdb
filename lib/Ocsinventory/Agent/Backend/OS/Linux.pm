package Ocsinventory::Agent::Backend::OS::Linux;

use strict;
use vars qw($runAfter);
$runAfter = ["Ocsinventory::Agent::Backend::OS::Generic"];

sub check { $^O =~ /^linux$/ }

sub run {
  my $params = shift;
  my $common = $params->{common};

  chomp (my $osversion = `uname -r`);

  my $lastloggeduser;
  my $datelastlog;
  my @query = runcmd("last -R");
 
  foreach ($query[0]) {
    if ( s/^(\S+)\s+\S+\s+(\S+\s+\S+\s+\S+\s+\S+)\s+.*// ) {
      $lastloggeduser = $1;
      $datelastlog = $2;
    }
  }
  
  # This will probably be overwritten by a Linux::Distro module.
  $common->setHardware({
      osname => "linux",
      oscomments => "unknown linux distribution",
      osversion => $osversion,
      lastloggeduser => $lastloggeduser,
      datelastloggeduser => $datelastlog
    });
}

1;
