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
use List::Util qw/min/;

use FindBin qw($Bin); use lib "$FindBin::Bin/../../lib"; use AOC;
use AOC::Grid;

my $TargetScore = 7036; # Score for example. Input is 147628
AOC::setup({ "s:i", \$TargetScore });

$logger->info("START");

my $Maze = AOC::Grid::loadGrid();
my @Start = ($Maze->findChar('S'))[0]->@*;
my @End   = ($Maze->findChar('E'))[0]->@*;

my $distance = dijkstra($Maze, '>', @Start, @End);

# Now walk backwards from the end. Keep decrementing (-1 for straight,
# -1000 for a turn) and include the tile as long as the remaining length
# is positive.

my $answer = cover($Maze, $distance, @End, @Start);
say $answer;

$logger->info("FINISH");

# Make CSV of a list so it can be a key in a priority queue.
sub str(@stuff) { local $" = ","; qq(@stuff) }

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

sub dijkstra($maze, $direction, $startR, $startC, @end)
{
    my $bestScore = $maze->height * $maze->width * 1001;

    my %distance;
    $distance{ str($startR,$startC)}{$direction } = 0;

    my %seen;
    
    use Array::Heap::PriorityQueue::Numeric;
    my $pq = Array::Heap::PriorityQueue::Numeric->new();
    $pq->add( [ $startR, $startC, $direction, [] ],  0);

    while ( my $x = $pq->get() )
    {
        my ($r, $c, $dir, $path) = $x->@*;;
        my $score = $distance{ str($r,$c)}{$dir };

        if ( "$r $c" eq "@end" )
        {
            if ( $score < $bestScore )
            {
                $bestScore = $score;
                $logger->debug("Saved path for score=$score, length=", $path->$#*+2);
            }
            next;
        }

        next if $seen{ str($r,$c,$dir) };
        $seen{ str($r,$c,$dir) } = true;

        for ( $dir, validTurn($dir) )
        {
            my @n = neighbor($r, $c, $_);
            my $v = $maze->get(@n);
            next if $v eq '#';

            my $cost = $score + 1 + ( $_ eq $dir  ? 0 : 1000 );
            if ( ! exists $distance{ str($n[0],$n[1])}{$_ }
                || $cost < $distance{ str($n[0],$n[1])}{$_ } )
            {
                $distance{ str($n[0],$n[1])}{$_ } = $cost;
            }

            next if $cost > $bestScore;

            $pq->add( [ @n, $_, [ @$path, [$r, $c] ] ], $cost );
        }
    }

    return \%distance;
}

sub cover($maze, $distance, $startR, $startC, $endR, $endC)
{
    my %covered;
    my @queue;
    my %seen;
    my $budget = min  values %{$distance->{str($startR, $startC)}};

    push @queue, [ $startR, $startC, $budget ];
    while ( my $x = shift @queue )
    {
        my ($r, $c, $remain) = @$x;

        $covered{str($r,$c)} = true;
        last if ( str($r,$c) eq str($endR, $endC) );

        next if $seen{$r}{$c};
        $seen{$r}{$c} = true;
        
        my $intoHere = $distance->{str($r,$c)};
        my @incomingDir = grep { $intoHere->{$_} <= $remain } keys %$intoHere;

        state %reverse = ( '^' => 'v', 'v' => '^', '>' => '<', '<' => '>' );

        for ( @incomingDir )
        {
            my @n = neighbor($r, $c, $reverse{$_});
            my $d = $distance->{str($r,$c)}{$_};
            if ( $remain - $d >= 0 )
            {
                push @queue, [ @n, $d ];
            }
        }
    }

    return scalar(keys %covered);
}
