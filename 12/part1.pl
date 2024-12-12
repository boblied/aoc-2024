#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# Copyright (c) 2024, Bob Lied
#=============================================================================
# Advent of Code 2024 Day 12 Part 1 "Garden Groups" 
#=============================================================================

use v5.40;
use FindBin qw($Bin); use lib "$FindBin::Bin/../../lib"; use AOC;
AOC::setup;
use AOC::Grid;

use List::MoreUtils qw/first_index/;

$logger->info("START");

my $Garden = AOC::Grid::loadGrid;
$logger->info("Garden: ", $Garden->show);

my $Region = lookForRegion($Garden, [0,0], [$Garden->height, $Garden->width]);

my $TotalCost = 0;
for ( $Region->@* ) # Array of hash reference
{
    my $area = $_->{area};
    my $perimeter = $_->{perimeter};
    my $cost = $area * $perimeter;
    $logger->info("$_->{id} ($_->{minR},$_->{maxR}) ($_->{minC},$_->{maxC})\tA=$area\tP=$perimeter\tC=$cost");

    $TotalCost += $cost;
}
say "COST: $TotalCost";


$logger->info("FINISH");

sub lookForRegion($grid, $upperLeft, $lowerRight)
{
    my @regionList = ();
    for my $r ( $upperLeft->[0] .. $lowerRight->[0] )
    {
        for my $c ( $upperLeft->[1] .. $lowerRight->[1] )
        {
            my $id = $grid->get($r, $c);
            next if $id eq '#';
            my $region = fillRegion($grid, $r, $c);
            $logger->debug("$region->{id}: ", $grid->show());
            push @regionList, $region;
        }
    }
    return \@regionList;
}


sub fillRegion($g, $row, $col)
{
    my $name = $g->get($row, $col);
    my $region = { id => $name, area => 0,
                   maxR => $row, minR => $row, maxC =>$col, minC => $col };
    $logger->info("Finding region for $name at ($row,$col)");

    # Breadth-first search for fill to get area
    my $fill = $g->get($row, $col);
    my $seen = AOC::Grid::makeGrid($g->height, $g->width, '#');
    my @queue = ( [ $row, $col ] );
    while ( my $x = shift @queue )
    {
        my ($r, $c) = @$x;

        next if $seen->get($r, $c) eq $fill;
        $seen->set($r, $c, $fill);
        $region->{area}++;
        $region->{maxR} = $r if $r > $region->{maxR};
        $region->{minR} = $r if $r < $region->{minR};
        $region->{maxC} = $c if $c > $region->{maxC};
        $region->{minC} = $c if $c < $region->{minC};


        my @neighbor = $g->aroundNESW($r, $c);
        for my $in ( grep { $_->[0] eq $name } @neighbor )
        {
            next if $seen->get( @{$in->[1]} ) eq $fill ;
            push @queue, [ $in->[1]->@* ];
        }
    }
    my @range =  @{$region}{ qw(minR minC maxR maxC) };
    $region->{mask} = $seen->getBox( @range );

    $region->{perimeter} = edgeCount($seen, @range, $name);

    clearRegion($seen, $g, $fill, @range);

    $logger->info("Region $name area=$region->{area} P=$region->{perimeter}");
    return $region;
}

sub edgeCount($g, $ulR, $ulC, $lrR, $lrC, $char)
{
    # Across rows
    my $edge = 0;
    for my $r ( $ulR .. $lrR )
    {
        my $outside = 1;
        for my $c ( $ulC .. $lrC )
        {
            my $v = $g->get($r, $c);
            if ( $outside && $v eq $char )
            {
                $edge++;
                $outside = 0;
            }
            elsif ( ! $outside && $v ne $char )
            {
                $outside = 1;
                $edge++
            }
        }
        $edge++ if ! $outside;
    }

    # Across columns
    for my $c ( $ulC .. $lrC )
    {
        my $outside = 1;
        for my $r ( $ulR .. $lrR )
        {
            my $v = $g->get($r, $c);
            if ( $outside && $v eq $char )
            {
                $edge++;
                $outside = 0;
            }
            elsif ( ! $outside && $v ne $char )
            {
                $outside = 1;
                $edge++
            }
        }
        $edge++ if ! $outside;
    }
    return $edge;
}

sub clearRegion($src, $dest, $val, $ulR, $ulC, $lrR, $lrC)
{
    my $gsrc = $src->grid;
    my $gdest = $dest->grid;
    my $width = $lrC - $ulC + 1;
    for my $r ( $ulR .. $lrR )
    {
        for my $c ( $ulC .. $lrC )
        {
            $gdest->[$r][$c] = '#' if $gsrc->[$r][$c] eq $val;
        }
    }
}
