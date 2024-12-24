#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# Copyright (c) 2024, Bob Lied
#=============================================================================
# Advent of Code 2024 Day 23 Part 2 "LAN Party" 
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
if ( $logger->is_debug )
{
    for ( keys %Graph )
    {
        $logger->debug("$_ neighbors: (", scalar(keys %{$Graph{$_}}), ")");
    }
}

my @Party;
for ( keys %Graph )
{
    my $c = party(\%Graph, $_);
    $logger->debug("$_: ($c->$#*) [@$c]");
    @Party = @$c if ( $c->$#* > $#Party );
}
say join(",", sort @Party);

$logger->info("FINISH");

sub party($g, $player)
{
    my @connected = ( $player );

    for my $maybe ( keys %{$g->{$player}} )
    {
        if ( all { exists $g->{$maybe}{$_} } @connected  )
        {
            push @connected, $maybe 
        }
    }
    return \@connected;
}
