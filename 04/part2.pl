#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# Copyright (c) 2024, Bob Lied
#=============================================================================
# Advent of Code Day 04 Part 2
#=============================================================================

use v5.40;
use FindBin qw($Bin); use lib "$FindBin::Bin/../../lib"; use AOC;
use AOC::Grid;

AOC::setup;

my $WS = AOC::Grid::loadGrid;
$logger->info($WS->show);

my $g = $WS->grid();
my $width = $WS->width();
my $height = $WS->height();

# Possible 3x3 squares with the MAS cross pattern:
# M.M   S.M     S.S     M.S
# .A.   .A.     .A.     .A.
# S.S   S.M     M.M     M.S
my $re = qr/M.S.A.M.S|M.M.A.S.S|S.M.A.S.M|S.S.A.M.M/;

# Extract all possible 3x3 boxes from the grid
my $x = 0;
for my $row (0 .. $height-2)
{
    for my $col ( 0 .. $width-2 )
    {
        my @box;
        push @box, $g->[$_]->@[$col .. $col+2] for $row .. $row+2;

        my $b = join("", @box);
        $x += $b =~ m/$re/;
        $logger->debug("BOX at $row,$col: ", $b, " X-MAS=", $x);
    }
}
say $x;
