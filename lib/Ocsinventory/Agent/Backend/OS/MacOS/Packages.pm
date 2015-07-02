package Ocsinventory::Agent::Backend::OS::MacOS::Packages;

use strict;
use warnings;

sub check {
    my $params = shift;

    return unless can_load("Mac::SysProfile");
    # Do not run an package inventory if there is the --nosoft parameter
    return if ($params->{config}->{nosoft});

    1;
}

sub run {
    my $params = shift;
    my $common = $params->{common};

    my $profile = Mac::SysProfile->new();
    my $data = $profile->gettype('SPApplicationsDataType'); # might need to check version of darwin

    return unless($data && ref($data) eq 'ARRAY');

    # for each app, normalize the information, then add it to the inventory stack
    foreach my $app (@$data){
        #my $a = $apps->{$app};
        my $kind = $app->{'runtime_environment'} ? $app->{'runtime_environment'} : 'UNKNOWN';
        my $comments = '['.$kind.']';
        $common->addSoftware({
            'name'        => $app->{'_name'},
            'version'     => $app->{'version'} || 'unknown',
            'comments'    => $comments,
            'publisher'   => $app->{'info'} || 'unknown',
			'installdate' => $app->{'lastmodified'},
        });
    }
}

1;
