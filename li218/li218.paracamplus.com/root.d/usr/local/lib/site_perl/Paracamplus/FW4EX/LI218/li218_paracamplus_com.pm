#! /usr/bin/perl
# -*- coding: utf-8 -*-
package Paracamplus::FW4EX::LI218::li218_paracamplus_com;
use Moose;
use namespace::autoclean;
use utf8;
extends ( 'Paracamplus::FW4EX::LI218' );
__PACKAGE__->_configureThenRun('/opt/li218.paracamplus.com/li218.paracamplus.com.yml', 
                               '1249' );
__PACKAGE__->meta->make_immutable;
1;
