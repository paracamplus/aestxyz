#! /usr/bin/perl
# -*- coding: utf-8 -*-
package Paracamplus::FW4EX::T::t_paracamplus_com;
use Moose;
use namespace::autoclean;
use strict;
use utf8;
extends ( 'Paracamplus::FW4EX::T' );
__PACKAGE__->_configureThenRun('/opt/t.paracamplus.com/t.paracamplus.com.yml', 
                               '1262' );
__PACKAGE__->meta->make_immutable;
1;
