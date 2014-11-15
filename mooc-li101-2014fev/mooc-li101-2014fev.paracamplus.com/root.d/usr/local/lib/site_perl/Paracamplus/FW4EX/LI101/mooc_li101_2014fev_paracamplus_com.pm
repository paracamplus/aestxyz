#! /usr/bin/perl
# -*- coding: utf-8 -*-
package Paracamplus::FW4EX::LI101::mooc_li101_2014fev_paracamplus_com;
use Moose;
use namespace::autoclean;
use utf8;
extends ( 'Paracamplus::FW4EX::LI101' );
__PACKAGE__->_configureThenRun('/opt/mooc-li101-2014fev.paracamplus.com/mooc-li101-2014fev.paracamplus.com.yml', 
                               '1223' );
__PACKAGE__->meta->make_immutable;
1;
