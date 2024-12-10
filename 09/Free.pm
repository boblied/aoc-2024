# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# Free.pm
#=============================================================================
# Copyright (c) 2024, Bob Lied
#=============================================================================
# Description: Free list
#=============================================================================

use v5.40;
use feature "class"; no warnings "experimental::class";
use List::Util qw/min/;

class Free;

field @free;
ADJUST { $free[$_] = [] for 0..9 }

method insert($at, $size)
{
    push @{$free[$size]}, $at;
    $free[$size] = [ sort { $a <=> $b } $free[$size]->@* ];
#   return;
#   my $list = $free[$size];
#   # Keep the list sorted
#   if ( $at > $list->[-1] )  # Most common while building
#   {
#       push @$list, $at;
#   }
#   else
#   {
#       for ( my $i = 0 ; $i <= $list->$#* ; $i++ )
#       {
#           if ( $list->[$i] > $at )
#           {
#               splice(@$list, $i, 0, $at);
#           }
#       }
#   }
}

method allocate($need, $below)
{
    # Select candidat lists. It must be a big enough block,
    # there must be free blocks on the list, and the first
    # free block must be to the left of the given position.
    my @bigEnough =
        grep { $_ >= $need
                && scalar(@{$free[$_]}) > 0
                && $free[$_][0] < $below
            } 1 .. 9;

    return undef if !@bigEnough;

    # Of the available lists, choose the one that has a free block
    # furthest to the left. Lists are known to be sorted.
    my $size = (sort { $free[$a][0] <=> $free[$b][0] } @bigEnough)[0];

    my $place = shift @{$free[$size]}; # Remove from free list
    my $remain = $size - $need;
    if ( $remain > 0 )  # Put smaller free block back in the right place
    {
        $self->insert($place+$need, $remain);
        #push @{$free[$remain]}, $place+$need;
    }
    return $place;

    for my $size ( grep { $_ >= $need } reverse 1..9 )
    {
        next if ! scalar($free[$size]->@*);

        my $place = shift @{$free[$size]};
        my $remain = $size - $need;
        if ( $remain > 0 )
        {
            push @{$free[$remain]}, $place+$need;
            $free[$remain] = [ sort { $a <=> $b } $free[$remain]->@* ];
        }
        return $place;
    }
    return undef;
}

method totalSpace()
{
    my $sum;
    $sum += $_ * scalar($free[$_]->@*) for 1 .. 9;
    return $sum;
}

method show()
{
    my $s;
    $s .= "\nFREE[$_]=($free[$_]->@*)" for 1 .. 9;
    return $s;
}
