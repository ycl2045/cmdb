package Ocsinventory::Agent::Backend::OS::Generic::Dmidecode::Memory;
use strict;

sub run {
  my $params = shift;
  my $common = $params->{common};

  my $dmidecode = `dmidecode`; # TODO retrieve error
  # some versions of dmidecode do not separate items with new lines
  # so add a new line before each handle
  $dmidecode =~ s/\nHandle/\n\nHandle/g;
  my @dmidecode = split (/\n/, $dmidecode);
  # add a new line at the end
  push @dmidecode, "\n";

  s/^\s+// for (@dmidecode);

  my $flag;

  my $capacity;
  my $speed;
  my $type;
  my $description;
  my $numslot;
  my $caption;
  my $serialnumber;

  foreach (@dmidecode) {

    if (/dmi type 17,/i) { # begining of Memory Device section
      $flag = 1;
      $numslot++;
    } elsif ($flag && /^$/) { # end of section
      $flag = 0;

      $common->addMemory({

	  capacity => $capacity,
	  description => $description,
	  caption => $caption,
	  speed => $speed,
	  type => $type,
	  numslots => $numslot,
	  serialnumber => $serialnumber,
	});

      $capacity = $description = $caption = $type = $type = $serialnumber = undef;
    } elsif ($flag) { # in the section

      $capacity = $1 if /^size\s*:\s*(\S+)/i;
      $description = $1 if /^Form Factor\s*:\s*(.+)/i;
      $caption = $1 if /^Locator\s*:\s*(.+)/i;
      $speed = $1 if /^speed\s*:\s*(.+)/i;
      $type = $1 if /^type\s*:\s*(.+)/i;
      $serialnumber = $1 if /^Serial Number\s*:\s*(.+)/i;


    }
  }
}

1;
