#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# Copyright (c) 2024, Bob Lied
#=============================================================================
# Advent of Code 2024 Day 18 Part 1 "RAM Run"
#=============================================================================

use v5.40;
use FindBin qw($Bin); use lib "$FindBin::Bin/../../lib"; use AOC;
use AOC::Grid;

my $TimeLimit = 5000;
my $Width = 70;
my $Height = 70;;
AOC::setup({ "t:i" => \$TimeLimit, "h:i" => \$Height, "w:i" => \$Width });

$logger->info("START");

my @fallingByte;
while (<>)
{
    chomp;
    my ($c, $r) = split ",";
    push @fallingByte, [$r, $c];
}

$logger->info("T:$TimeLimit $Height x $Width, bytes=", scalar(@fallingByte));

my @Grid;
for ( 0 .. $Height ) { push @Grid, [ ('.') x ($Width+1) ] }

my $RAM = AOC::Grid->new(grid=>\@Grid, height=>$Height, width=>$Width);
my @START = (0,0);
my @END   = ($Height, $Width);

for ( my $t = 0; $t < $TimeLimit; $t++ )
{
    my ($r, $c) = $fallingByte[$t]->@*;
    $RAM->set($r, $c, '#');
}
if ( $logger->is_debug ) { $logger->info("RAM after $TimeLimit", $RAM->gdump); }

my $path = navigate($RAM, @START, @END);
say $path;

$logger->info("FINISH");

sub navigate($ram, $startR, $startC, $endR, $endC)
{
    my @queue;
    my %seen;
    my $shortest = $ram->width * $ram->height + 1;

    my $distance = AOC::Grid::makeGrid($ram->height, $ram->width, $shortest);
    $distance->set($startR, $startC, 0);
    my $predecessor = AOC::Grid::makeGrid($ram->height, $ram->width, $shortest);

    push @queue, [$startR, $startC, 0, [] ];
    while ( my $x = shift @queue )
    {
        my ($r, $c, $plength, $path) = $x->@*;
        if ( $r == $endR && $c == $endC )
        {
            $plength++;
            push @$path, [$r,$c];
            $shortest = $plength if $plength < $shortest;
            return $distance->get($endR, $endC);
        }
        next if ( $seen{$r}{$c} );
        $seen{$r}{$c} = true;
        push @$path, [$r, $c];

        for ( grep { $_->[0] ne '#' } $ram->aroundNESW($r,$c) )
        {
            my ($nr,$nc) = $_->[1]->@*;
            next if ( $seen{$nr}{$nc} );
            my $dist = $plength + 1;
            next if ( $dist >= $shortest );

            if ( $dist <= $distance->get($nr, $nc) )
            {
                $distance->set($nr, $nc, $dist);
                push @queue, [ $nr, $nc, $plength+1, $path];
            }
        }
    }
    return -1;
}
