package Ocsinventory::Agent::Backend::OS::Solaris::Packages;

use strict;
use warnings;

sub check {
  my $params = shift;

  # Do not run an package inventory if there is the --nosoft parameter
  return if ($params->{config}->{nosoft});

  can_run("pkginfo");
}

sub run {
  my $params = shift;
  my $common = $params->{common};
  my $chaine ;
  my @tab;

  my $name;
  my $version;
  my $comments;
  my $publisher;
  foreach (`pkginfo -l`) {
    if (/^\s*$/) {
      $common->addSoftware({
          'name'          => $name,
          'version'       => $version,
          'comments'      => $comments,
          'publisher'      => $publisher,
          });

      $name = '';
      $version = '';
      $comments = '';
      $publisher = '';

    } elsif (/PKGINST:\s+(.+)/) {
      $name = $1;
    } elsif (/VERSION:\s+(.+)/) {
      $version = $1;
    } elsif (/VENDOR:\s+(.+)/) {
      $publisher = $1;
    } elsif (/DESC:\s+(.+)/) {
      $comments = $1;
    }
  }
  my $testrep;
  $testrep=0;
  #opendir(DIR,'/var/sis/') || exit ;
  opendir(DIR,'/var/sis/') || ($testrep=1) ;
  if ($testrep==0)
  {
	
	
	  foreach (`ls /var/sis/*.SIS`)
	  {
		$chaine= `cat $_` ;
		@tab = split(/;/, $chaine);
		if (/^\/var\/sis\/(\S+).SIS/){
				$common->addSoftware({
					'version'       => $tab[2],
					'name'          => $tab[0]." ($1)",
					'publisher'     => $tab[1],
					'comments' 		=> $1,
				});
			}
		
	  }
  }
  closedir(DIR);
}

1;
