#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# Copyright (c) 2024, Bob Lied
#=============================================================================
# Advent of Code 2024 Day 03 Part 2
#=============================================================================

use v5.40;

my $doMult = true;

my $sum = 0;
while (<>)
{
    chomp;
    $sum += mult($_);
}
say $sum;

sub mult($s)
{
    my $sum = 0;
    while ( $s =~ m/(do\(\)|don't\(\)|(mul\((\d+),(\d+)\)))/g )
    {
        #say "1=$1 2=$2 3=$3 4=$4";
        if    ( $1 eq q/do()/    ) { say "  DO"; $doMult = true;  next; }
        elsif ( $1 eq q/don't()/ ) { say "DONT"; $doMult = false; next; }
        elsif ( $doMult )
        {
            say "$3*$4=", $3*$4;
            $sum += $3 * $4;
        }
    }
    return $sum;
}
