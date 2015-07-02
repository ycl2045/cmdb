package Ocsinventory::Agent::XML::Inventory;
# TODO: resort the functions
use strict;
use warnings;
use JSON;
use Data::Dumper;

=head1 NAME

Ocsinventory::Agent::XML::Inventory - the XML abstraction layer

=head1 DESCRIPTION

OCS Inventory uses XML for the data transmition. The module is the
abstraction layer. It's mostly used in the backend module where it
called $inventory in general.

=cut

use XML::Simple;
use Digest::MD5 qw(md5_base64);
use Config;

use Ocsinventory::Agent::Backend;

=over 4

=item new()

The usual constructor.

=cut
sub new {
  my (undef, $params) = @_;

  my $self = {};
  $self->{accountinfo} = $params->{context}->{accountinfo};
  $self->{accountconfig} = $params->{context}->{accountconfig};
  $self->{backend} = $params->{backend};
  $self->{common} = $params->{context}->{common};

  my $logger = $self->{logger} = $params->{context}->{logger};
  $self->{config} = $params->{context}->{config};

  if (!($self->{config}{deviceid})) {
    $logger->fault ('deviceid unititalised!');
  }


  #$self->{xmlroot}{CONTENT}{HARDWARE} = {
    # TODO move that in a backend module
   # ARCHNAME => [$Config{archname}]
  #};

  # Is the XML centent initialised?
  $self->{isInitialised} = undef;

  bless $self;
}

=item initialise()

Runs the backend modules to initilise the data.

=cut
sub initialise {
  my ($self) = @_;

  return if $self->{isInitialised};

  $self->{backend}->feedInventory ({inventory => $self});
  $self->{isInitialised} = 1;

}


=item getContent()

Return the inventory as a XML string.

=cut
sub getContent {
  my $json = JSON->new->allow_nonref;
  my ($self, $args) = @_;

  my $logger = $self->{logger};
  my $common = $self->{common};

  if ($self->{isInitialised}) {
    $self->processChecksum();

    #  checks for MAC, NAME and SSN presence
    my $macaddr = $self->{xmlroot}->{base_networks}[0]->{macaddr};
    my $ssn = $self->{xmlroot}->{base_bios}->{ssn};
    my $name = $self->{xmlroot}->{base_hardware}->{name};

    my $missing;

    $missing .= "MAC-address " unless $macaddr;
    $missing .= "SSN " unless $ssn;
    $missing .= "HOSTNAME " unless $name;

    if ($missing) {
      $logger->debug('Missing value(s): '.$missing.'. I will send this inventory to the server BUT important value(s) to identify the computer are missing');
    }
  $self->{xmlroot}{_metadata}{deviceid} = $self->{config}->{deviceid};
  $self->{xmlroot}{_metadata}{version} = "1.0";

  $self->{accountinfo}->setAccountInfo($self);

    #my $content = XMLout( $self->{xmlroot},RootName=>'content', XMLDecl => '<?xml version="1.0" encoding="UTF-8"?>', SuppressEmpty => undef );
    
    #Cleaning XML to delete unprintable characters
    #my $clean_content=$common->cleanXml($content);

    #Cleaning xmltags content after adding it o inventory
    $common->flushXMLTags();
    #print Dumper($self->{xmlroot});
    my $clean_content = $json->encode($self->{xmlroot});
    return $clean_content;
  }
}

=item printXML()

Only for debugging purpose. Print the inventory on STDOUT.

=cut
sub printXML {
  my ($self, $args) = @_;

  if ($self->{isInitialised}) {
    print $self->getContent();
  }
}

=item writeXML()

Save the generated inventory as an XML file. The 'local' key of the config
is used to know where the file as to be saved.

