package Ocsinventory::Agent::Backend::OS::Generic::Users;

sub check {
# Useless check for a posix system i guess
  my @who = `who 2>/dev/null`;
  return 1 if @who;
  return;
}

# Initialise the distro entry
sub run {
  my $params = shift;
  my $common = $params->{common};

  # Logged on users
  for(`cat /etc/passwd`){
    my($user, $passwd, $uid, $gid, $gcos, $home, $shell) = split(/:/);
    $common->addUser ({ login => $user,
    uid=>$uid,
    gid=>$gid,
    comment=>$gcos,
    home=>$home,
    shell=>$shell,
    });
  }

}

1;
