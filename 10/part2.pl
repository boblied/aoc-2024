#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# Copyright (c) 2024, Bob Lied
#=============================================================================
# Advent of Code 2024 Day 10 Part 2
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

my @Destination = $Map->findChar('9');
$logger->debug("DEST: (@$_)") for @Destination;

my $count = 0;
while ( my $th = shift @Trailhead )
{
    for my $dest ( @Destination )
    {
        my $p = countPaths($Map, $th, $dest);
        $count += $p;
        $logger->info("(@$th)<->(@$dest): $p (count=$count)");
    }
}

$logger->info("Total paths: $count");

$logger->info("FINISH");

sub countPaths($map, $start, $goal)
{
    my @visited;
    for my $r ( 0 .. $map->height() )
    {
        push @visited, [ (false) x $map->width() ];
    }
    my @path = ();

    return _count($map, $start, $goal, \@visited, \@path, 0);
}

sub _count($map, $place, $goal, $visited, $path, $sofar)
{
    my ($r, $c) = @$place;
    $visited->[$r][$c] = true;

    push @$path, $place;
    if ( "@$place" eq "@$goal" )
    {
        $sofar++;
        $logger->debug("Found (@$goal) ", map { "(@$_)" } @$path);
    }
    else
    {
        my $val = $map->get($r,$c);
        my @near = grep { $_->[0] eq $val+1 } $map->aroundNESW($r, $c);
        for ( @near )
        {
            my ($v, $at) = @$_;
            if ( ! $visited->[$at->[0]][$at->[1]] )
            {
                $sofar = _count($map, $at, $goal, $visited, $path, $sofar);
            }
        }
    }

    pop @$path;
    $visited->[$r][$c] = false;
    return $sofar;
}
