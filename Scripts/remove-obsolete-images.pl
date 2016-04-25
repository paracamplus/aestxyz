#! /usr/bin/perl
# Determine obsolete docker images and generate shell commands

open(IN, "docker images |") || die "Cannot run docker images";

my %REPOSITORY;
while ( <IN> ) {
    chomp;
    next if /^REPOSITORY/; # skip 1st line

    if ( /^([^ ]+)\s+([^ ]+)\s+(\w+)\s+/ ) {
        my ($repository, $tag, $imageid) = ($1, $2, $3);
        if ( defined $REPOSITORY{$repository} ) {
            # There is a more recent image so remove the oldest one:
            print "docker rmi $imageid # $repository:$imageid \n";
        } else {
            # Keep this first encountered image:
            $REPOSITORY{$repository} = $imageid;
            if ( $repository =~ m@^www.paracamplus.com:5000/(.*)$@ ) {
                # but if it comes from the private repository, mark
                # those coming from dockerhub.io as obsolete:
                my $alternateRepository = $1;
                $REPOSITORY{$alternateRepository} = $imageid;
            }
            print "echo \"# Keeping $repository:$imageid\"\n";
        }
    } else {
        die "Cannot parse $_";
    }
}

# end of remove-obsolete-images.pl
