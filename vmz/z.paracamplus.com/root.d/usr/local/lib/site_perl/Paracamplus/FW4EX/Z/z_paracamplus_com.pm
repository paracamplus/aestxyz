#! /usr/bin/perl
# -*- coding: utf-8 -*-
package Paracamplus::FW4EX::Z::z_paracamplus_com;
use Moose;
use namespace::autoclean;
use strict;
use utf8;
extends ( 'Paracamplus::FW4EX::Z' );
__PACKAGE__->_configureThenRun('/opt/z.paracamplus.com/z.paracamplus.com.yml', 
                               '1262' );
__PACKAGE__->meta->make_immutable;
1;
