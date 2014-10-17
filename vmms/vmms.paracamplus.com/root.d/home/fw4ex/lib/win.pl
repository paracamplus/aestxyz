#! /usr/bin/perl

use diagnostics;
diagnostics::enable();
use strict;

=head1 NAME

 win - produce a mark

=head1 SYNOPSIS

A single argument is a formula to evaluate:

 win.pl 1/2                                      # yields 0.5
 win.pl 1.3/3                                    # yields 0.43

More than one argument is a parameterized shape followed by a number.
Here the shape is triangular:

 win.pl triangular 0 10 50 100 -- 0              # yields 0
 win.pl triangular 0 10 50 1000 -- 5             # yields 500
 win.pl triangular 0 10 50 1000 -- 10            # yields 1000
 win.pl triangular 0 10 50 1000 -- 30            # yields 500
 win.pl triangular 0 10 50 1000 -- 50            # yields 0

Formulas may be used everywhere:

 win.pl triangular 1-1 100/10 100/2 '10*100' -- '7*11'    # yields 0
 
=head1 DESCRIPTION

This program takes some arguments and produces a mark onto its
standard output. It basically takes the description of a function (say
C<f>) followed by a number (say C<x>) then computes and emits C<f(x)>.

The emitted mark is always limited to at most two decimals.

Some shapes are predefined. They are described below.

=cut

my $usage = "
$0 formula
Calcule la valeur de <formula>

$0 shape shapeParameters -- numbers
Calcule la valeur associee a <numbers> suivant la forme <shape> dument
parametree par <shapeParameters>. Parmi les formes existent:
   equal xmed ymax                            -- x
   triangular xmin xmed xmax ymax             -- x
";

# Limiter a 2 decimales seulement l'impression de la note.

sub emit {
    my ($result) = @_;
    if ( $result =~ /^ *(-?)(\d*)((\.\d\d?)(\d*)?)? *$/ ) {
        my ($sign, $int, $frac) = ($1, $2, $4);
        $frac = '' unless defined $frac;
        $result = "$sign$int$frac";
    }
    print $result;
}

# La copie d'un etudiant mene a un nombre x. La note attribuee (y) est
# calculee a partir de ce nombre x et d'une formule parametree. Toutes
# les formules parametrees retournent une fonction prenant x et
# calculant y. Le mecanisme supporte un nombre quelconque de
# parametres pour la forme.

my $withinShape = 1;
my $shape;
my @parameters;
my @x;

if ( scalar(@ARGV) == 1 ) {
    my $option = $ARGV[0];
    # S'il y a un unique argument, c'est une formule a simplement evaluer.
    emit(_solve($option));
    exit;
}

foreach my $option ( @ARGV ) {
    if ( $withinShape ) {
        if ( !defined $shape ) {
            # Le premier argument obligatoire designe la forme:
            $shape = $option;
        } elsif ( $option eq '--' ) {
            # -- introduit le(s) nombre(s) definissant la copie de l'etudiant
            $withinShape = 0;
        } else {
            # ces nombres sont les parametres de la forme:
            push(@parameters, $option);
        }
    } else {
        push(@x, $option);
    }
}

die "No shape given!" if ! defined $shape;
die "Unknown shape: $shape!" if
  $shape !~ /^(compute|equal|triangular)$/;
die "No '-- x' given!" if 0 == scalar(@x);

no strict 'refs';
my $fn = &{$shape}(@parameters);
my $result = &{$fn}(@x);
emit($result);
use strict;

# La forme compute simule la commande expr avec une expression Perl
# pouvant notamment contenir des flottants. Attention, du fait des
# conventions syntaxiques, il faut ecrire:
#      win.pl compute -- 3.14/2.78

sub compute {
    return sub {
        my ($expression) = @_;
        die "compute requires 1 parameter!" if !defined($expression);
        return _solve($expression);
    }
}

