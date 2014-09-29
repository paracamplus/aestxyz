#! /usr/bin/perl
# -*- coding: utf-8 -*-
package Paracamplus::FW4EX::T::t_paracamplus_net;
use Moose;
use namespace::autoclean;
use utf8;
extends 'Paracamplus::FW4EX::T';
__PACKAGE__->_configureThenRun('/opt/t.paracamplus.net/t.paracamplus.net.yml', 
                               '1208' );
__PACKAGE__->meta->make_immutable;
1;
