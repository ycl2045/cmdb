package Ocsinventory::Agent::AccountConfig;
use strict;
use warnings;

# AccountConfig read and write the setting for the client given by the server
# This file will be overwrite and is not designed to be changed by the user

# DESPITE ITS NAME, ACCOUNTCONFIG IS NOT A CONFIG FILE!
use JSON qw( );
use Data::Dumper;

sub new {
    my (undef,$params) = @_;

    my $self = {};
    bless $self;

    $self->{config} = $params->{config};
    my $logger = $self->{logger} = $params->{logger};

    # Configuration reading
    $self->{xml} = {};
    if ($self->{config}->{accountconfig}) {
        if (! -f $self->{config}->{accountconfig}) {
            $logger->debug ('accountconfig file: `'. $self->{config}->{accountconfig}.
                " doesn't exist. I create an empty one");

            $self->write();
        } else {
            $self->read($self->{config}->{accountconfig});
        }
    }

    $self;
}

sub get {
    my ($self, $name) = @_;

    my $logger = $self->{logger};
    return $self->{xml}{CONF}{$name} if $name;
    return $self->{xml};
}

sub set {
    my ($self, $name, $value) = @_;

    my $logger = $self->{logger};

    $self->{xml}->{$name} = $value;
    $self->write(); # save the change
}


sub write {
    my ($self, $args) = @_;

    my $logger = $self->{logger};

    return unless $self->{config}->{accountconfig};
    my %conf;
    $conf{CONF} = $self->{xml};
    my $json_obj = new JSON;
    my $xml = $json_obj->pretty->encode(\%conf);

    #my $xml = XML::Simple::XMLout( $self->{xml} , RootName => 'CONF',
    #    NoAttr => 1 );

    my $fault;
    if (!open CONF, ">".$self->{config}->{accountconfig}) {

        $fault = 1;

    } else {

        print CONF $xml;
        $fault = 1 if (!close CONF);

    }

    if (!$fault) {
        $logger->debug ("ocsinv.conf updated successfully");
    } else {

        $logger->error ("Can't save setting change in `".$self->{config}->{accountconfig}."'");
    }
}


sub read {
    my ($self,$filename) = @_;
    $self->{xml} = {};

    my $json_text ;

    if(open(Myfile,$filename)){

    while(<Myfile>){
       $json_text .= "$_";
    }
    }
    my $json = JSON->new->allow_nonref;
    $self->{xml} = $json->utf8->decode($json_text);
    return $self->{xml}
}
1;