sub _solve {
    my ($expression) = @_;
    my $result = 0;
    eval {
        $result = eval($expression);
    };
    die "$@" if "$@";
    return $result;
}

=head1 SHAPE equal

The C<equal> shape is a kind of finite Dirac. The command looks like:

 win.pl equal xmed ymax -- x

If C<x> is equal to C<xmed> then the C<ymax> mark is emitted otherwise
the won mark is C<0>.

=cut

# La forme equal n'accepte que la valeur attendue (xmed) et lui donne
# le maximum de points obtenables (ymax). C'est une sorte de Dirac!

sub equal {
    my ($xmed, $ymax) = @_;
    die "equal requires 2 parameters!" if
      !defined($xmed) or !defined($ymax);
    $xmed = _solve($xmed);
    $ymax = _solve($ymax);

    return sub {
        my ($x) = @_;
        die "Missing x!" if !defined($x);
        $x = _solve($x);
        if ( $x == $xmed ) {
            return $ymax;
        } else {
            return 0;
        }
    }
}

=head1 SHAPE triangular

The C<triangular> shape looks like:

   y
   ^
   |
  ymax         +
   |          / \
   |         /   \
   |        /     \
   |       /       \
   +----min---med---max----->x

The command looks like:

 win.pl triangular xmin xmed xmax ymax -- x

The maximal mark is C<ymax> and is won when C<x> is equal to C<xmed>.
Out of the interval [C<xmin>, C<xmax>], the emitted mark is C<0>.
Otherwise the won mark is linearly interpolated.

One may parameterize the shape with C<xmin> = C<xmed> or C<xmed> =
C<xmax>. Use the shape C<equal> when C<xmin> = C<xmed> = C<xmax>.

=cut

# La forme triangular accepte des petites variations autour de la
# valeur attendue (xmed) et produit une petite variation autour du
# nombre de points maximal obtenable (ymax). Il est possible que
# min = med ou med = max (si min = med = max alors utiliser la forme
# equal). 

sub triangular {
    my ($xmin, $xmed, $xmax, $ymax) = @_;
    die "triangular requires 4 parameters!" if
      !defined($xmin) or !defined($xmed) or !defined($xmax) or !defined($ymax);
    $xmin = _solve($xmin);
    $xmed = _solve($xmed);
    $xmax = _solve($xmax);
    $ymax = _solve($ymax);

    return sub {
        my ($x) = @_;
        die "Missing x!" if !defined($x);
        $x = _solve($x);
        my $d;

        if ( $x < $xmin or $x > $xmax ) {
            return 0;
        } elsif ( $x < $xmed ) {
            $d = $xmed - $x;
            return $ymax * (1.0 - $d/($xmed-$xmin));
        } else {
            $d = $x - $xmed;
            return $ymax * (1.0 - $d/($xmax-$xmed));
        }
    }
}

=head1 SHAPE rectangular

The C<rectangular> shape looks like:

   y
   ^
   |
  ymax   +----------+
   |     |          |
   |     |          |
   |     |          |
   |     |          |
   +----min---------max----->x

The command looks like:

 win.pl rectangular xmin xmax ymax -- x

The maximal mark is C<ymax> and is won when C<x> is between C<xmin>
and C<xmax>. Out of the interval [C<xmin>, C<xmax>], the emitted mark
is C<0>. 

=cut

sub rectangular {
    my ($xmin, $xmax, $ymax) = @_;
    die "rectangular requires 3 parameters!" if
      !defined($xmin) or !defined($xmax) or !defined($ymax);
    $xmin = _solve($xmin);
    $xmax = _solve($xmax);
    $ymax = _solve($ymax);

    return sub {
        my ($x) = @_;
        die "Missing x!" if !defined($x);
        $x = _solve($x);
        my $d;

        if ( $x < $xmin or $x > $xmax ) {
            return 0;
        } else {
            return $ymax;
        }
    }
}

=head1 AUTHOR

Christian Queinnec, C<< Christian@Queinnec.org >>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

# end of win.pl
