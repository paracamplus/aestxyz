#! /usr/bin/perl
# -*- coding: utf-8 -*-
package Paracamplus::FW4EX::X::x_paracamplus_net;
use Moose;
use namespace::autoclean;
use utf8;
extends ( 'Paracamplus::FW4EX::X' );
__PACKAGE__->_configureThenRun('/opt/x.paracamplus.net/x.paracamplus.net.yml', 
                               '1212' );
__PACKAGE__->meta->make_immutable;
1;
