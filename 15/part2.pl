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

my %replace = ( '#' => [ '#', '#' ],
                'O' => [ '[', ']' ],
                '@' => [ '@', '.' ],
                '.' => [ '.', '.' ], );

while (<>)
{
    chomp;
    if    ( m/^#/ )
    {
        push @Floor, [ map { $replace{$_}->@* } split // ];
    }
    elsif ( m/[<>v^]/ )
    {
        push @Move, split //
    }
}
my $Warehouse = AOC::Grid->new(height=>$#Floor, width=>$Floor[0]->$#*, grid=>\@Floor);

my @Myself = ($Warehouse->findChar('@'))[0]->@*;

$logger->debug("Start at (@Myself)", $Warehouse->show());

while ( my $mv = shift @Move )
{
    $logger->trace("MOVE $mv from (@Myself)");
    if ( $mv eq '>' )
    {
        # Change in place
        my $row = $Warehouse->grid()->[$Myself[0]];
        $Myself[1] = moveOne($row); # Update column
    }
    elsif ( $mv eq '<' )
    {
        # Operate on a backwards copy of the row
        my @row = reverse( $Warehouse->getRow($Myself[0]) );
        my $at = moveOne(\@row);
        $Warehouse->grid()->[$Myself[0]] = [ reverse @row ];
        $Myself[1] = $#row - $at;
    }
    elsif ( $mv eq '^' )
    {
        my @at = moveVertical($Warehouse, @Myself, -1);
        @Myself = @at;
    }
    elsif ( $mv eq 'v' )
    {
        my @at = moveVertical($Warehouse, @Myself, 1);
        @Myself = @at;
    }
    $logger->trace("Now at (@Myself)", $Warehouse->gdump );
}

$logger->info("Done moving", $Warehouse->gdump);
my @Box = $Warehouse->findChar('[');
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
        $row->[$me++] = '.';
        $row->[$me] = '@';
        return $me;
    }
    if ( $next eq '#' )
    {
        return $me;
    }

    # Must be a box there. Find the end of the boxes.
    my $rock = $me + 1;
    $rock++ while ( $row->[$rock] eq '[' || $row->[$rock] eq ']' );
    if ( $row->[$rock] ne '.' )
    {
        # Blocked, can't move
        return $me;
    }
    else # Shuffle the boxes and myself over one space
    {
        while ( $rock > $me )
        {
            $row->[$rock] = $row->[$rock-1];
            $rock--;
        }
        # Clear the old location of myself and return the new
        $row->[$me++] = '.';
        return $me;
    }
}

sub moveVertical($g, $meR, $meC, $dr) # dr = +1 or -1
{
    my $next = $g->get($meR + $dr, $meC);
    if ( $next eq '#' ) { return ($meR, $meC) } # Blocked, no move
    if ( $next eq '.' ) # Open, move there and clear current
    {
        $g->set($meR, $meC, '.');
        $meR += $dr;
        $g->set($meR, $meC, '@');
        return ($meR, $meC);
    }

    # The thing in the next row must be a box.
    my $boxR = $meR + $dr;
    my $boxLeft = ( $g->get($boxR, $meC) eq '[' ? $meC : $meC - 1 );

    my @stack = ( [$boxR, $boxLeft] );
    my @toBeMoved;
    while ( my $bx = pop @stack )
    {
        my ($br, $bl) = @$bx;
        my @adjoin = ( $g->get($br+$dr, $bl) , $g->get($br+$dr, $bl+1) );
        push @toBeMoved, [@$bx];

        if ( $adjoin[0] eq '#' || $adjoin[1] eq '#' ) # Blocked, nothing can move
        {
            return ($meR, $meC);
        }
        elsif ( $adjoin[0] eq "." && $adjoin[1] eq "." ) # End of stack, can move
        {
        }

        if ( $adjoin[0] eq "[" )   # Vertical stack, go on to next
        {
            push @stack, [$br + $dr, $bl];
        }
        elsif ( $adjoin[0] eq "]" ) # Stack and go left
        {
            push @stack, [$br + $dr, $bl -1];
        }
        if ( $adjoin[1] eq "[" ) # Stack and go right
        {
            push @stack, [$br + $dr, $bl + 1];
        }
    }

    # A diamond shape in the boxes will stack the point of the
    # diamond more than once, so look for that.
    my %beenMoved;
    while ( my $bx = pop @toBeMoved )
    {
        my ($bxR, $bxC) = @$bx;
        next if $beenMoved{"@$bx"};
        $g->set($bxR + $dr, $bxC, "["); $g->set($bxR + $dr, $bxC + 1, "]");
        $g->set($bxR      , $bxC, "."); $g->set($bxR      , $bxC + 1, ".");
        $beenMoved{"@$bx"} = true;
    }

    $g->set($meR, $meC, ".");
    $meR += $dr;
    $g->set($meR, $meC, "@");

    return ($meR, $meC);
}
