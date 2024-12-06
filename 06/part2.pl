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

my $Floor = loadGrid();
$logger->debug( $Floor->show() );

my $dir = "^";
my @Start = (0,0);
FINDSTART: for my $r ( 0 .. $Floor->height() )
{
    for my $c ( 0 .. $Floor->width() )
    {
        if ( $Floor->get($r,$c) =~ m/[<>^v]/ )
        {
            @Start = ($r, $c);
            $dir = $Floor->get($r,$c);
            last FINDSTART;
        }
    }
}
$logger->info("START at (@Start) facing $dir");

sub isAtEdge($g, $r, $c, $dir)
{
    return ( $dir eq "^" && $r == 0
          || $dir eq "v" && $r == $g->height()
          || $dir eq ">" && $c == $g->width()
          || $dir eq "<" && $c == 0 )
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

sub move($g, $r, $c, $dir)
{
    if ( $dir eq '^' )
    {
        while ( ! ($r == 0  || $g->get($r-1, $c) eq '#' ) ) { $r-- }
    }
    elsif ( $dir eq 'v' )
    {
        while ( ! ($r == $g->height  || $g->get($r+1, $c) eq '#' ) ) { $r++ }
    }
    elsif ( $dir eq '<' )
    {
        my $row = $g->grid->[$r];
        while ( ! ($c == 0 || $row->[$c-1] eq '#') ) { $c-- }
    }
    elsif ( $dir eq '>' )
    {
        my $row = $g->grid->[$r];
        while ( ! ($c == $row->$#* || $row->[$c+1] eq '#') ) { $c++ }
    }
    return [$r, $c];
}

sub patrol($name, $path, $g, $dir, @pos)
{
    my %Turn;
    while ( ! isAtEdge($g, @pos, $dir) )
    {
        my ($next, $val) = getNext($g, @pos, $dir);
        if ( $val eq '#' )
        {
            my $turn = "$dir$Right{$dir}";
            if ( exists $Turn{$pos[0]}{$pos[1]}{$turn} )
            {
                # We've made this turn before at this corner, so we
                # must be in a loop
                $logger->debug("$name LOOP detected at corner @pos, $turn");
                return false;
            }
            $Turn{$pos[0]}{$pos[1]}{$turn} = true;

            $logger->debug("TURN at @pos $turn");
            $dir = $Right{$dir};

            next;
        }

        if ( defined $path )
        {   # One step at a time, to save all positions covered.
            @pos = @$next;
            $path->{"@pos"} = [@pos];
        }
        else
        {   # Zoom to the end of the row/column.
            @pos = move($g, @pos, $dir)->@*;
        }

        $logger->debug("MOVE to (@pos)");
    }
    $logger->debug("EXIT at (@pos)");
    return true;
}

# Do one patrol to the end, saving all the locations visited
my %path;
patrol("FIRST", \%path, $Floor->clone(), $dir, @Start);

# Now repeat, with each location replaced by a block
my $possibleBlocker = 0;
for my $p ( values %path )
{
    my $h = $Floor->clone();
    $h->set(@$p, '#');
    if ( patrol("TRY B=(@$p)", undef, $h, $dir, @Start) )
    {
        $logger->debug("B at (@$p) has no loop");
    }
    else
    {
        $possibleBlocker++;
        $logger->info("B at (@$p) has LOOP, count=$possibleBlocker");
    }
}
say $possibleBlocker;

say "POSSIBLE BLOCKS: $possibleBlocker";

$logger->info("FINISH");
