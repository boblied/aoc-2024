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
