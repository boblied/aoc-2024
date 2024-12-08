#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# Copyright (c) 2024, Bob Lied
#=============================================================================
# Advent of Code 2024 Day 08 Part 1
#=============================================================================

use v5.40;
use FindBin qw($Bin); use lib "$FindBin::Bin/../../lib"; use AOC;
use AOC::Grid;
AOC::setup;

$logger->info("START");

my $Grid = AOC::Grid::loadGrid();
$logger->info( $Grid->show() );

my %Antenna;
for my $r ( 0 .. $Grid->height() )
{
    for my $c ( 0 .. $Grid->width() )
    {
        my $x = $Grid->get($r,$c);
        next if $x eq '.';

        push @{$Antenna{$x}}, [$r, $c];
    }
}

if ( $logger->is_debug ) {
    use Data::Dumper; $Data::Dumper::Sortkeys = 1; $Data::Dumper::Indent=0;
    $logger->debug( "Antenna:\n", Dumper(\%Antenna) );
}

my %Antinode;
my $nodeCount = 0;
for my ($ant, $loc) ( %Antenna )
{
    $nodeCount += placeAntinode($Grid, \%Antinode, $ant, $loc->@*);
}
$logger->debug($Grid->show);

say scalar(keys %Antinode);

$logger->info("FINISH");

sub placeAntinode($g, $node, $ant, @location)
{
    while ( my $loc1 = shift @location )
    {
        for my $loc2 ( @location )
        {
            my ($r1,$c1) = @$loc1;
            my ($r2,$c2) = @$loc2;
            my $dr = $r2-$r1;
            my $dc = $c2-$c1;

            $logger->debug("place: $ant (@$loc1)(@$loc2), dr=$dr dc=$dc");
            for my $n ( [ $r1-$dr, $c1-$dc ], [ $r2+$dr, $c2+$dc ] )
            {
                if ( $g->isInbounds(@$n) )
                {
                    if ( ! exists $node->{"@$n"} )
                    {
                        $logger->trace("    AN at (@$n)");
                        $node->{"@$n"} = $n;
                        $g->set(@$n, '#');
                    }
                    else
                    {
                        $logger->trace("OVERLAP at (@$n)");
                    }
                }
                else
                {
                    $logger->trace("    OFF at (@$n)");
                }
            }
        }
    }

    if ( $logger->is_debug ) {
        $logger->debug("NODES: ", join(" ", map {"($_)"} sort keys %$node));
    }
    return scalar(%$node);
}
