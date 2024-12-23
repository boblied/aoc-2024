# Advent of Code 2024 Day 23
[LAN Party](https://adventofcode.com/2024/day/23)

## Part 1

Use DFS to find connected components. Maybe ccomps from graphviz could apply.
Nope, different problem. The example is one completely connected graph, which
I discovered after implemented DFS for components.

The actual problem is "Start by looking for sets of three computers where each computer in the set is connected to the other two computers."

Represent the edges in the graph with a hash set, G{from}{to}.  Explicitly
look through two levels to get a triad. The first member of each triad must
be one that starts with 't'.

## Part 2
