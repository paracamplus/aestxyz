#! /usr/bin/perl
# -*- coding: utf-8 -*-
package Paracamplus::FW4EX::Y::vmy_paracamplus_net;
use Moose;
use namespace::autoclean;
use utf8;
extends 'Paracamplus::FW4EX::Y';
__PACKAGE__->_configureThenRun('/opt/vmy.paracamplus.net/vmy.paracamplus.net.yml', 
                               '1209' );
__PACKAGE__->meta->make_immutable;
1;
