#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# Copyright (c) 2024, Bob Lied
#=============================================================================
# Advent of Code 2024 Day 23 Part 1 "LAN Party" 
#=============================================================================

use v5.40;

use List::Util qw/all any/;

use FindBin qw($Bin); use lib "$FindBin::Bin/../../lib"; use AOC;
AOC::setup;

my %Graph;
$logger->info("START");

while (<>)
{
    chomp;
    my ($from, $to) = split /-/;

    $Graph{$from}{$to} = $Graph{$to}{$from} = true;
}
$logger->info( scalar(keys %Graph), " nodes");

say find3loop(\%Graph);

$logger->info("FINISH");

sub find3loop($g)
{
    my %isInTriad;

    for my $v ( grep /^t/, keys %$g )
    {
        for my $adj ( keys %{$g->{$v}} )
        {
            for my $third ( grep !/$v/, keys %{$g->{$adj}} )
            {
                if ( exists $g->{$third}{$v} )
                {
                    my $triad = join(",", sort $v, $adj, $third);
                    $isInTriad{$triad} = true;
                }
            }
        }
    }
    return scalar(keys %isInTriad);
}
