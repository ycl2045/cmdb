package Ocsinventory::Agent::Backend::OS::Generic::Dmidecode::UUID;

use strict;

sub check { return can_run('dmidecode') }

sub run {
  my $params = shift;
  my $common = $params->{common};

  my $uuid;

  $uuid = `dmidecode -s system-uuid`;
  chomp($uuid);
  $uuid =~ s/^#+\s+$//g;

   $common->setHardware({
      uuid => $uuid,
   });

}

1;