=cut
sub writeXML {
  my ($self, $args) = @_;

  my $logger = $self->{logger};

  if ($self->{config}{local} =~ /^$/) {
    $logger->fault ('local path unititalised!');
  }

  if ($self->{isInitialised}) {

    my $localfile = $self->{config}{local}."/".$self->{config}{deviceid}.'.json';
    $localfile =~ s!(//){1,}!/!;

    # Convert perl data structure into xml strings

    if (open OUT, ">$localfile") {
      print OUT $self->getContent();
      close OUT or warn;
      $logger->info("Inventory saved in $localfile");
    } else {
      warn "Can't open `$localfile': $!"
    }
  }
}

=item processChecksum()

Compute the <CHECKSUM/> field. This information is used by the server to
know which parts of the XML have changed since the last inventory.

The is done thank to the last_file file. It has MD5 prints of the previous
inventory. 

=cut
sub processChecksum {
  my $self = shift;
  my $logger = $self->{logger};
  my $common = $self->{common};

#To apply to $checksum with an OR
  my %mask = (
    'HARDWARE'      => 1,
    'BIOS'          => 2,
    'MEMORIES'      => 4,
    'SLOTS'         => 8,
    'REGISTRY'      => 16,
    'CONTROLLERS'   => 32,
    'MONITORS'      => 64,
    'PORTS'         => 128,
    'STORAGES'      => 256,
    'DRIVES'        => 512,
    'INPUT'         => 1024,
    'MODEMS'        => 2048,
    'NETWORKS'      => 4096,
    'PRINTERS'      => 8192,
    'SOUNDS'        => 16384,
    'VIDEOS'        => 32768,
    'SOFTWARES'     => 65536,
    'VIRTUALMACHINES' => 131072,
    'CPUS'          => 262144,
  );
  # TODO CPUS is not in the list

  if (!$self->{config}->{vardir}) {
    $logger->fault ("vardir uninitialised!");
  }

  my $checksum = 0;

  if (!$self->{config}{local} && $self->{config}->{last_statefile}) {
    if (-f $self->{config}->{last_statefile}) {
      # TODO: avoid a violant death in case of problem with XML
      $self->{last_state_content} = XML::Simple::XMLin(

        $self->{config}->{last_statefile},
        SuppressEmpty => undef,
        ForceArray => 1

      );
    } else {
      $logger->debug ('last_state file: `'.
  	$self->{config}->{last_statefile}.
  	"' doesn't exist (yet).");
    }
  }

  foreach my $section (keys %mask) {
    #If the checksum has changed...
    my $hash = md5_base64(XML::Simple::XMLout($self->{xmlroot}{$section}));
    if (!$self->{last_state_content}->{$section}[0] || $self->{last_state_content}->{$section}[0] ne $hash ) {
      $logger->debug ("Section $section has changed since last inventory");
      #We make OR on $checksum with the mask of the current section
      $checksum |= $mask{$section};
      # Finally I store the new value.
      $self->{last_state_content}->{$section}[0] = $hash;
    }
  }

  $common->setHardware({CHECKSUM => $checksum});
}

=item saveLastState()

At the end of the process IF the inventory was saved
correctly, the last_state is saved.

=cut
sub saveLastState {
  my ($self, $args) = @_;

  my $logger = $self->{logger};

  if (!defined($self->{last_state_content})) {
	  $self->processChecksum();
  }

  if (!defined ($self->{config}->{last_statefile})) {
    $logger->debug ("Can't save the last_state file. File path is not initialised.");
    return;
  }

  if (open LAST_STATE, ">".$self->{config}->{last_statefile}) {
    print LAST_STATE my $string = XML::Simple::XMLout( $self->{last_state_content}, RootName => 'LAST_STATE' );;
    close LAST_STATE or warn;
  } else {
    $logger->debug ("Cannot save the checksum values in ".$self->{config}->{last_statefile}.":$!");
  }
}

=item addSection()

A generic way to save a section in the inventory. Please avoid this
solution.

=cut
sub addSection {
  my ($self, $args) = @_;
  my $logger = $self->{logger};
  my $multi = $args->{multi};
  my $tagname = $args->{tagname};

  for( keys %{$self->{xmlroot}} ){
    if( $tagname eq $_ ){
      $logger->debug("Tag name `$tagname` already exists - Don't add it");
      return 0;
    }
  }

  if($multi){
    $self->{xmlroot}{$tagname} = [];
  }
  else{
    $self->{xmlroot}{$tagname} = {};
  }
  return 1;
}

=item feedSection()

Add information in inventory.

=back
=cut
# Q: is that really useful()? Can't we merge with addSection()?
sub feedSection{
  my ($self, $args) = @_;
  my $tagname = $args->{tagname};
  my $values = $args->{data};
  my $logger = $self->{logger};

  my $found=0;
  for( keys %{$self->{xmlroot}} ){
    $found = 1 if $tagname eq $_;
  }

  if(!$found){
    $logger->debug("Tag name `$tagname` doesn't exist - Cannot feed it");
    return 0;
  }

  if( $self->{xmlroot}{$tagname} =~ /ARRAY/ ){
    push @{$self->{xmlroot}{$tagname}}, $args->{data};
  }
  else{
    $self->{xmlroot}{$tagname} = $values;
  }

  return 1;
}

1;
