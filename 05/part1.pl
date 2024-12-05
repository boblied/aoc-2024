#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# Copyright (c) 2024, Bob Lied
#=============================================================================
# Advent of Code 2024 Day 05 Part 1 
#=============================================================================

use v5.40;
use FindBin qw($Bin); use lib "$FindBin::Bin/../../lib"; use AOC;
AOC::setup;

my %rule;
my @order;

while (<>)
{
    chomp;
    if ( m/(\d+)[|](\d+)/ )
    {
        push @{$rule{$1}}, $2;
    }
    elsif ( m/,/ )
    {
        push @order, [ split( /,/) ] 
    }
}

my $answer = 0;
for my ($i, $ord) ( indexed @order )
{
    my $mid = $ord->[ $ord->$#* /2 ];
    if ( validOrder($ord, \%rule) )
    {
        $answer += $mid;
        $logger->info("ORDER $i VALID mid=$mid answer=$answer [@$ord]");
    }
    else
    {
        $logger->info("ORDER $i INVALID [@$ord]");
    }
}

# DFS for topological sort, but only works for DAG. Input is not DAG.

sub validOrder($ord, $rule)
{
    # Find the ordering only among the pages that are needed
    my %include = map { $_ => true } @$ord;
    my @stack;
    my %visited;
    for my $page ( $ord->@* )
    {
        if ( ! $visited{$page} )
        {
            topoSort($page, \%include, $rule, \%visited, \@stack, "");
        }
    }
    @stack = reverse @stack;
    $logger->debug("SORT: [@stack]");

    my %place;
    for my ($i, $p) (indexed @stack)
    {
        $place{$p} = $i;
    }

    my $isValid = true;
    my $first = shift @$ord;
    while ( $isValid && defined(my $next = shift @$ord) )
    {
        $isValid &&= $place{$first} <= $place{$next};
        if ( ! $isValid )
        {
            $logger->debug("INVALID at $first,$next ($place{$first},$place{$next})");
        }
        $first = $next;
    }
    return $isValid;

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
