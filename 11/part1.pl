#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# Copyright (c) 2024, Bob Lied
#=============================================================================
# Advent of Code 2024 Day 11 Part 1 "Plutoniant Pebbles" 
#=============================================================================

use v5.40;
use FindBin qw($Bin); use lib "$FindBin::Bin/../../lib"; use AOC;
AOC::setup;

$logger->info("START");

my $Blink = shift;

my @Pebble = @ARGV;
if ( ! @Pebble )
{
    while (<>) { chomp; push @Pebble, split }

}
$logger->info("PEBBLE: @Pebble");
$logger->info("BLINK: $Blink times");

blink(\@Pebble) for 1 .. $Blink;

$logger->debug("AFTER: @Pebble");

say scalar(@Pebble);

$logger->info("FINISH");

sub blink($pebble)
{
    for ( my $i = 0 ; $i <= $pebble->$#* ; $i++ )
    {
        my $p = $pebble->[$i];
        if ( $p == 0 ) { $pebble->[$i] = 1 }
        elsif ( (my $n = length("$p")) % 2 == 0 )
        {
            my $mid = $n/2;
            $pebble->[$i] = 0 + substr($p, $n/2);
            splice(@$pebble, $i, 0, substr($p, 0, $n/2));
            $i++;
        }
        else
        {
            $pebble->[$i] *= 2024;
        }
    }
}
