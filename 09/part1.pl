#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# Copyright (c) 2024, Bob Lied
#=============================================================================
# Advent of Code 2024 Day 09 Part 1
#=============================================================================

use v5.40;
use FindBin qw($Bin); use lib "$FindBin::Bin/../../lib"; use AOC;
AOC::setup;

use List::MoreUtils qw/first_index last_index/;

$logger->info("START");

my @DISK;
while (<>)
{
    chomp;
    my @x = split "";

    for ( 0 .. $#x )
    {
        if ( $_ % 2 )   # Free space
        {
            push @DISK, (".") x $x[$_];
        }
        else # File, assign ID
        {
            push @DISK, (int($_/2)) x $x[$_];
        }
    }
}

# Move last block to first open space

my $end  = last_index  { $_ ne '.' } @DISK;
my $open = first_index { $_ eq '.' } @DISK;
$logger->trace(join "", @DISK);
while ( $end > $open )
{
    @DISK[$open,$end] = @DISK[$end, $open];
    $logger->trace(join( "", @DISK), " SWAP: open=$open end=$end");
    
    $end--; while ( $end >= 0 && $DISK[$end] eq '.' ) { $end-- }
    $open++; while ( $open <= $#DISK && $DISK[$open] ne '.' ) {$open++}
}

my $checksum;
for ( 0 .. (last_index { $_ ne '.' } @DISK) )
{
    $checksum += $_ * $DISK[$_];
}
say "CHECKSUM: ", $checksum;

$logger->info("DISK: @DISK");

$logger->info("FINISH");

