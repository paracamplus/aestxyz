#! /usr/bin/perl
# -*- coding: utf-8 -*-

package Paracamplus::FW4EX::Y;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

use strict;
use warnings;
use utf8;

use Catalyst::Runtime 5.80;
use Sys::Hostname;

extends 'Catalyst';
use Catalyst (
#              '-Debug',
              'ConfigLoader',
#              'Log::Handler',
              'Static::Simple',
#              'Unicode::Encoding',
);

my $verbose = 0;

sub _configureThenRun {
    my ($self, $configFile, $version) = @_;
    die "Missing $configFile!" if ! -r $configFile;
    __PACKAGE__->config('Plugin::ConfigLoader' => {
        driver => {
            'General' => { -UTF8 => 1 },
        },
        file => $configFile });
    __PACKAGE__->config('VERSION' => $version);

    if ( __PACKAGE__->config->{verbose} ) {
        $verbose = __PACKAGE__->config->{verbose};
    }

    if ( __PACKAGE__->config->{testing} ) {
        print STDERR "Setting debug mode!\n";
        eval "   sub __PACKAGE__::debug { 1 };    ";
    }

    # Start the application
    __PACKAGE__->setup;
}

1;

# end of Y.pm
