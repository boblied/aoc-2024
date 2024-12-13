#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# Copyright (c) 2024, Bob Lied
#=============================================================================
# Advent of Code 2024 Day 13 Part 1 "Claw Contraption" 
#=============================================================================

use v5.40;
use FindBin qw($Bin); use lib "$FindBin::Bin/../../lib"; use AOC;
AOC::setup;

$logger->info("START");

my $PrizeOffset = 10000000000000;

my @Machine;
{ local $/ = "\n\n";
    while (<>)
    {
        chomp;
        my $m;
        my %move;
        for ( split /\n/ )
        {
            if ( m/Button (.): X\+(\d+), Y\+(\d+)/ )
            {
                $move{$1} = [ $2, $3 ];
            }
            elsif ( m/Prize: X=(\d+), Y=(\d+)/ )
            {
                push @Machine, Machine->new(
                    moveA => $move{A}, moveB => $move{B},
                    prize => [$1 + $PrizeOffset, $2 + $PrizeOffset] );
            }
        }
    }
}

my $TotalCost = 0;
for ( @Machine )
{
    $logger->info("Machine: ", $_->show);
    my $cost = play($_);
    if ( defined $cost )
    {
        $logger->info("Machine: ", $_->id, " cost=$cost");
        $TotalCost += $cost;
    }
    else
    {
        $logger->info("Machine: ", $_->id, " NO SOLUTION");
    }
}
say $TotalCost;

$logger->info("FINISH");

# Moves are only positive, so it's a linear combination of A moves
# and B moves. Use Cramer's rule to solve
# [ Ax Bx ][a]   [ Px ]
# [ Ay By ][b] = [ Py ]
# Det=(Ax*By - Ay*Bx)  Da=(Px*By - Py*Bx)  Db=(Ax*Py - Ay*Px)
# a = Da/Det  b = Db /Det
sub play($machine)
{
    my ($Ax,$Ay) = $machine->moveA->@*;
    my ($Bx,$By) = $machine->moveB->@*;
    my ($Px,$Py) = $machine->prize->@*;

    my $D  = ($Ax*$By - $Ay*$Bx);
    my $Da = ($Px*$By - $Py*$Bx);
    my $Db = ($Ax*$Py - $Ay*$Px);

    if ( $D == 0 ) {
        $logger->debug("FAIL No solution, D=0");
        return undef;
    }

    my $a = $Da/$D;
    my $b = $Db/$D;
    # Must have an integer number of moves
    if ( $a != int($a) || $b != int($b) )
    {
        $logger->debug("FAIL No integer solution, a=$a, b=$b");
        return undef;
    }

    # Can't exceed max moves
    #if ( ($a + $b) > $machine->maxMove )
    #{
    #    $logger->debug("FAIL Too many presses (",$a+$b,")");
    #}

    my $cost = $a * $machine->costA + $b * $machine->costB;
    return $cost;
}

use feature "class"; no warnings "experimental::class";
class Machine
{
    my $count;
    field $id           :reader;
    field $moveA :param :reader //= [0,0];
    field $moveB :param :reader //= [0,0];
    field $prize :param :reader //= [0,0];
    method costA() { 3 }
    method costB() { 1 }
    method maxMove() { 100 }

    ADJUST { $id = ++$count; }

    method show(){ "[$id] A=(@$moveA) B=(@$moveB) prize=(@$prize)" }
}
