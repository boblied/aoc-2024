#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# Copyright (c) 2024, Bob Lied
#=============================================================================
# Advent of Code 2024 Day 10 Part 1 
#=============================================================================

use v5.40;
use FindBin qw($Bin); use lib "$FindBin::Bin/../../lib"; use AOC;
AOC::setup;
use AOC::Grid;

$logger->info("START");

my $Map = AOC::Grid::loadGrid();
$logger->info($Map->show());

my @Trailhead = $Map->findChar('0');
$logger->debug("TH: (@$_)") for @Trailhead;

my $count = 0;
for ( @Trailhead )
{
    my $p = countPaths($_, $Map, 9);
    $logger->info("TH at (@$_) has $p paths");
    $count += $p;
}
$logger->info("Total paths: $count");

$logger->info("FINISH");

sub countPaths($trailhead, $map, $goal)
{
    my $count = 0;
    my %visited;
    my @queue = ( [$trailhead] );
    while ( my $x = pop @queue  )
    {
        my ($loc) = @$x;
        $logger->trace("TH (@$trailhead): popped (@$loc)");
        my ($r, $c) = @$loc;
        next if $visited{$r}{$c};
        $visited{$r}{$c} = true;
        my $val;
        if ( ($val = $map->get($r, $c)) eq $goal )
        {
            $count++;
            next;
        }

        my @near = grep { $_->[0] eq $val+1 } $map->aroundNESW($r,$c);
        for ( @near )
        {
            my ($val, $at) = @$_;
            next if $visited{$at->[0]}{$at->[1]};
            push @queue, [ $at ];
        }
        $visited{$r}{$c} = false;
    }
    return $count;
}
