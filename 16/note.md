# Advent of Code 2024 Day 16
[Reindeer Maze](https://adventofcode.com/2024/day/16)

## Part 1

Shortest path problem. Did a BFS from scratch first, without looking
anything up, but pretty sure it should have been Dijkstra's algorithm.
It was. Really nasty time getting all the details right. The trick is
to make the node IDs (x,y,direction), not just the (x,y). Not helped
by trying to use a List::PriorityQueue that only works on scalars.
I couldn't pass a reference to a list, because internally, it does
a compare on scalar values (the array reference), not on the list
contents.

Extra tests found on Reddit.
test1 21148
test2 5078

## Part 2

That List::PriorityQueue is really getting in my way. To save the path,
I need to pass along a referce to an array to update, but if I include it
in the key, it has to be part of the string.

test1 149
test2 413
