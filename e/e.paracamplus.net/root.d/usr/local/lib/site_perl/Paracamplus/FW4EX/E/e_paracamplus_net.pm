#! /usr/bin/perl
# -*- coding: utf-8 -*-
package Paracamplus::FW4EX::E::e_paracamplus_net;
use Moose;
use namespace::autoclean;
use utf8;
extends 'Paracamplus::FW4EX::E';
__PACKAGE__->_configureThenRun('/opt/e.paracamplus.net/e.paracamplus.net.yml', 
                               '1209' );
__PACKAGE__->meta->make_immutable;
1;
