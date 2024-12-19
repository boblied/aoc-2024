#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# Copyright (c) 2024, Bob Lied
#=============================================================================
# Advent of Code 2024 Day 19 Part 1 "Linen Layout"
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

my $valid = 0;
for ( @Design )
{
    $logger->debug("isValid($_)");
    if ( isValid($_) )
    {
        $logger->debug("YES: $_");
        $valid++;
    }
    else
    {
        $logger->debug(" NO: $_");
    }
}
say $valid;

$logger->info("FINISH");

my %cache;
sub isValid($design)
{
    if ( $design eq "" ) { return true }
    elsif ( exists $cache{$design} ) { return $cache{$design} }

    my $first = substr($design, 0, 1);
    for my $p ( grep { $design =~ m/^$_/ } $Towel{$first}->@* )
    {
        (my $tail = $design) =~ s/^$p//;

        $logger->trace( "CHECK $design [$p | ", $tail, "]");
        if ( $tail eq "" || isValid($tail) )
        {
            $cache{$tail} = true;
            return true;
        }
    }
    $cache{$design} = false;
    return false;
}
