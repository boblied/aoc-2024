#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# Copyright (c) 2024, Bob Lied
#=============================================================================
# Advent of Code 2024 Day 15 Part 1 "Warehouse Woes" 
#=============================================================================

use v5.40;
use FindBin qw($Bin); use lib "$FindBin::Bin/../../lib"; use AOC;
use AOC::Grid;

use List::AllUtils qw/first_index/;

AOC::setup;
$logger->info("START");

my @Floor;
my @Move;

while (<>)
{
    chomp;
    if    ( m/^#/ )     { push @Floor, [ split // ] }
    elsif ( m/[<>v^]/ ) { push @Move, split // }
}
my $Warehouse = AOC::Grid->new(height=>$#Floor, width=>$Floor[0]->$#*, grid=>\@Floor);

my @Myself = ($Warehouse->findChar('@'))[0]->@*;

$logger->debug("Start at (@Myself)", $Warehouse->show());

while ( my $mv = shift @Move )
{
    $logger->debug("MOVE $mv from (@Myself)");
    if ( $mv eq '>' )
    {
        # Change in place
        my $row = $Warehouse->grid()->[$Myself[0]];
        $Myself[1] = moveOne($row); # Update column
    }
    elsif ( $mv eq '<' )
    {
        # Operate on a copy of the row
        my @row = reverse( $Warehouse->getRow($Myself[0]) );
        my $at = moveOne(\@row);
        $Warehouse->grid()->[$Myself[0]] = [ reverse @row ];
        $Myself[1] = $#row - $at;
    }
    elsif ( $mv eq '^' )
    {
        my @vert = reverse( $Warehouse->getColumn($Myself[1]) );
        my $at = moveOne(\@vert);
        $Warehouse->replaceColumn($Myself[1], [ reverse @vert ]);
        $Myself[0] = $#vert - $at;
    }
    elsif ( $mv eq 'v' )
    {
        my @vert = $Warehouse->getColumn($Myself[1]);
        my $at = moveOne(\@vert);
        $Warehouse->replaceColumn($Myself[1], \@vert);
        $Myself[0] = $at;
    }
    $logger->debug("Now at (@Myself)", $Warehouse->show );
}

$logger->info("Done moving");
my @Box = $Warehouse->findChar('O');
my $GPS = 0;
for my $box ( @Box )
{
    my ($r, $c) = $box->@*;
    my $gps = 100*$r + $c;
    $GPS += $gps;
}

say "GPS Sum: $GPS";

$logger->info("FINISH");

sub pushRock($row)
{
    my $me = first_index { $_ eq '@' } $row->@*;
    my $rock = first_index { $_ eq 'O' } $row->@[$me+1 .. $row->$#* ];
    my $wall;
    if ( $rock == -1 )
    {
        $wall = $me + 1 + first_index { $_ eq '#' } $row->@[$me+1 .. $row->$#* ];
    }
    else
    {
        my $nextRock = first_index { $_ eq 'O' } $row->@[$rock+1 .. $row->$#* ];
    }

    my $p = $wall - 1;
    while ( $p > $me )
    {
        if    ( $row->[$p] eq 'O' )
        {
            $row->[--$wall] = $row->[$p];
            $row->[$p] = '.' if $p < $wall;
        }
        $p--
    }

    # Last move is myself. In this order, in case nothing moved.
    $row->[$me] = '.';
    $row->[--$wall] = '@';

    return $wall; # Ends up pointing at @
}

sub moveOne($row)
{
    my $me = first_index { $_ eq '@' } $row->@*;
    my $next = $row->[$me+1];
    if ( $next eq '.' )
    {
        $row->[$me] = '.'; $row->[$me+1] = '@'; return $me + 1;
    }
    if ( $next eq '#' )
    {
        return $me;
    }

    # Must be an O there. Is it more than 1?
    my $rock = $me + 1;
    $rock++ while ( $row->[$rock] eq 'O' );
    if ( $row->[$rock] ne '.' )
    {
        # Blocked, can't move
        return $me;
    }
    else # Move the whole set by rotating the front to the back
    {
        $row->[$rock  ] = 'O';
        $row->[$me]     = '.';
        $row->[$me + 1] = '@';
        return $me+1;
    }
}
