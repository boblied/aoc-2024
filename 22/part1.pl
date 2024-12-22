#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# Copyright (c) 2024, Bob Lied
#=============================================================================
# Advent of Code 2024 Day 22 Part 1 "Monkey Market" 
#=============================================================================

use v5.40;
use FindBin qw($Bin); use lib "$FindBin::Bin/../../lib"; use AOC;
AOC::setup;

$logger->info("START");

my @SecretNumber;
while (<>)
{
    chomp;
    push @SecretNumber, $_;
}
$logger->info(scalar(@SecretNumber), " secret numbers");

# my $secret = $SecretNumber[0];
#     my $s1 = step1($secret);
#     my $s2 = step2($s1);
#     my $s3 = step3($s2);
#     my $n  = step3(step2(step1($secret)));
# $logger->info(sprintf("  STEP 1: $secret -> (0x%8x)\t%d", $s1, $s1));
# $logger->info(sprintf("  STEP 2: $secret -> (0x%8x)\t%d", $s2, $s2));
# $logger->info(sprintf("  STEP 3: $secret -> (0x%8x)\t%d", $s3, $s3));
#s$logger->info(sprintf("STEP ALL: $secret -> (0x%8x)\t%d", $n,  $n ));

my $sum = 0;
for my $secret ( @SecretNumber )
{
    my $s = nextSecret($secret);
    $logger->info("2000 Times: $secret => $s");
    $sum += $s;
}

say "SUM: ", $sum;

$logger->info("FINISH");

sub step1($s) { prune(mix($s*64, $s)) }       # << 6

sub step2($s) { prune(mix( int($s/32), $s)) } # >> 5

sub step3($s) { prune(mix($s*2048, $s)) }     # << 11

sub mix($n, $s) { $n ^ $s }

sub prune($n) { $n % 16777216 }               # & 0x100 0000

sub nextSecret($s)
{
    for ( 1 .. 2000 )
    {
        $s = step3(step2(step1($s)));
    }
    return $s;
}
