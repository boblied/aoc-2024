#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# Copyright (c) 2024, Bob Lied
#=============================================================================
# Advent of Code 2024 Day 24  Part 1  "Crossed Wires" 
#=============================================================================

use v5.40;
use Object::Pad;

use FindBin qw($Bin); use lib "$FindBin::Bin/../../lib"; use AOC;
AOC::setup;

$logger->info("START");

my %Input;
my @Gate;
my %Circuit;
while (<>)
{
    chomp;
    if ( m/:/ )
    {
        my ($input, $value) = split /:\s*/;
        $Circuit{$input} = Node->new(id => $input, type => 'ASSIGN',
                                     left => $value, right => $value );
    }
    elsif ( m/->/ )
    {
        my @g= split;

        $Circuit{$g[4]} = Node->new(id => $g[4], type => $g[1],
                                   left => $g[0], right => $g[2] );
    }
}

my @out;
for my $output ( sort { $b cmp $a } grep /^z/, keys %Circuit )
{
    push @out, $Circuit{$output}->evaluate();
}
my $z = join("", @out);
say "$z ", oct("0b$z");


$logger->info("FINISH");


class Node;

sub    AND($x,$y) { $x && $y }
sub     OR($x,$y) { $x || $y }
sub    XOR($x,$y) { $x ^^ $y }
sub ASSIGN($x,$y) { $x }

field $id    :param;
field $left  :param;
field $right :param;
field $type  :param;

field $op;

ADJUST {
    if    ( $type eq    'AND' ) { $op = \&AND; }
    elsif ( $type eq     'OR' ) { $op = \&OR;  }
    elsif ( $type eq    'XOR' ) { $op = \&XOR; }
    elsif ( $type eq 'ASSIGN' ) { $op = \&ASSIGN;  }
}

method evaluate()
{
    if    ( $type eq 'ASSIGN' )
    {
        return $left;
    }
    elsif ( $type eq 'AND' )
    {
        return $Circuit{$left}->evaluate() & $Circuit{$right}->evaluate();
    }
    elsif ( $type eq 'OR' )
    {
        return $Circuit{$left}->evaluate() | $Circuit{$right}->evaluate();
    }
    elsif ( $type eq 'XOR' )
    {
        return 0x1&($Circuit{$left}->evaluate() ^ $Circuit{$right}->evaluate());
    }
}
