#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# Copyright (c) 2024, Bob Lied
#=============================================================================
# Advent of Code 2024 Day 19 Part 2 "Linen Layout"
#=============================================================================

use v5.40;
use FindBin qw($Bin); use lib "$FindBin::Bin/../../lib"; use AOC;
AOC::setup;

$logger->info("START");

my %Towel;
my @Design;
while (<>)
{
    chomp;

    if ( m/,/ )
    {
        for my $towel ( split ", " )
        {
            push @{$Towel{ substr($towel, 0, 1) }}, $towel;
        }
        next;
    }
    elsif ( m/^$/ ) { next }

    push @Design, $_;

}

if ( $logger->is_debug ) {
    for my $first ( sort keys %Towel )
    {
        $logger->debug("Starts with $first: ", $Towel{$first}->$#*);
    }
}

my $count = 0;
for ( @Design )
{
    $logger->debug("countValid($_)");
    my $designCount = countValid($_, 0);
    if ( $designCount > 0 )
    {
        $logger->debug("YES: $designCount $_");
        $count += $designCount;
    }
    else
    {
        $logger->debug(" NO: $_");
    }
}
say $count;

$logger->info("FINISH");

my %cache;
sub countValid($design, $count, $depth="")
{
    if ( $design eq "" )
    {
        return $count+1;
    }
    elsif ( exists $cache{$design}{$count} )
    {
        return $cache{$design}{$count}
    }

    my $first = substr($design, 0, 1);
    my $sofar = $count;
    for my $p ( grep { $design =~ m/^$_/ } $Towel{$first}->@* )
    {
        (my $tail = $design) =~ s/^$p//;

        $logger->trace("$depth CHECK $design,$count [$p | ", $tail, "]");
        $sofar += countValid($tail, $count, "  $depth");
    }
    $cache{$design}{$count} = $sofar;
    return $sofar;
}
