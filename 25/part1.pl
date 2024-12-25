#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# Copyright (c) 2024, Bob Lied
#=============================================================================
# Advent of Code 2024 Day 25 Part 1 "Code Chronicle" 
#=============================================================================

use v5.40;
use List::Util qw/all/;

use FindBin qw($Bin); use lib "$FindBin::Bin/../../lib"; use AOC;
AOC::setup;

$logger->info("START");

my @Key;
my @Lock;

my @block;
{ local $/=""; # paragraph mode
    while (<>)
    {
        chomp(my @block = split " ");
        $logger->debug("@block");
        my $top = shift @block;
        if ( $top =~ m/#{5}/ )
        {
            pop @block;
            my @tumbler = (0) x 5;
            for my $b ( @block )
            {
                for my ($i, $t) ( indexed map { tr/.#/01/r } split //, $b )
                {
                    $tumbler[$i] += $t;
                }
            }
            push @Lock, [ @tumbler ];
        }
        elsif ( $top =~ m/\.{5}/ )
        {
            pop @block;
            my @tumbler = (5) x 5;
            for my $b ( @block )
            {
                for my ($i, $t) ( indexed map { tr/.#/10/r } split //, $b )
                {
                    $tumbler[$i] -= $t;
                }
            }
            push @Key, [ @tumbler ];
        }

    }
}


$logger->info(scalar(@Key), " keys, ", scalar(@Lock), " locks");
if ( $logger->is_debug )
{
    $logger->debug( "Lock [ @$_]") for @Lock;
    $logger->debug( "Key: [ @$_]") for @Key;
}

my $Fit = 0;
for my $lock ( @Lock )
{
    for my $key ( grep { $_->[0] + $lock->[0] <= 5 } @Key )
    {
        if ( all { $key->[$_] + $lock->[$_] <= 5 } 1 .. 4 )
        {
            $Fit++;
            $logger->debug("key [@$key] fits lock [@$lock]");
        }
    }
}
say $Fit;

$logger->info("FINISH");

