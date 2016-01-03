#! /usr/bin/perl
# -*- coding: utf-8 -*-

package Paracamplus::FW4EX::P;
use Moose;
use namespace::autoclean;
use strict;
use utf8;

BEGIN { extends 'Paracamplus::FW4EX::GenericApp' };
Paracamplus::FW4EX::GenericApp::_initiate(__PACKAGE__);

1;
