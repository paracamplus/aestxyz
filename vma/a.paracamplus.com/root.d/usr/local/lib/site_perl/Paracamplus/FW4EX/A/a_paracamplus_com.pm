#! /usr/bin/perl
# -*- coding: utf-8 -*-
package Paracamplus::FW4EX::A::a_paracamplus_com;
use Moose;
use namespace::autoclean;
use utf8;
extends 'Paracamplus::FW4EX::A';
__PACKAGE__->_configureThenRun('/opt/a.paracamplus.com/a.paracamplus.com.yml', 
                               '1209' );
__PACKAGE__->meta->make_immutable;
1;
