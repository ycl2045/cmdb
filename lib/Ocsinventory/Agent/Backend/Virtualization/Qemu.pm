package Ocsinventory::Agent::Backend::Virtualization::Qemu;
# With Qemu 0.10.X, some option will be added to get more and easly information (UUID, memory, ...)

use strict;

sub check { return (can_run('qemu') || can_run('kvm') || can_run('qemu-kvm'))}

sub run {
    my $params = shift;
    my $common = $params->{common};

    foreach ( `ps -ef` ) {
        if (m/^.*((qemu|kvm|(qemu-kvm)).*\-([fh]d[a-d]|drive|cdrom).*)$/) {
            # match only if an qemu instance
            
            my $name = "N/A";
            my $mem = 0;
            my $uuid;
            my $vmtype = $2;
                        
            my @process = split (/ \-/, $1);     #separate options
            
            foreach my $option ( @process ) {
                if ($name eq "N/A" and $option =~ m/^([fh]d[a-d]|cdrom) (\S+)/) {
                    $name = $2;
                } elsif ($option =~ m/^name (\S+)/) {
                    $name = $1;
                } elsif ($option =~ m/^m (\S+)/) {
                    $mem = $1;
                } elsif ($option =~ m/^uuid (\S+)/) {
                    $uuid = $1;
                }
            }
            
            if ($mem == 0 ) {
                # Default value
                $mem = 128;
            }
            
            $common->addVirtualMachine ({
                name      => $name,
                uuid      => $uuid,
                vcpu      => 1,
                memory    => $mem,
                status    => "running",
                subsystem => $vmtype,
                vmtype    => $vmtype,
            });
        }
    }
}

1;
