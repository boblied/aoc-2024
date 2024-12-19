# Advent of Code 2024 Day 19
[Linen Layout](https://adventofcode.com/2024/day/19)

## Part 1

Recursive depth-first search, with cache.

## Part 2

Instead of returning success as soon as the end is reached,
we need to increment the count and continue following other paths.
Add a count parameter to the recursion, only incremented at the end.
Still need to cache for reasonable finish times, but the cache
now is for pairs of (string,countSoFar).
