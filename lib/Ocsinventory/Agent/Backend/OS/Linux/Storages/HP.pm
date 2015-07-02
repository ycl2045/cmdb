package Ocsinventory::Agent::Backend::OS::Linux::Storages::HP;

use Ocsinventory::Agent::Backend::OS::Linux::Storages;
# Tested on 2.6.* kernels
#
# Cards tested :
#
# Smart Array E200
#
# HP Array Configuration Utility CLI 7.85-18.0

use strict;

sub check {

    my $ret;
# Do we have hpacucli ?
    if (can_run("hpacucli")) {
        foreach (`hpacucli ctrl all show 2> /dev/null`) {
            if (/.*Slot\s(\d*).*/) {
                $ret = 1;
                last;
            }
        }
    }
    return $ret;

}

sub run {


    my $params = shift;
    my $common = $params->{common};
    my $logger = $params->{logger};

    my ($pd, $serialnumber, $model, $capacity, $firmware, $description, $media, $manufacturer);

    foreach (`hpacucli ctrl all show 2> /dev/null`) {

# Example output :
#    
# Smart Array E200 in Slot 2    (sn: PA6C90K9SUH1ZA)

        if (/.*Slot\s(\d*).*/) {

            my $slot = $1;

            foreach (`hpacucli ctrl slot=$slot pd all show 2> /dev/null`) {

# Example output :
                #
# Smart Array E200 in Slot 2
                #
#   array A
                #
#      physicaldrive 2I:1:1 (port 2I:box 1:bay 1, SATA, 74.3 GB, OK)
#      physicaldrive 2I:1:2 (port 2I:box 1:bay 2, SATA, 74.3 GB, OK)

                if (/.*physicaldrive\s(\S*)/) {
                    my $pd = $1;
                    foreach (`hpacucli ctrl slot=$slot pd $pd show 2> /dev/null`) {

# Example output :
#  
# Smart Array E200 in Slot 2
                        #
#   array A
                        #
#      physicaldrive 1:1
#         Port: 2I
#         Box: 1
#         Bay: 1
#         Status: OK
#         Drive Type: Data Drive
#         Interface Type: SATA
#         Size: 74.3 GB
#         Firmware Revision: 21.07QR4
#         Serial Number:      WD-WMANS1732855
#         Model: ATA     WDC WD740ADFD-00
#         SATA NCQ Capable: False
#         PHY Count: 1        

                        $model = $1 if /.*Model:\s(.*)/;
                        $description = $1 if /.*Interface Type:\s(.*)/;
                        $media = $1 if /.*Drive Type:\s(.*)/;
                        $capacity = 1000*$1 if /.*Size:\s(.*)/;
                        $serialnumber = $1 if /.*Serial Number:\s(.*)/;
                        $firmware = $1 if /.*Firmware Revision:\s(.*)/;
                    }
                    $serialnumber =~ s/^\s+//;
                    $model =~ s/^ATA\s+//; # ex: ATA     WDC WD740ADFD-00
                    $model =~ s/\s+/ /;
                    $manufacturer = Ocsinventory::Agent::Backend::OS::Linux::Storages::getManufacturer($model);
                    if ($media eq 'Data Drive') {
                        $media = 'disk';
                    }

                    $logger->debug("HP: N/A, $manufacturer, $model, $description, $media, $capacity, $serialnumber, $firmware");

                    $common->addStorages({
                            name => $model,
                            manufacturer => $manufacturer,
                            model => $model,
                            description => $description,
                            type => $media,
                            disksize => $capacity,
                            serialnumber => $serialnumber,
                            firmware => $firmware
                        }); 
                }
            }
        }
    }
}

1;
