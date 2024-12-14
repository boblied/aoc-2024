#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# Copyright (c) 2024, Bob Lied
#=============================================================================
# Advent of Code 2024 Day 14 Part 1 "Restroom Redoubt" 
#=============================================================================

use v5.40;
use FindBin qw($Bin); use lib "$FindBin::Bin/../../lib"; use AOC;
AOC::setup;
use AOC::Grid;

$logger->info("START");
my @Robot;

my $H = 103;
my $W = 101;

while (<>)
{
    chomp;
    my ($px,$py,$vx,$vy) = m/(-?\d+)/g;
    push @Robot, [ [$py, $px ], [$vy, $vx] ];
    $logger->trace("Robot $. ", showRobot($Robot[-1]));
}

my $rob = $Robot[0];
my @p = $rob->[0]->@*;
my @v = $rob->[1]->@*;

my $Room = AOC::Grid::makeGrid($H-1, $W-1, 0);
for my $r ( @Robot )
{
    my @p = $r->[0]->@*;
    $Room->set(@p, 1+$Room->get(@p));
}
$logger->info("BEGIN ", $Room->show);

for my $t ( 1 .. 100 )
{
    for my $rob ( @Robot )
    {
        my @p = $rob->[0]->@*;
        my @v = $rob->[1]->@*;
        my @n = move(@p, @v);
        $rob->[0] = [@n];

        $Room->set(@p, $Room->get(@p)-1);
        $Room->set(@n, $Room->get(@n)+1);
        $logger->trace("T=$t p=(@p)+v(@v)=n(@n)", $Room->show());
    }
}

$logger->info("END ", $Room->show);

my $midR = int($H / 2); # Assuming odd dimensions
my $midC = int($W / 2);
$logger->debug("Middle: r=$midR c=$midC");

my $q1 = count($Room, 0,       0,        $midR-1, $midC-1);
my $q2 = count($Room, 0, $midC+1,        $midR-1, $W-1);
my $q3 = count($Room, $midR+1, 0,        $H-1,    $midC-1);
my $q4 = count($Room, $midR+1, $midC+1,  $H-1,    $W-1);

$logger->info("QUADRANTS: q1=$q1 q2=$q2 q3=$q3 q4=$q4");

say "Safety factor: ", $q1 * $q2 * $q3 * $q4;


$logger->info("FINISH");

sub showRobot($r)
{
    my ($pos, $speed) = $r->@*;
    return "at (@$pos)\tspeed=(@$speed)";
}

sub move($pr,$pc,  $vr, $vc)
{
    return ( (($pr+$vr) % $H), (($pc+$vc) % $W) );
}

sub count($room, $ulR, $ulC, $lrR, $lrC)
{
    $logger->debug("count ($ulR $ulC) ($lrR $lrC)");
    my $n = 0;
    for my $r ( $ulR .. $lrR) 
    {
        for my $c ( $ulC .. $lrC )
        {
            $n += $room->get($r,$c);
        }
    }
    return $n;
}
