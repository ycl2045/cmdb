package Ocsinventory::Agent::Backend::OS::Linux::LVM;

use strict;
use vars qw($runAfter);
$runAfter = ["Ocsinventory::Agent::Backend::OS::Linux::Drives"];

sub check {
  return unless can_run ("pvs");
  1
}

sub run {
my $params = shift;
my $common = $params->{common};

use constant mb => (1024*1024);

if (can_run('pvs')) {
	foreach (`pvs --noheading --nosuffix --units b -o +pv_uuid`) {
		chomp;
		$_ =~s/^\s+//;
		my @vs_elem=split('\s+');
		my $status='VG: '.$vs_elem[1].', Fmt: '.$vs_elem[2].', Attr: '.$vs_elem[3];
		$common->addDrive({
			free => $vs_elem[5]/mb,
			filesystem => 'lvm pv',
			total => $vs_elem[4]/mb,
			type => $vs_elem[0],
			volumn => $status,
			serial => $vs_elem[6]
        });
	}
}

if (can_run('vgs')) {
	foreach (`vgs --noheading --nosuffix --units b -o +vg_uuid,vg_extent_size`) {
		chomp;
		$_ =~s/^\s+//;
		my @vs_elem=split('\s+');
		my $status = 'PV/LV: '.$vs_elem[1].'/'.$vs_elem[2]
			.', Attr: '.$vs_elem[4].', PE: '.($vs_elem[8]/mb).' MB';
		$common->addDrive({
			free => $vs_elem[6]/mb,
			filesystem => 'lvm vg',
			total => $vs_elem[5]/mb,
			type => $vs_elem[0],
			volumn => $status,
			serial => $vs_elem[7]
        });
	}
}

if (can_run('lvs')) {
	foreach (`lvs -a --noheading --nosuffix --units b -o lv_name,vg_name,lv_attr,lv_size,lv_uuid,seg_count`) {
		chomp;
		$_ =~s/^\s+//;
		my @vs_elem=split('\s+');
		my $status='Attr: '.$vs_elem[2].', Seg: '.$vs_elem[5];
		$common->addDrive({
			free => 0,
			filesystem => 'lvm lv',
			total => $vs_elem[3]/mb,
			type => $vs_elem[1].'/'.$vs_elem[0],
			volumn => $status,
			serial => $vs_elem[4]
        });
	}
}

}	
1;
