#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# Copyright (c) 2024, Bob Lied
#=============================================================================
# Advent of Code 2024 Day 22 Part 2 "Monkey Market" 
#=============================================================================

use v5.40;
use FindBin qw($Bin); use lib "$FindBin::Bin/../../lib"; use AOC;

my $Iterations = 2000;
AOC::setup({"n:i" => \$Iterations });

$logger->info("START");

my @SecretNumber;
while (<>)
{
    chomp;
    push @SecretNumber, $_;
}
$logger->info(scalar(@SecretNumber), " secret numbers");


my $sum = 0;
my @diff = [ 0 ];

for my $secret ( @SecretNumber )
{
    my $s = optSecret($secret, $Iterations);
    $logger->info("2000 Times: $secret => $s");
    $sum += $s;
}

say "SUM: ", $sum;

$logger->info("FINISH");

sub mix($n, $s) { $n ^ $s }
sub prune($n) { $n % 16777216 }               # & 0xfff ffff

sub step1($s) { prune(mix($s*64, $s)) }       # << 6
sub opt1($s)  { (($s <<  6) ^ $s) & 0xffffff }

sub step2($s) { prune(mix( int($s/32), $s)) } # >> 5
sub opt2($s)  { (($s >>  5) ^ $s) & 0xffffff }

sub step3($s) { prune(mix($s*2048, $s)) }     # << 11
sub opt3($s)  { (($s << 11) ^ $s) & 0xffffff }

sub nextNumber($s) {
    $s   = (($s <<  6) ^ $s) & 0xffffff;
    $s   = (($s >>  5) ^ $s) & 0xffffff;
    return (($s << 11) ^ $s) & 0xffffff;
}

sub monkey($secret, $times)
{
    my $diff = 0;
    my $prevPrice = 0;
    my $nextPrice = $secret % 10;

    my $fourseq = 0;

    # Prime the pump with the first four numbers.
    my $next = nextNumber($secret);
    $nextPrice = $next % 10;
    $diff = $nextPrice - $prevPrice;
    $fourseq = ($diff & 0xff)
    $prevPrice = $nextPrice;

    $next = nextNumber($next);
    $diff = $nextPrice - $prevPrice;
    $fourseq = (($fourseq << 8) | ($diff & 0xff) & 0xffffffff);
    $prevPrice = $nextPrice;

    $next = nextNumber($next);
    $diff = $nextPrice - $prevPrice;
    $fourseq = (($fourseq << 8 | ($diff & 0xff) & 0xffffffff);
    $prevPrice = $nextPrice;

    $next = nextNumber($next);
    $diff = $nextPrice - $prevPrice;
    $fourseq = (($fourseq << 8) | ($diff & 0xff) & 0xffffffff);
    $prevPrice = $nextPrice;

    $SeqPrice{$fourseq} = $nextPrice;

    $times -= 4;
    while ( $times-- )
    {
        $next = nextNumber($start);

        $nextPrice = $next % 10;
        $diff = $nextPrice - $prevPrice;
        $fourseq = (($fourseq << 8) | ($diff & 0xff) & 0xffffffff);

        $SeqPrice{$fourseq} = $nextPrice if ( ! exists $SeqPrice{$fourseq} );

        $prevPrice = $nextPrice;
        $secret = $next;
    }
}
