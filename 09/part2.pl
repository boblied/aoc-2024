#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# Copyright (c) 2024, Bob Lied
#=============================================================================
# Advent of Code 2024 Day 09 Part 2
#=============================================================================

use v5.40;
use FindBin qw($Bin); use lib "$FindBin::Bin/../../lib"; use AOC;
use lib "$FindBin::Bin";
AOC::setup;

use List::MoreUtils qw/last_index/;

$logger->info("START");

my @DISK;
my $block = 0;

use Free;
my $Free = Free->new();
my @File;

my $FreeSpace = 0;
my $FileSpace = 0;
while (<>)
{
    chomp;
    my @x = split "";

    for ( 0 .. $#x )
    {
        my $size = $x[$_];
        if ( $_ % 2 )   # Free space
        {
            $Free->insert($block, $size) if $size > 0;
            $FreeSpace += $size;
        }
        else # File, assign ID
        {
            my $id = int($_/2);
            push @File, { id => $id, size=>$size, start=>$block};
            $FileSpace += $size;
        }
        $block += $size;
    }
}
$logger->info("SPACE: files=$FileSpace, free=$FreeSpace");
$logger->info( scalar(@File), " files");
$logger->debug("FREE LIST:", $Free->show);
for my $file ( reverse @File )
{
    if ( my $newPlace = $Free->allocate($file->{size}, $file->{start}) )
    {
        $logger->debug("Found free block at $newPlace");
        $logger->debug("MOVE file $file->{id}, size=$file->{size} to $newPlace");
        $file->{start} = $newPlace;
    }
    else
    {
        $logger->debug("KEEP file $file->{id} at $file->{start}, size=$file->{size}");
    }
}

@DISK = ('.') x ($FreeSpace + $FileSpace);
for my $file ( @File )
{
    my $start = $file->{start};
    my $end = $start + $file->{size} - 1;
    @DISK[$start .. $end] = ($file->{id}) x ($end - $start + 1);
}
$logger->debug("DISK: ", join("", @DISK) );
my $fspace = 0;
for my $file ( @File )
{
    $fspace += $file->{size};
}
$logger->info("AFTER filespace=$fspace, Free = ", $Free->totalSpace());
$logger->debug($Free->show);


my $checksum = 0;
for ( 0 .. (last_index { $_ ne '.' } @DISK) )
{
    $checksum += $_ * $DISK[$_] if $DISK[$_] ne '.';
}
say "CHECKSUM 1: ", $checksum;

$checksum = 0;
for my $file ( @File )
{
    for my $p ( $file->{start} .. ($file->{start} + $file->{size} - 1) )
    {
        $checksum += $p * $file->{id};
    }
}
say "CHECKSUM 2: ", $checksum;

$logger->debug("DISK: ", join("", @DISK));

$logger->info("FINISH");

