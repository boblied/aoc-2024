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
Cheats are reversible, so a cheat from 
