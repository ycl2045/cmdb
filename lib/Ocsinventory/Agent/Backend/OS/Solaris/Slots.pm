package Ocsinventory::Agent::Backend::OS::Solaris::Slots;

use strict;
sub check { can_run ("prtdiag") }

sub run {
  my $params = shift;
  my $common = $params->{common};

  my $description;
  my $designation;
  my $name;
  my $status;  
  my @pci;
  my $flag;
  my $flag_pci;
  my $model;
  my $sun_class;

  $model=`uname -i`;
  # debug print model
  #print "Model: '$model'";
  # cut the CR from string model
  $model = substr($model, 0, length($model)-1);
  # we map (hopfully) our server model to a known class
  if ($model eq "SUNW,SPARC-Enterprise") { $sun_class = 1; }
  if ($model eq "SUNW,SPARC-Enterprise-T5120") { $sun_class = 2 ; }
  else { $sun_class = 0; }
  #Debug
  #print "sun_class : $sun_class\n";


    foreach (`prtdiag `) {
    #print $_."\n";
 
   if ( $sun_class == 0 )
   {
    last if(/^\=+/ && $flag_pci);
    next if(/^\s+/ && $flag_pci);
    if($flag && $flag_pci && /^(\S+)\s+/){
      $name = $1;
    }
    if($flag && $flag_pci && /(\S+)\s*$/){
      $designation = $1;
    }
    if($flag && $flag_pci && /^\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+(\S+)/){
      $description = $1;
    }
    if($flag && $flag_pci && /^\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+(\S+)/){
      $status = $1;
    }
    if($flag && $flag_pci){
      $common->addSlot({
          DESCRIPTION =>  $description,
          DESIGNATION =>  $designation,
          NAME            =>  $name,
          STATUS          =>  $status,
          });
    }
    if(/^=+\s+IO Cards/){$flag_pci = 1;}
    if($flag_pci && /^-+/){$flag = 1;}

   }
   
   if ( $sun_class == 1 )
   {
	last if(/^\=+/ && $flag_pci && $flag);
	
	if($flag && $flag_pci && /^\s+(\d+)/){
           $name = "LSB " . $1;	 
	}
 	if($flag && $flag_pci && /^\s+\S+\s+(\S+)/){
                $description = $1;
        }
        if($flag && $flag_pci && /^\s+\S+\s+\S+\s+(\S+)/){
                $designation = $1;
        }
	$status = " ";
	
	#Debug
	#if ($flag && $flag_pci){print "$name" . "||||" . "$designation" . "||" . "$description\n";}
    	#print $_."\n";

        if($flag && $flag_pci){
        $common->addSlot({
          DESCRIPTION =>  $description,
          DESIGNATION =>  $designation,
          NAME            =>  $name,
          STATUS          =>  $status,
          });
        }
        if(/^=+\S+\s+IO Cards/){$flag_pci = 1;  }
        if($flag_pci && /^-+/){$flag = 1;}
   }
   if ( $sun_class == 2 )
   {
	if (/pci/)
	{
	@pci = split(/ +/);
	$name=$pci[4]." ".$pci[5];
	$description=$pci[0]." (".$pci[1].")";
	$designation=$pci[3];
	$status="";
	$common->addSlot({
          DESCRIPTION =>  $description,
          DESIGNATION =>  $designation,
          NAME            =>  $name,
          STATUS          =>  $status,
          });
	
	}
	
   }
  }
}
1;
