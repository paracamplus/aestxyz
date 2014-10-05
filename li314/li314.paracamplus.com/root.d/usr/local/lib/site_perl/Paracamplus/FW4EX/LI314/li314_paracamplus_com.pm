#! /usr/bin/perl
# -*- coding: utf-8 -*-
package Paracamplus::FW4EX::LI314::li314_paracamplus_com;
use Moose;
use namespace::autoclean;
use utf8;
extends ( 'Paracamplus::FW4EX::LI314' );
__PACKAGE__->_configureThenRun('/opt/li314.paracamplus.com/li314.paracamplus.com.yml', 
                               '1210' );
__PACKAGE__->meta->make_immutable;
1;
