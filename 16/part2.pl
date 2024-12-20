#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# Copyright (c) 2024, Bob Lied
#=============================================================================
# Advent of Code 2024 Day 16 Part 2 "Reindeer Maze" 
#=============================================================================
# From part 1, we know the score of the shortest path. Now we're going to
# do Dijkstra algorithm to find all the places touched in any path that has
# the given score. Part 1 used List::PriorityQueue, which makes it difficult
# to pass a path list, so we're replacing that with an ad-hoc priority queue.
#=============================================================================

use v5.40;
use FindBin qw($Bin); use lib "$FindBin::Bin/../../lib"; use AOC;
use AOC::Grid;

my $TargetScore = 7036; # Score for example. Input is 147628
AOC::setup({ "s:i", \$TargetScore });

$logger->info("START");

my $Maze = AOC::Grid::loadGrid();
my @Start = ($Maze->findChar('S'))[0]->@*;
my @End   = ($Maze->findChar('E'))[0]->@*;

my $answer = coverBest($TargetScore, $Maze, '>', @Start, @End);
say $answer;

$logger->info("FINISH");


sub neighbor($r, $c, $dir)
{
state %n = ( '^' => [-1, 0], '>' => [0,1], 'v' => [1,0], '<' => [0,-1] );
    return ( $r + $n{$dir}->[0], $c + $n{$dir}->[1] );
}

sub validTurn($dir)
{
state %t = ( '^' => [ qw(< >) ], '>' => [ qw(^ v) ],
             'v' => [ qw(> <) ], '<' => [ qw(v ^) ] );
    return $t{$dir}->@*;
}

sub coverBest($targetScore, $maze, $direction, $startR, $startC, @end)
{
    my %distance;
    my $bestScore = $maze->height * $maze->width * 1001;

    my %pathInBest = ( "$startR $startC" => true, "@end" => true );

    my $ptDir = "$startR $startC $direction";
    $distance{$ptDir} = 0;

    my %visited;

    my %prio;
    $prio{$ptDir} = { r=>$startR, c=>$startC, dir=>$direction,
                      prio=>0, path=>[ "$startR $startC" ] };

    while ( my $x = lowestPriority(\%prio) )
    {
        my $r = $x->{r};
        my $c = $x->{c};
        my $dir = $x->{dir};
        my $pathSoFar = $x->{path};

        my $ptDir = "$r $c $dir";
        my $score = $distance{$ptDir};

        if ( "$r $c" eq "@end" )
        {
            $logger->debug("END score=$score");
            if ( $score == $targetScore )
            {
                $pathInBest{$_} = true for $pathSoFar->@*;
            }
            next;
        }

        next if $visited{$ptDir};
        $visited{$ptDir} = true;

        for ( $dir, validTurn($dir) )
        {
            my @n = neighbor($r, $c, $_);
            my $v = $maze->get(@n);
            next if $v eq '#';

            $ptDir = "@n $_";
            my $cost = $score + 1 + ( $_ eq $dir  ? 0 : 1000 );
            if ( ! exists $distance{$ptDir} || $cost < $distance{$ptDir} )
            {
                $distance{$ptDir} = $cost
            }

            next if $cost > $targetScore;

            $prio{$ptDir} = { r=>$n[0], c=>$n[1], dir=>$_,
                              prio=>$cost,
                              path=>[ $pathSoFar->@*, "@n" ] };
        }
    }
    return scalar(keys %pathInBest);
}

sub lowestPriority($pq)
{
    return undef if scalar(keys %$pq) == 0;
    my @byPriority = sort { $pq->{$a}{prio} <=> $pq->{$b}{prio} } keys %$pq;
    my $lowest = $pq->{$byPriority[0]};
    delete $pq->{$byPriority[0]};
    return $lowest;
}
