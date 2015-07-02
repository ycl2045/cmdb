package Ocsinventory::Agent::Backend::OS::Linux::Storages::Adaptec;
use Ocsinventory::Agent::Backend::OS::Linux::Storages;

# Tested on 2.6.* kernels
#
# Cards tested :
#
# Adaptec AAC-RAID

use strict;

my @devices = Ocsinventory::Agent::Backend::OS::Linux::Storages::getFromUdev();

sub check {

    if (can_run ('smartctl') ) { 
      foreach my $hd (@devices) {
        $hd->{MANUFACTURER} eq 'Adaptec'?return 1:1;
      }
    }
  return 0;

}

sub run {

  my $params = shift;
  my $common = $params->{common};
  my $logger = $params->{logger};

  if (-r '/proc/scsi/scsi') {
    foreach my $hd (@devices) {
      open (PATH, '/proc/scsi/scsi');

# Example output:
#
# Attached devices:
# Host: scsi0 Channel: 00 Id: 00 Lun: 00
#   Vendor: Adaptec  Model: raid10           Rev: V1.0
#   Type:   Direct-Access                    ANSI  SCSI revision: 02
# Host: scsi0 Channel: 01 Id: 00 Lun: 00
#   Vendor: HITACHI  Model: HUS151436VL3800  Rev: S3C0
#   Type:   Direct-Access                    ANSI  SCSI revision: 03
# Host: scsi0 Channel: 01 Id: 01 Lun: 00
#   Vendor: HITACHI  Model: HUS151436VL3800  Rev: S3C0
#   Type:   Direct-Access                    ANSI  SCSI revision: 03

      my ($host, $model, $firmware, $manufacturer, $size, $serialnumber);
      my $count = -1;
      while (<PATH>) {
        ($host, $count) = (1, $count+1) if /^Host:\sscsi$hd->{SCSI_COID}.*/;
        if ($host) {
          if ((/.*Model:\s(\S+).*Rev:\s(\S+).*/) and ($1 !~ 'raid.*')) {
            $model = $1;
            $firmware = $2;
            $manufacturer = Ocsinventory::Agent::Backend::OS::Linux::Storages::getManufacturer($model);
            foreach (`smartctl -i /dev/sg$count`) {
              $serialnumber = $1 if /^Serial Number:\s+(\S*).*/;
            }
            $logger->debug("Adaptec: $hd->{NAME}, $manufacturer, $model, SATA, disk, $hd->{DISKSIZE}, $serialnumber, $firmware");
            $host = undef;

            $common->addStorages({
                name => $hd->{NAME},
                manufacturer => $manufacturer,
                model => $model,
                description => 'SATA',
                type => 'disk',
                disksize => $size,
                serialnumber => $serialnumber,
                firmware => $firmware,
                });
          }
        }
      }
      close (PATH);
    }
  }

}

1;
