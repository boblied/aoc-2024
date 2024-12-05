#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# Copyright (c) 2024, Bob Lied
#=============================================================================
# Advent of Code 2024 Day 02 Part 2
#=============================================================================

use v5.40;

sub isSafe(@report)
{
    my ($INC, $DEC) = (false, false);
    if ( $report[1] - $report[0] > 0 ) { $INC = true }
    if ( $report[1] - $report[0] < 0 ) { $DEC = true }

    my $safe = $INC || $DEC;
    my $r1 = shift @report;
    while ( $safe && defined(my $r2 = shift @report) )
    {
        my $diff = abs($r2 - $r1);

        $safe &&= (($INC && $r2 > $r1) || ($DEC && $r2 < $r1)) && (1 <= $diff <= 3);
        $r1 = $r2;
    }
    return $safe;
}

my $safe = 0;
while (<>)
{
    my @report = split;
    if ( isSafe(split) ) { $safe++; next; }

    for my $rmv ( 0 .. $#report )
    {
        my @rep = @report;
        splice(@rep, $rmv, 1);
        if ( isSafe(@rep) ) { $safe++ ; last; }
    }
}

say $safe;
