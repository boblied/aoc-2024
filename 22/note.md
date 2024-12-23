# Advent of Code 2024 Day 22
[Monkey Market](https://adventofcode.com/2024/day/22)

## Part 1

Composition of a few bit operations.

## Part 2

Idea: Store the sequence of four differences in the bytes of an integer
by shifting and masking. Use the resulting integer as key to a hash to
accumulate the totals.
