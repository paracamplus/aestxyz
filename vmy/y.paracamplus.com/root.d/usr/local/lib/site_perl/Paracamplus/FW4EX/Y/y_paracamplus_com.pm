#! /usr/bin/perl
# -*- coding: utf-8 -*-
package Paracamplus::FW4EX::Y::y_paracamplus_com;
use Moose;
use namespace::autoclean;
use strict;
use utf8;
extends ( 'Paracamplus::FW4EX::Y' );
__PACKAGE__->_configureThenRun('/opt/y.paracamplus.com/y.paracamplus.com.yml', 
                               '1262' );
__PACKAGE__->meta->make_immutable;
1;
