package Ocsinventory::Agent::Backend::OS::AIX::Software;

use strict;
use warnings;

sub check {
  my $params = shift;

  # Do not run an package inventory if there is the --nosoft parameter
  return if ($params->{config}->{nosoft});

  return unless can_run("lslpp");
  1;
}

sub run {
  my $params = shift;
  my $common = $params->{common};

  my @list;
  my $buff;
  foreach (`lslpp -c -l`) {
    my @entry = split /:/,$_;
    next unless (@entry);
    next unless ($entry[1]);
    next if $entry[1] =~ /^device/;

    $common->addSoftware({
	'comments'      => $entry[6],
	'folder'	=> $entry[0],
	'name'          => $entry[1],
	'version'       => $entry[2],
	});
  }
}

1;
