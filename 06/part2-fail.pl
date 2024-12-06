#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# Copyright (c) 2024, Bob Lied
#=============================================================================
# Advent of Code 2024 Day 06 Part 2
#=============================================================================

use v5.40;
use FindBin qw($Bin); use lib "$FindBin::Bin/../../lib"; use AOC;
AOC::setup;
use AOC::Grid;

my %Right = ( '^' => '>', '>' => 'v', 'v' => '<', '<' => '^' );

$logger->info("START");

my $g = loadGrid();
$logger->debug( $g->show() );

my $blocker = 0;

my $dir = "^";
my @pos = (0,0);
FINDSTART: for my $r ( 0 .. $g->height() )
{
    for my $c ( 0 .. $g->width() )
    {
        if ( $g->get($r,$c) =~ m/[<>^v]/ )
        {
            @pos = ($r, $c);
            $dir = $g->get($r,$c);
            last FINDSTART;
        }
    }
}
$logger->info("START at (@pos) facing $dir");
fill($g, @pos, $dir);

sub isAtEdge($g, $r, $c, $dir)
{
    return ( $dir eq "^" && $r == 0
          || $dir eq "v" && $r == $g->height()
          || $dir eq ">" && $c == $g->width()
          || $dir eq "<" && $c == 0 )
}

sub fill($grid, $r, $c, $dir)
{
    my $g = $grid->grid();
    my $end;

    if ( $dir eq '<' || $dir eq '>' )
    {
        for ( my $j = $c; $j >= 0 && $g->[$r][$j] ne '#' ; $j-- )
        {
            $g->[$r][$j] .= "$dir"
        }
        for (my $j = $c+1; $j <= $grid->width && $g->[$r][$j] ne '#'; $j++ )
        {
            $g->[$r][$j] .= "$dir"
        }
    }
    elsif ( $dir eq '^' || $dir eq 'v' )
    {
        for ( my $j = $r; $j >= 0 && $g->[$j][$c] ne '#' ; $j-- )
        {
            $g->[$j][$c] .= "$dir"
        }
        for (my $j = $r; $j <= $grid->height && $g->[$j][$c] ne '#'; $j++ )
        {
            $g->[$j][$c] .= "$dir"
        }
    }
}

sub getNext($g, $r, $c, $dir)
{
    my $pos;
    if    ( $dir eq '^' ) { $pos = $g->north($r,$c) }
    elsif ( $dir eq 'v' ) { $pos = $g->south($r,$c) }
    elsif ( $dir eq '>' ) { $pos = $g->east($r,$c) }
    elsif ( $dir eq '<' ) { $pos = $g->west($r,$c) }
    defined($pos) ? ($pos, $g->get(@$pos)) : undef;
}

while ( ! isAtEdge($g, @pos, $dir) )
{
    my ($next, $val) = getNext($g, @pos, $dir);
    if ( $val eq '#' )
    {
        $logger->debug("TURN at @pos from $dir to ", $Right{$dir});
        $dir = $Right{$dir};
        fill($g, @pos, $dir); # Mark vertical or horizontal piece between # or edge
        next;
    }

    @pos = @$next;
    # If I turned right at this point, would I be on a path that
    # I've already traveled in that direction?
    if ( index($val, $Right{$dir}) >= 0 )
    {
        $blocker++;
        $logger->info("BLOCK at (@pos), dir=$dir val=$val block=$blocker");
    }

    $logger->debug("MOVE to (@pos)");
}
$logger->info("EXIT at (@pos)");
$logger->debug($g->show());

say $blocker;

$logger->info("FINISH");
