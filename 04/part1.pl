#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# Copyright (c) 2024, Bob Lied
#=============================================================================
# Advent of Code 2024 Day 04 Part 1 
#=============================================================================

use v5.40;
use FindBin qw($Bin); use lib "$FindBin::Bin/../../lib"; use AOC;
use AOC::StringArray;
use File::Slurper qw/read_lines/;

AOC::setup;

my @WS = read_lines(shift);

$logger->info( showAofS(\@WS) );

my $xmas = 0;
for my $row ( @WS )
{
    $xmas +=()= ( "$row|".reverse $row) =~ m/XMAS/g;
    $logger->debug("ROWS: $xmas", "\t$row|".reverse $row);
}

my $t = transposeAofS(\@WS);
for my $row ( $t->@* )
{
    $xmas +=()= ( "$row|".reverse $row) =~ m/XMAS/g;
    $logger->debug("COLUMNS $xmas", "\t$row|".reverse $row);
}

$t = diaglrAofS(\@WS);
for my $row ( $t->@* )
{
    $xmas +=()= ( "$row|".reverse $row) =~ m/XMAS/g;
    $logger->debug("DIAG LR $xmas", "\t$row|".reverse $row);
}

$t = diagrlAofS(\@WS);
for my $row ( $t->@* )
{
    $xmas +=()= ( "$row|".reverse $row) =~ m/XMAS/g;
    $logger->debug("DIAG RL $xmas", "\t$row|".reverse $row);
}

say $xmas;
