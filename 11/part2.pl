#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# Copyright (c) 2024, Bob Lied
#=============================================================================
# Advent of Code 2024 Day 11 Part 2 "Plutoniant Pebbles" 
#=============================================================================

use v5.40;
use FindBin qw($Bin); use lib "$FindBin::Bin/../../lib"; use AOC;
AOC::setup;

$logger->info("START");

# Cache results to shortcut recursion. Huge speedup.
use Memoize;
memoize("blinker");

# Usage: part2.pl    1 2 3    25
#        part2.pl 25 < input
my $Blink = pop @ARGV // 75;

my @Pebble = @ARGV;
if ( ! @Pebble )
{
    while (<>) { chomp; push @Pebble, split }

}
$logger->info("PEBBLE: @Pebble");
$logger->info("BLINK: $Blink times");

my $d=""; # Indentation level for debugging recursion

my $size = 0;
for ( @Pebble)
{
    $logger->info("BLINK $Blink FOR $_");
    my $n = blinker($_, $Blink);

    $logger->info("FOR $_: $n");
    $size += $n;
}
say $size;

$logger->info("FINISH");

sub blinker($pebble, $repeat)
{
    $d = "  $d";
    $logger->debug("$d ENTER blinker $pebble $repeat");
    my $size;
    if ( $repeat == 0 )
    {
        $logger->debug("$d BOTTOM $pebble repeat=0");
        $size = 1;
    }
    elsif ( $pebble == 0 )
    {
        $logger->trace("$d 0 becomes 1");
        $size = blinker(1, $repeat-1);
    }
    else
    {
        my $n = length($pebble);
        if ( ($n % 2) == 1 )
        {
            $logger->trace("$d ODD $pebble x2024 -> ", $pebble*2024);
            $size = blinker($pebble * 2024, $repeat-1);
        }
        else    # Even number of digits, split in half
        {
            # Convert to numbers if leading zeros.
            my ($left, $right) = map { $_+0 }
                    ( substr($pebble, 0, $n/2), substr($pebble, $n/2) );
            $logger->trace("$d SPLIT $left $right");
            $size = blinker($left,  $repeat-1) + blinker($right, $repeat-1);
        }
    }
    $logger->debug("$d RETURN pebble=$pebble repeat=$repeat SIZE $size");
    $d = substr($d, 2);
    return $size;
}
