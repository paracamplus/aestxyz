#! /usr/bin/perl

use diagnostics;
use strict;
use utf8;

use Getopt::Long;
use File::Slurp;
use Paracamplus::FW4EX::XML::toShell;

my $infile;
my $outfile;
my $maxcpu = 10;
my $maxout = 200*1000;
my $maxerr = 50*1000;

my $options = GetOptions(
    'input=s' => \$infile,
    'output=s' => \$outfile,
    'maxcpu=i' => \$maxcpu,
    'maxout=i' => \$maxout,
    'maxerr=i' => \$maxerr,
    );

die "Missing parameter --input" unless defined $infile;
die "Cannot find file $infile!" unless -r $infile;
die "Missing parameter --output" unless defined $outfile;

my $compiler = Paracamplus::FW4EX::XML::toShell->new(
    maxcpu => $maxcpu,
    maxout => $maxout,
    maxerr => $maxerr,
);
my $script = $compiler->compile_file($infile);
write_file($outfile, $script);

# end of exercise-xml2sh.pl
