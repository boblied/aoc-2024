# Advent of Code 2024 Day 18
[RAM Run](https://adventofcode.com/2024/day/18)

## Part 1

Another BFS for shortest path. Details in the input: the grid is 70x70,
even if there aren't any input points in the outside edges. The task is
asking to place T blocks on the grid, then determine the shortest path.
It is *not* asking to simulate dropping a byte at a time and dynamically
recalculating the best path.

## Part 2

Once we have part 1 with an input parameter for the time limit, just
run it repeatedly. Bisect the input (1725 is the midpoint), then bisect
which half it appears in, and continue drilling down to find the 
answer. Done manually.
