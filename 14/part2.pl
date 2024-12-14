#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# Copyright (c) 2024, Bob Lied
#=============================================================================
# Advent of Code 2024 Day 14 Part 2 "Restroom Redoubt" 
#=============================================================================

use v5.40;
use FindBin qw($Bin); use lib "$FindBin::Bin/../../lib"; use AOC;
use AOC::Grid;

my $H = 103;
my $W = 101;
my $Time = 100;

my $logger;
{ # Setup
    my $DoDebug = 0;
    use Log::Log4perl qw(:easy);
    $logger = Log::Log4perl->get_logger();
    Log::Log4perl->easy_init({
            level => $WARN,
            layout => "%d{HH:mm:ss.SSS} %p{1} %m%n"
        });
    my %DBLEVEL = ( 1 => $INFO, 2 => $DEBUG, 3 => $TRACE,
        i => $INFO, d => $DEBUG, t => $TRACE, );

    use Getopt::Long;
    GetOptions("h:i" => \$H, "w:i"=> \$W, "t:i" => \$Time, "debug:s" => \$DoDebug);
    $logger->level($DBLEVEL{$DoDebug}) if $DoDebug;
}


$logger->info("START");
my @Robot;

#        0 <--- W --->
#     0  #############      Points on the midR or MidC line go into
#     ^  # 1   #   2 #      Quadrant 0.
#     |  #     #     #
#     |  ############# <- midR
#     |  #     #     #
#     H  # 3   #   4 #
#     v  #############
#              ^-- midC
#my $H = 103;
#my $W = 101;
my $midR = int($H / 2); # Assuming odd dimensions
my $midC = int($W / 2);
my @Quad = (0, 0,0,0,0);

while (<>)
{
    chomp;
    my ($px,$py,$vx,$vy) = m/(-?\d+)/g;
    push @Robot, [ [$py, $px ], [$vy, $vx] ];
    $logger->trace("Robot $. ", showRobot($Robot[-1]));
}

my $rob = $Robot[0];
my @p = $rob->[0]->@*;
my @v = $rob->[1]->@*;

my $Room = AOC::Grid::makeGrid($H-1, $W-1, 0);
for my $r ( @Robot )
{
    my @p = $r->[0]->@*;
    $Room->set(@p, 1+$Room->get(@p));

    $Quad[ ptToQuad(@p) ]++;
}
$logger->debug("BEGIN Qaudrants=[@Quad]", $Room->show);

for my $t ( 1 .. $Time )
{
    for my $rob ( @Robot )
    {
        my @p = $rob->[0]->@*;
        my @v = $rob->[1]->@*;
        my @n = move(@p, @v);
        $rob->[0] = [@n];

        $Room->set(@p, $Room->get(@p)-1);
        $Room->set(@n, $Room->get(@n)+1);

        $Quad[ ptToQuad(@p) ]--;
        $Quad[ ptToQuad(@n) ]++;

        if ( $logger->level == 3 ) {
                $logger->trace("T=$t p=(@p)+v(@v)=n(@n) Q=(@Quad)", $Room->show()); }
    }
    my $asS = $Room->gdump;
    if ( $asS =~ m/11111111/ ) {
        $logger->info("Possible horizontal line at T=$t, $asS");
        exit(1);
    }
    if ( $Quad[1] == $Quad[2]  &&  $Quad[3] == $Quad[4] )
    {
        $logger->info("Possible symmetry detected at T=$t Q=(@Quad)");

        if ( isSymArray($Room->grid()) )
        {
            $logger->info("HAS SYMMETRY" );
            $logger->debug($Room->gdump());
            exit(0);
        }
    }
}

$logger->debug("END ", $Room->show);

$logger->debug("Middle: r=$midR c=$midC");

my $q1 = count($Room, 0,       0,        $midR-1, $midC-1);
my $q2 = count($Room, 0, $midC+1,        $midR-1, $W-1);
my $q3 = count($Room, $midR+1, 0,        $H-1,    $midC-1);
my $q4 = count($Room, $midR+1, $midC+1,  $H-1,    $W-1);

$logger->info("QUADRANTS: q1=$q1 q2=$q2 q3=$q3 q4=$q4");
$logger->info("QUADRANTS: @Quad");

say "Safety factor: ", $q1 * $q2 * $q3 * $q4;


$logger->info("FINISH");

sub showRobot($r)
{
    my ($pos, $speed) = $r->@*;
    return "at (@$pos)\tspeed=(@$speed)";
}

sub move($pr,$pc,  $vr, $vc)
{
    return ( (($pr+$vr) % $H), (($pc+$vc) % $W) );
}

sub count($room, $ulR, $ulC, $lrR, $lrC)
{
    $logger->debug("count ($ulR $ulC) ($lrR $lrC)");
    my $n = 0;
    for my $r ( $ulR .. $lrR) 
    {
        for my $c ( $ulC .. $lrC )
        {
            $n += $room->get($r,$c);
        }
    }
    return $n;
}

sub ptToQuad($r,$c)
{
    if    ( $r < $midR ) { return ($c < $midC ? 1 : $c > $midC ? 2 : 0 ) }
    elsif ( $r > $midR ) { return ($c < $midC ? 3 : $c > $midC ? 4 : 0 ) }
    else                 { return 0 }
}

sub checkForXmas($room)
{
}

sub isSymRow($row)
{
    for ( my $left = 0, my $right = $row->$#* ; $left != $right; $left++, $right-- )
    {
        return false if $row->[$left] != $row->[$right];
    }
    return true;
}

sub isSymArray($arr)
{
    use List::Util qw/all/;
    return all { isSymRow($_) } $arr->@*;
}
