#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# Copyright (c) 2024, Bob Lied
#=============================================================================
# Advent of Code 2024 Day 21 Part 1 "Keypad Conundrum" 
#=============================================================================

use v5.40;
use FindBin qw($Bin); use lib "$FindBin::Bin/../../lib"; use AOC;
use lib ".";
use Keypad;

my @Code = ( '' );
AOC::setup({ "c:s" => \$Code[0] });

#     [0] [1] [2]
# [0]  7   8   9
# [1]  4   5   6
# [2]  1   2   3
# [3]      0   A    # A = 10
my %Numeric = ( 7=>[0,0], 8=>[0,1],  9=>[0,2],
                4=>[1,0], 5=>[1,1],  6=>[1,2],
                1=>[2,0], 2=>[2,1],  3=>[2,2],
                          0=>[3,1], 10=>[3,2], 'A'=>[3,2], );

#     [0] [1] [2]
# [0]      ^   A    # A = 10
# [1]  <   v   >
my %Directional = (             '^'=>[0,1], 'A'=>[0,2],  '10'=>[0,2], 
                    '<'=>[1,0], 'v'=>[1,1], '>'=>[1,2], );


$logger->info("START");


if ( $Code[0] eq '' )
{
    while (<>)
    {
        chomp;
        push @Code, $_;
    }
}

$logger->info("Codes: @Code");


$logger->info("FINISH");
