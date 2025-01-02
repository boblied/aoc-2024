#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# Copyright (c) 2024, Bob Lied
#=============================================================================
# Advent of Code 2024 Day 20 Part 1 "Race Condition" 
#=============================================================================

use v5.40;
use List::PriorityQueue;

use FindBin qw($Bin); use lib "$FindBin::Bin/../../lib"; use AOC;
use AOC::Grid;

my $SaveThreshold = 100;
AOC::setup({"s:i" => \$SaveThreshold });

$logger->info("START");

my $Track = AOC::Grid->loadGrid();
my $Start = ($Track->findChar('S'))[0];
my $End   = ($Track->findChar('E'))[0];
$logger->info("START: (@$Start)  END: (@$End)", $Track->show );

# Run Dijkstra backward to find finishing distance of every point on path

my ($predPath, $distance) = dijkstra($Track, @$End, @$Start);

$logger->info("Path length: ", scalar(keys %$predPath));

my $n = tryToCheat($Track, $SaveThreshold, $predPath, $distance, @$Start);
say "$n cheats save at least $SaveThreshold";

$logger->info("FINISH");

sub dijkstra($track, $startR, $startC, $endR, $endC)
{
    my $INF = $track->height * $track->width * 10000 - 1;
    my %distance;
    my %seen;
    my %predecessor;

    for my $dot ( $track->findChar('.') )
    {
        $distance{"@$dot"} = $INF;
    }
    $distance{"$startR $startC"} = 0;
    $distance{"$endR $endC"}     = $INF;

    my $pq = List::PriorityQueue->new();
    $pq->insert("$startR $startC", 0);

    while ( my $x = $pq->pop() )
    {
        next if $seen{$x};
        $seen{$x} = true;

        my @u = split(" ", $x);
        my @neighbor = $track->aroundNESW(@u);

        for my $v ( map { "$_->[1]->@*" } grep { $_->[0] ne '#' } @neighbor )
        {
            next if $seen{$v};

            my $d = $distance{$x} + 1;
            if ( $d < $distance{$v} )
            {
                $distance{$v} = $d;
                $predecessor{$v} = $x;
            }

            $pq->insert($v, $d);
        }
    }

    return (\%predecessor, \%distance);
}

sub tryToCheat($track, $threshold, $path, $distance, @start)
{
    my $cheatsThatWork = 0;

    # Unroll path into an array.
    my @Path = ( "@start" );
    my $p = "@start";
    while ( defined $path->{$p} )
    {
        push @Path, $path->{$p};
        $p = $path->{$p};
    }

    # Check every pair of points. If the second is 100 closer to the end,
    # and it can be reached in 20 steps, it's a valid shortcut.
    # There are about 9000 elements in Path for the input, so this is not
    # near optimal (takes about 20 seconds to run).
    while ( my $p1 = shift @Path )
    {
        for my $p2 ( @Path )
        {
            my $d1 = $distance->{$p1};
            my $d2 = $distance->{$p2};
            my $move = mdist($p1, $p2);
            my $save = $d1 - $d2 - $move;
            if ( $save >= $threshold && $move <= 20 )
            {
                $logger->trace("Cheat: [$p1]($d1) to [$p2]($d2) $move moves saves $save");
                $cheatsThatWork ++;
            }
        }
    }

    return $cheatsThatWork;
}

sub mdist($p1, $p2)
{
    my @p1 = split(" ", $p1);
    my @p2 = split(" ", $p2);
    return abs($p1[0] - $p2[0]) + abs($p1[1] - $p2[1]);
}

sub tryToCheatPart1($track, $threshold, $path, $distance, @End)
{
    my $cheatsThatWork = 0;
    for my $p ( keys %$path )
    {
        next if $p eq "@End";
        my $fromHere = $distance->{$p};

        my ($r, $c) = split(" ", $p);
        for my ($dr, $dc) ( 0,1,  0,-1,  1,0,  -1,0 )
        {
            if ( (my $x = $track->get($r+$dr, $c+$dc)) eq '#' )
            {
                my @thru = ($r + $dr + $dr, $c + $dc + $dc);
                next unless $track->isInbounds(@thru);
                next unless $track->get(@thru) ne '#';

                my $fromThere = $distance->{"@thru"};

                if ( $fromThere < $fromHere )
                {
                    my $save = $fromHere - $fromThere - 2;
                    $logger->debug("CHEAT ($p) to (@thru), save $save at [$fromHere -> $fromThere]");
                    $cheatsThatWork++ if ( $save >= $threshold )
                }
            }
        }
    }
    return $cheatsThatWork;
}
