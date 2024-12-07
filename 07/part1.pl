#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# Copyright (c) 2024, Bob Lied
#=============================================================================
# Advent of Code 2024 Day 07 Part 1
#=============================================================================

use v5.40;
use FindBin qw($Bin); use lib "$FindBin::Bin/../../lib"; use AOC;
AOC::setup;

$logger->info("START");

my $sum = 0;
while (<>)
{
    # Everthing that is not a digit is a field separator. map ensures numeric value.
    my ($goal, @term) = map { $_+0 } split /[^0-9]+/;

    if ( isValidBackward($goal, @term) )
    {
        $sum += $goal;
        $logger->info("YES $goal=(@term) reached, sum=$sum");
    }
    else
    {
        $logger->info("NO $goal=(@term)");
    }
}
say $sum;

$logger->info("FINISH");

sub isValidBackward($goal, @terms)
{
    use integer;

    return $goal == $terms[0] if ( @terms == 1 );

    my $last = pop @terms;
    return true if ( $goal % $last == 0 && isValidBackward($goal/$last, @terms) );

    return true if ( $goal > $last      && isValidBackward($goal-$last, @terms) );

    return false;
}
