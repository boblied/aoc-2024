#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# Copyright (c) 2024, Bob Lied
#=============================================================================
# Advent of Code 2024 Day 05 Part 2
#=============================================================================

use v5.40;
use FindBin qw($Bin); use lib "$FindBin::Bin/../../lib"; use AOC;
AOC::setup;

my %rule;
my @update;

while (<>)
{
    chomp;
    if ( m/(\d+)[|](\d+)/ )
    {
        push @{$rule{$1}}, $2;
    }
    elsif ( m/,/ )
    {
        push @update, [ split( /,/) ] 
    }
}

my $answer = 0;
for my ($i, $upd) ( indexed @update )
{
    my $place = findOrder($upd, \%rule);

    if ( isValidOrder( \%rule, $place, $upd->@*) )
    {
        $logger->info("ORDER $i VALID [@$upd]");
    }
    else
    {
        my @sorted = sort { $place->{$a} <=> $place->{$b} } $upd->@*;
        my $mid = $sorted[ $#sorted /2 ];
        $answer += $mid;
        $logger->info("ORDER $i INVALID mid=$mid answer=$answer [@sorted]");
    }
}

# DFS for topological sort, but only works for DAG. Input is not DAG.

# Returns a hash map of pages to their relative order
sub findOrder($upd, $rule)
{
    # Find the ordering only among the pages that are needed
    my %include = map { $_ => true } @$upd;
    my @stack;
    my %visited;
    for my $page ( $upd->@* )
    {
        if ( ! $visited{$page} )
        {
            topoSort($page, \%include, $rule, \%visited, \@stack, "");
        }
    }
    @stack = reverse @stack;
    $logger->debug("SORT: [@stack]");

    # Invert the sorted list to assign each page to its index
    my %place;
    for my ($i, $p) (indexed @stack)
    {
        $place{$p} = $i;
    }
    return \%place;
}

sub isValidOrder($rule, $place, @validate)
{
    my $isValid = true;
    my $first = shift @validate;
    while ( $isValid && defined(my $next = shift @validate) )
    {
        $isValid &&= $place->{$first} <= $place->{$next};
        if ( ! $isValid )
        {
            return false;
        }
        $first = $next;
    }

    return true;
}

sub topoSort($page, $include, $rule, $visited, $stack, $depth)
{
    $visited->{$page} = true;

    for my $adj ( $rule{$page}->@* )
    {
        $logger->debug("$depth TOPO $page, adj=$adj from {$rule{$page}->@*}" );
        if ( ! $visited->{$adj} && exists $include->{$adj} )
        {
            topoSort($adj, $include, $rule, $visited, $stack, "  $depth");
        }
    }
    push @$stack, $page;
}

say $answer;
