package Ocsinventory::Agent::Backend::OS::Linux::Archs::i386::CPU;

use strict;

use Config;

sub check { can_read("/proc/cpuinfo"); can_run("arch"); }

sub run {

    my $params = shift;
    my $common = $params->{common};

    my @cpu;
    my $current;
    my $cpuarch = `arch`;
    chomp($cpuarch);
    my $cpusocket;
    my $siblings;
    my $cpucores;
    my $cpuspeed;
    my $coreid;

	$cpucores=0;
	$siblings=0;
    open CPUINFO, "</proc/cpuinfo" or warn;
    foreach(<CPUINFO>) {

        if (/^vendor_id\s*:\s*(Authentic|Genuine|)(.+)/i) {
			$cpucores++;
            $current->{manufacturer} = $2;
            $current->{manufacturer} =~ s/(TMx86|TransmetaCPU)/Transmeta/;
            $current->{manufacturer} =~ s/CyrixInstead/Cyrix/;
            $current->{manufacturer} =~ s/CentaurHauls/VIA/;
        }

        if (/^siblings\s*:\s*(\d+)/i){
			$siblings++;
		}
		$current->{current_speed} = $1 if /^cpu\sMHz\s*:\s*(\d+)/i;
        $current->{type} = $1 if /^model\sname\s*:\s*(.+)/i;
	    $current->{l2cachesize} = $1 if /^cache\ssize\s*:\s*(\d+)/i;
    }

	# /proc/cpuinfo provides real time speed processor.
	# Get optimal speed with dmidecode command
  	# Get also cpu cores with dmidecode command
  	# Get also voltage information with dmidecode command
   	@cpu = `dmidecode -t processor`;
	$cpuspeed=0;
	$cpusocket=0;
   	for (@cpu){
		if (/Processor\sInformation/i){
			if ($cpusocket > 0) {
				$common->addCPU($current);
			}
			$cpusocket++;
			if ($cpuspeed != 0){
				if ($cpusocket > $cpucores) {
					last;
				}
			}
			$cpuspeed=0;
		}	
    	if (/Current\sSpeed:\s*(.*) (|MHz|GHz)/i){
			$cpuspeed = $1;
            $current->{speed} = $cpuspeed;
		}
        if (/Core\sCount:\s*(\d+)/i){
            $current->{cores} = $1;
        } else {
			$current->{cores} = $cpucores;
		}
    	# Is(Are) CPU(s) hyperthreaded?
    	if ($siblings == $current->{cores}) {
       		# Hyperthreading is off
       		$current->{hpt}='on';
    	} else {
       		# Hyperthreading is on
       		$current->{hpt}='off';
    	}
        if (/Voltage:\s*(.*)V/i){
            $current->{voltage} = $1;
        }
		if (/Status:\s*(.*)/i){
			$current->{cpustatus} = $1;
		}
		if (/Status:\s*(.*),\s(.*)/i){
            $current->{cpustatus} = $2;
        }
        if (/Upgrade:\s*(.*)/i){
            $current->{socket} = $1;
        }

    	$current->{cpuarch}=$cpuarch;
		if ($cpuarch eq "x86_64"){
			$current->{data_width}=64;
    	} else {
			$current->{data_width}=32;
    	}
		
		$current->{nbsocket} = $cpusocket;
    }
	$common->addCPU($current);

}

1
