#! /usr/bin/perl
# -*- coding: utf-8 -*-
package Paracamplus::FW4EX::X::x_paracamplus_com;
use Moose;
use namespace::autoclean;
use utf8;
extends ( 'Paracamplus::FW4EX::X' );
__PACKAGE__->_configureThenRun('/opt/x.paracamplus.com/x.paracamplus.com.yml', 
                               '1209' );
__PACKAGE__->meta->make_immutable;
1;
