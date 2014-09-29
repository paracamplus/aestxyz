# -*- coding: utf-8 -*-
package Paracamplus::FW4EX::T;
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

=head1 NAME

Paracamplus::FW4EX::T - Catalyst based application

=head1 SYNOPSIS

    script/paracamplus_fw4ex_t_server.pl

=head1 DESCRIPTION

This is the server for teachers.

=head1 SEE ALSO

L<Paracamplus::FW4EX::T::Controller::Root>, L<Catalyst>

=head1 AUTHOR

Christian Queinnec,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
