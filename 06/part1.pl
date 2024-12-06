#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# Copyright (c) 2024, Bob Lied
#=============================================================================
# Advent of Code 2024 Day 06 Part 1
#=============================================================================

use v5.40;
use FindBin qw($Bin); use lib "$FindBin::Bin/../../lib"; use AOC;
AOC::setup;
use AOC::Grid;

$logger->info("START");

my $g = loadGrid();
$logger->debug( $g->show() );

my $dir = "^";
my @pos = (0,0);
my $seen = 1;
FINDSTART: for my $r ( 0 .. $g->height() )
{
    for my $c ( 0 .. $g->width() )
    {
        if ( $g->get($r,$c) =~ m/[<>^v]/ )
        {
            @pos = ($r, $c);
            $dir = $g->get($r,$c);
            $g->set($r,$c, 'X');
            last FINDSTART;
        }
    }
}
$logger->info("START at (@pos) facing $dir");

sub isAtEdge($g, $r, $c, $dir)
{
    return ( $dir eq "^" && $r == 0
          || $dir eq "v" && $r == $g->height()
          || $dir eq ">" && $c == $g->width()
          || $dir eq "<" && $c == 0 )
}


while ( ! isAtEdge($g, @pos, $dir) )
{
    if ( $dir eq "^" && $g->get($g->north(@pos)->@*) eq '#' )
    {
        $logger->debug("TURN at @pos from $dir to >");
        $dir = ">"; next;
    }
    elsif ( $dir eq '>' && $g->get($g->east(@pos)->@*) eq '#' )
    {
        $logger->debug("TURN at @pos from $dir to v");
        $dir = "v"; next;
    }
    elsif ( $dir eq 'v' && $g->get($g->south(@pos)->@*) eq '#' )
    {
        $logger->debug("TURN at @pos from $dir to <");
        $dir = "<"; next;
    }
    elsif ( $dir eq '<' && $g->get($g->west(@pos)->@*) eq '#' )
    {
        $logger->debug("TURN at @pos from $dir to ^");
        $dir = "^"; next;
    }

    if    ( $dir eq '^' )
    {
        @pos = $g->north(@pos)->@*;
        $seen++ if ( $g->get(@pos) ne 'X' );
        $g->set(@pos, 'X');
    }
    elsif ( $dir eq '>' )
    {
        @pos = $g->east(@pos)->@*;
        $seen++ if ( $g->get(@pos) ne 'X' );
        $g->set(@pos, 'X');
    }
    elsif ( $dir eq 'v' )
    {
        @pos = $g->south(@pos)->@*;
        $seen++ if ( $g->get(@pos) ne 'X' );
        $g->set(@pos, 'X');
    }
    elsif ( $dir eq '<' )
    {
        @pos = $g->west(@pos)->@*;
        $seen++ if ( $g->get(@pos) ne 'X' );
        $g->set(@pos, 'X');
    }
    $logger->debug("MOVE to (@pos), seen=$seen");
}

$logger->info("EXIT at (@pos)");
say $seen;

$logger->info("FINISH");
