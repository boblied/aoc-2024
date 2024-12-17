#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# Copyright (c) 2024, Bob Lied
#=============================================================================
# Advent of Code 2024 Day 16 Part 1 "Reindeer Maze" 
#=============================================================================

use v5.40;
use FindBin qw($Bin); use lib "$FindBin::Bin/../../lib"; use AOC;
use AOC::Grid;
AOC::setup;

$logger->info("START");

my $Maze = AOC::Grid::loadGrid();
my @Start = ($Maze->findChar('S'))[0]->@*;
my @End   = ($Maze->findChar('E'))[0]->@*;

$logger->debug("Start=(@Start) End=(@End)", $Maze->show);

#my $answer = lowestScore($Maze, '>', @Start, @End);
my $answer = dijkstra($Maze, '>', @Start, @End);
say $answer;

$logger->info("FINISH");

sub lowestScore($maze, $dir, $locR, $locC, @end)
{
    my %seen;
    my $bestScore = $maze->height * $maze->width * 1000;
    my @stack = ( [ [$locR,$locC], $dir, 0 ] );
    while ( my $x = shift @stack )
    {
        my ($loc, $dir, $score) = @$x;

        next if $seen{"@$loc"};

        if ( "@$loc" eq "@end" )
        {
            $bestScore = $score if $score < $bestScore;
            $logger->debug("Found END", $maze->gdump);
            next;
        }

        $seen{"@$loc"} = true;
        $maze->set(@$loc, $dir);

        for ( $dir, validTurn($dir) )
        {
            my @p = neighbor(@$loc, $_);
            next if $seen{"@p"};

            my $v = $maze->get(@p);
            next if $v eq '#';

            my $cost = ( $_ eq $dir ) ? 1 : 1001;

            next if $score + $cost > $bestScore;

            push @stack, [ [@p], $_, $score + $cost ];
        }
    }
    return $bestScore;
}

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

# Make CSV of a list so it can be a key in a priority queue.
sub str(@stuff) { local $" = ","; qq(@stuff) }

sub dijkstra($maze, $direction, $startR, $startC, @end)
{
    use List::PriorityQueue;

    my %distance;
    my $bestScore = $maze->height * $maze->width * 1001;

    my $ptDir = str($startR, $startC, $direction);
    $distance{$ptDir} = 0;

    my %visited;

    my $prio = List::PriorityQueue->new();
    $prio->insert( $ptDir,  0);

    while ( my $ptDir = $prio->pop )
    {
        my ($r, $c, $dir) = split(",", $ptDir);
        my $score = $distance{$ptDir};

        if ( "$r $c" eq "@end" )
        {
            $bestScore = $score if ( $score < $bestScore );
            next;
        }

        next if $visited{$ptDir};
        $visited{$ptDir} = true;

        for ( $dir, validTurn($dir) )
        {
            my @n = neighbor($r, $c, $_);
            my $v = $maze->get(@n);
            next if $v eq '#';

            $ptDir = str(@n, $_);
            my $cost = $score + 1 + ( $_ eq $dir  ? 0 : 1000 );
            if ( ! exists $distance{$ptDir} || $cost < $distance{$ptDir} )
            {
                $distance{$ptDir} = $cost
            }

            next if $cost > $bestScore;

            $prio->insert( $ptDir, $cost);
        }
    }
    say $bestScore;
}
