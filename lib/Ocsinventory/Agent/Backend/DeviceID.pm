package Ocsinventory::Agent::Backend::DeviceID;

# Initialise the DeviceID. In fact this value is a bit specific since
# it generates in the main script.
sub run {
  my $params = shift;
  my $common = $params->{common};
  my $config = $params->{config};

  my $UsersLoggedIn = join "/", keys %user;

  if ($config->{old_deviceid}) {
    $common->setHardware({ old_deviceid => $config->{old_deviceid} });
  }
  $common->setHardware({ deviceid => $config->{deviceid} });

}

1;
