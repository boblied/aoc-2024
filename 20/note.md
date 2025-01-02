# Advent of Code 2024 Day 20
[Race Condition](https://adventofcode.com/2024/day/20)

## Part 1

Oh, this is day 16 again. Find the shortest path, then look at adjoining walls.
Too bad I still haven't solved day 16.

Idea: 
 - Run Dijkstra backward from END to START to find finishing distance of
every point on path

 - For every point on the path, see if removing an adjoining wall would
give access to a point with a shorter finishing distance

## Part 2

Using the same distance information, expand the diamond that's reachable
around each point
                    
        c  c  c  c  c  c   c  c  c  c  c
       -5 -4 -3 -2 -1     +1 +2 +3 +4 +5
  r-5                  5
  r-4               5  4  5
  r-3            5  4  3  4  5
  r-2         5  4  3  2  3  4  5
  r-1      5  4  3  2  1  2  3  4  5 
  r     5  4  3  2  1  0  1  2  3  4  5
  r+1      5  4  3  2  1  2  3  4  5
  r+2         5  4  3  2  3  4  5
  r+3            5  4  3  4  5
  r+4               5  4  5
  r+5                  5

But that's an absurd number of checks -- a distance of 20 would have 761 cells
in the diamond, and there would be massive overlap from one point on the path
to the next.

Alternatively: for each pair of points in the path, if the second is closer than
the first and can be reached with a Manhattan distance of 20, it's a shortcut.
There are about 9000 steps in the input path, so pairwise that's about 81,000,000
comparisons. 
