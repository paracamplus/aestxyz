#! /usr/bin/perl
# -*- coding: utf-8 -*-
package Paracamplus::FW4EX::A::a_paracamplus_net;
use Moose;
use namespace::autoclean;
use utf8;
extends ( 'Paracamplus::FW4EX::A' );
__PACKAGE__->_configureThenRun('/opt/a.paracamplus.net/a.paracamplus.net.yml', 
                               '1211' );
__PACKAGE__->meta->make_immutable;
1;
