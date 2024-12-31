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
      Part 1    Part 2
test1 21148     149
test2 5078      413

## Part 2

That List::PriorityQueue is really getting in my way. To save the path,
I want to pass along a referce to an array to update, but if I include it
in the key, it has to be part of the string.

Turns out I don't need to record the path, saving the distance table is enough.

Use Dijkstra algorithm to get distance from start to end for every trail.
Now follow the trail backward, but use the distance info to follow alternatives.

  #    #    #    #    #    #    #    #    #    #    #    #    #    #    #    
  #                                       #                       36    #    
  #         #         #    #    #         #         #    #    #   35    #    
  #                             #         #                   #   34    #    
  #         #    #    #         #    #    #    #    #         #   33    #    
  #         #         #                                       #   32    #    
  #         #         #    #    #    #    #         #    #    #   31    #    
  #              8    9   10   11   12   13   14   15   16    #   30    #    
  #    #    #    7    #    9    #    #    #    #    #   17    #   29    #    
  #    4    5    6    #    8                        #   18    #   28    #    
  #   -3-   #   -5-   #    7    #    #    #         #   19    #   27    #    
  #   [2]  -3-  [4]  -5-   6    #                   #   20    #   26    #    
  #    1    #    #    #         #         #         #   21    #   25    #    
  #    0              #                             #   22   23   24    #    
  #    #    #    #    #    #    #    #    #    #    #    #    #    #    #    

Switch to a different heap implementation (Array::Heap::PriorityQueue::Numeric)
that allows array references as values.

Last step, to check coverage while moving from End to Start, is a breadth-first
search, using the distances to decide what is valid in the next fringe.
The distance table has the directions, but obviously in the opposite direction.
