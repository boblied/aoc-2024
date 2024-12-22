# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# Keypad.pm
#=============================================================================
# Copyright (c) 2024, Bob Lied
#=============================================================================
# Description:
#=============================================================================

use v5.40;
use lib '../../lib/';
use AOC::Grid;

my @NK = ( [ '#', '#', '#', '#', '#' ],
           [ '#',  7 ,  8 ,  9 , '#' ],
           [ '#',  4 ,  5 ,  6 , '#' ],
           [ '#',  1 ,  2 ,  3 , '#' ],
           [ '#', '#',  0 , 'A', '#' ],
           [ '#', '#', '#', '#', '#' ], );


my @DK = ( [ '#', '#', '#', '#', '#' ],
           [ '#', '#', '^', 'A', '#' ],
           [ '#', '<', 'v', '>', '#' ],
           [ '#', '#', '#', '#', '#' ], );


my $nkp = AOC::Grid->new(grid => \@NK, height=> 4, width => 4);
say $nkp->show;
my %Nmove;
for my $from ( 0 .. 9, 'A' )
{
    my $start = ($nkp->findChar($from))[0];
    for my $to ( 0 .. 9, 'A' )
    {
        my $end = ($nkp->findChar($to))[0];

        my $path = bfs($nkp, @$start, @$end);
        say "FROM $from(@$start) TO $to(@$end) = @$path";
        $Nmove{$to}{$from} = $path;
    }
}

my $dkp = AOC::Grid->new(grid =>\@DK, height => 3, width => 4);
say $dkp->show;
my %Dmove;
for my $from ( '<', '>', '^', 'v', 'A' )
{
    my $start = ($dkp->findChar($from))[0];
    for my $to ( '<', '>', '^', 'v', 'A' )
    {
        my $end = ($dkp->findChar($to))[0];

        my $path = bfs($dkp, @$start, @$end);
        say "FROM $from(@$start) TO $to(@$end) = @$path";
        $Dmove{$to}{$from} = $path;
    }
}

say "DONE";

sub bfs($g, $startR, $startC, $endR, $endC)
{
    my @queue;
    my %seen;
    push @queue, [ $startR, $startC, [] ];
    while ( my $x = shift @queue )
    {
        my ($r, $c, $path) = @$x;

        if ($r == $endR && $c == $endC )
        {
            return $path;
        }
        $seen{"$r $c"} = true;

        for ( [$r-1,$c,'^'], [$r+1,$c,'v'], [$r,$c-1,'<'], [$r,$c+1,'>'] )
        {
            my ($v, $h, $d) = @$_;
            if ( $g->get($v,$h) ne '#' && !$seen{$v}{$h} )
            {
                push @queue, [ $v, $h, [ @$path, $d ] ];
            }
        }
        say "loop end";
    }
    return undef;
}

