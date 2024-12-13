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
    my $sidecount = $_->{sidecount};
    my $cost1 = $area * $perimeter;
    my $cost2 = $area * $sidecount;
    $logger->info("$_->{id} ($_->{minR},$_->{maxR}) ($_->{minC},$_->{maxC})\tA=$area\tP=$perimeter\tS=$sidecount\tC1=$cost1\tC2=$cost2");

    $TotalCost += $cost2;
}
say "COST: $TotalCost";

$logger->info("FINISH");
########################################################################

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

    # Do edge detection on the bounding rectangle, and use the
    # mask in the $seen grid so that we're looking only at characters
    # from the found region.
    $region->{perimeter} = edgeCount($seen, @range, $name);
    $region->{sidecount} = sideCount($seen, @range);

    # In the main grid, clear this region. Will leave nested regions
    # untouched.
    clearRegion($seen, $g, $fill, @range);

    $logger->info("Region $name area=$region->{area} P=$region->{perimeter} S=$region->{sidecount}");
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

# Clearly some refactoring is possible here, but I went
# crazy-balls bananas trying to do the rotations, so let's
# say I applied a loop-unrolling optimization.
sub sideCount($g, $ulR, $ulC, $lrR, $lrC)
{
    my $side = 0;
    my @edgeMatrix;

    # Left edges
    for my $r ( $ulR .. $lrR )
    {
        my @row = ($g->getRow($r))[$ulC .. $lrC];
        push @edgeMatrix, [ edge(@row) ];
    }
    my $left = sides(\@edgeMatrix);
    $side += $left;
    $logger->debug("sideCount LEFT=$left S=$side");

    # Right edges
    @edgeMatrix = ();
    for my $r ( $ulR .. $lrR )
    {
        my @row = reverse( ($g->getRow($r))[$ulC .. $lrC] );
        push @edgeMatrix, [ edge(@row) ];
    }
    my $right = sides(\@edgeMatrix);
    $side += $right;
    $logger->debug("sideCount RIGHT=$left S=$side");

    # Top edges
    @edgeMatrix = ();
    for my $c ( $ulC .. $lrC )
    {
        my @col = ($g->getColumn($c))[$ulR .. $lrR];
        push @edgeMatrix, [ edge(@col) ];
    }
    my $top = sides(\@edgeMatrix);
    $side += $top;
    $logger->debug("sideCount TOP=$top S=$side");

    # Bottom edges
    @edgeMatrix = ();
    for my $c ( $ulC .. $lrC )
    {
        my @col = reverse (($g->getColumn($c))[$ulR .. $lrR] );
        push @edgeMatrix, [ edge(@col) ];
    }
    my $bottom = sides(\@edgeMatrix);
    $side += $bottom;
    $logger->debug("sideCount BOTTOM=$bottom S=$side");

    return $side;
}

sub sides($edgeMatrix)
{
    my $h = $edgeMatrix->$#*;
    my $w = $edgeMatrix->[0]->$#*;
    my $step = 0;

    for my $c ( 0 .. $w )
    {
        my @col = map { $edgeMatrix->[$_][$c] } 0 .. $h;
        $logger->trace("sides col=$c (@col) s=$step");

        # Find every time we go from 0 to 1
        my $zero = true;
        for ( @col )
        {
            if ( $zero && $_      ) {
                $zero = false; $step++;
                $logger->trace("edge FOUND zero=$zero _=$_ step=$step");
            }
            elsif (       $_ == 0 ) {
                $zero = true;
                $logger->trace("edge ENDED zero=$zero _=$_ step=$step");
            }
        }
    }
    return $step;
}

sub edge(@row)
{
    my @edge;
    my $out = 1;
    for ( @row )
    {
        if ( $out && $_ ne '#' ) { $out = 0; push @edge, 1; }
        else {
            push @edge, 0;
            $out = true if $_ eq '#';
        }
    }
    return @edge;
}
