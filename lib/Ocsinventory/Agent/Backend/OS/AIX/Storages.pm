package Ocsinventory::Agent::Backend::OS::AIX::Storages;
use strict;
#use warning;

sub check {
	`which lsdev 2>&1`;
	return if($? >> 8)!=0;
	`which lsattr 2>&1`;
	($? >> 8)?0:1}

sub run {
  my $params = shift;
  my $common = $params->{common};

  my(@disques, $device, $model, $capacity, $description, $manufacturer, $n, $i, $flag, @rep, @scsi, @values, @lsattr, $FRU, $status);
  
  #lsvpd
  my @lsvpd = `lsvpd`;  
  s/^\*// for (@lsvpd);
  
  #SCSI disks 
  $n=0;
  @scsi=`lsdev -Cc disk -s scsi -F 'name:description'`;
  for(@scsi){
	chomp $scsi[$n];
	/^(.+):(.+)/;
	$device=$1;
	$description=$2;
    @lsattr=`lsattr -EOl $device -a 'size_in_mb'`;
	for (@lsattr){
	  if (! /^#/ ){
	    $capacity= $_;
	    chomp($capacity);$capacity =~ s/(\s+)$//;
	  }
	}
	for (@lsvpd){
	  if(/^AX $device/){$flag=1}
	  if ((/^MF (.+)/) && $flag){$manufacturer=$1;chomp($manufacturer);$manufacturer =~ s/(\s+)$//;}
	  if ((/^TM (.+)/) && $flag){$model=$1;chomp($model);$model =~ s/(\s+)$//;}
	  if ((/^FN (.+)/) && $flag){$FRU=$1;chomp($FRU);$FRU =~ s/(\s+)$//;$manufacturer .= ",FRU number :".$FRU}
	  if ((/^FC .+/) && $flag) {$flag=0;last}
	}
	$common->addStorages({
	  name => $device,
	  manufacturer => $manufacturer,
	  model => $model,
	  description => $description,
	  type => 'disk',
	  disksize => $capacity
    });
	$n++;
  }
#Virtual disks
  @scsi= ();
  @lsattr= ();
  $n=0;
  @scsi=`lsdev -Cc disk -s vscsi -F 'name:description'`;
  for(@scsi){
        chomp $scsi[$n];
        /^(.+):(.+)/;
        $device=$1;
        $description=$2;
	@lsattr=`lspv  $device 2>&1`;
	for (@lsattr){
		if ( ! ( /^0516-320.*/ ) )
		{
          		if (/TOTAL PPs:/ ) {
	
				($capacity,$model) = split(/\(/, $_);
				($capacity,$model) = split(/ /,$model);
			}
        	}
		else
		{
			$capacity=0;
		}
	}
        $common->addStorages({
          manufacturer => "VIO Disk",
          model => "Virtual Disk",
          description => $description,
          type => 'disk',
	  name => $device,
          disksize => $capacity
    });
        $n++;
  }



  #CDROM
  @scsi= ();
  @lsattr= ();
  @scsi=`lsdev -Cc cdrom -s scsi -F 'name:description:status'`;
  $i=0;
  for(@scsi){
    chomp $scsi[$i];
    /^(.+):(.+):(.+)/;
    $device=$1;
    $status=$3;
    $description=$2;
    $capacity="";
    if (($status =~ /Available/)){
      @lsattr=`lsattr -EOl $device -a 'size_in_mb'`;
      for (@lsattr){
        if (! /^#/ ){
          $capacity= $_;
          chomp($capacity);$capacity =~ s/(\s+)$//;
        }
      }
      $description = $scsi[$n];
      for (@lsvpd){
		if(/^AX $device/){$flag=1}
		if ((/^MF (.+)/) && $flag){$manufacturer=$1;chomp($manufacturer);$manufacturer =~ s/(\s+)$//;}
		if ((/^TM (.+)/) && $flag){$model=$1;chomp($model);$model =~ s/(\s+)$//;}
		if ((/^FN (.+)/) && $flag){$FRU=$1;chomp($FRU);$FRU =~ s/(\s+)$//;$manufacturer .= ",FRU number :".$FRU}
		if ((/^FC .+/) && $flag) {$flag=0;last}
      }
      $common->addStorages({
	    name => $device,
	    manufacturer => $manufacturer,
	    model => $model,
	    description => $description,
	    type => 'cd',
	    disksize => $capacity
      });
      $n++;
    }
    $i++;
  }

  #TAPE
  @scsi= ();
  @lsattr= ();
  @scsi=`lsdev -Cc tape -s scsi -F 'name:description:status'`;
  $i=0;
  for(@scsi){
    chomp $scsi[$i];
	/^(.+):(.+):(.+)/;
	$device=$1;
	$status=$3;
	$description=$2;
	$capacity="";
	if (($status =~ /Available/)){
      @lsattr=`lsattr -EOl $device -a 'size_in_mb'`;
	  for (@lsattr){
        if (! /^#/ ){
          $capacity= $_;
          chomp($capacity);$capacity =~ s/(\s+)$//;
        }
      }
      for (@lsvpd){
	    if(/^AX $device/){$flag=1}
		if ((/^MF (.+)/) && $flag){$manufacturer=$1;chomp($manufacturer);$manufacturer =~ s/(\s+)$//;}
		if ((/^TM (.+)/) && $flag){$model=$1;chomp($model);$model =~ s/(\s+)$//;}
		if ((/^FN (.+)/) && $flag){$FRU=$1;chomp($FRU);$FRU =~ s/(\s+)$//;$manufacturer .= ",FRU number :".$FRU}
		if ((/^FC .+/) && $flag) {$flag=0;last}
   	  }
   	  $common->addStorages({
	    name => $device,
	    manufacturer => $manufacturer,
	    model => $model,
	    description => $description,
	    type => 'tape',
	    disksize => $capacity
      });
      $n++;
    }
    $i++;
  }

  #Disquette
  @scsi= ();
  @lsattr= ();
  @scsi=`lsdev -Cc diskette -F 'name:description:status'`;
  $i=0;
  for(@scsi){
    chomp $scsi[$i];
    /^(.+):(.+):(.+)/;
    $device=$1;
    $status=$3;
    $description=$2;
    $capacity="";
    if (($status =~ /Available/)){
      @lsattr=`lsattr -EOl $device -a 'fdtype'`;
      for (@lsattr){
        if (! /^#/ ){
          $capacity= $_;
          chomp($capacity);$capacity =~ s/(\s+)$//;
        }
      }
      #On le force en retour taille disquette non affichable
      $capacity ="";
      $common->addStorages({
	    name => $device,
	    manufacturer => 'N/A',
	    model => 'N/A',
	    description => $description,
	    type => 'floppy',
	    disksize => ''
      });
	  $n++;
    }
    $i++;
  }
}

1;
