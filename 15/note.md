# Advent of Code 2024 Day 15

[WareHouse Woes](https://adventofcode.com/2024/day/15)

## Part 1

Implement simulation of moves. Look for open or wall at the end of a row
of blocks. Fiddly, not too difficult.

## Part 2

1433084 is too low

Horizontal moves are similar; look for space or wall at end of boxes.

For vertical moves, Recursively look for wall blocking any chain of boxes.
Build a stack of what has to move. If not blocked, unstack the boxes, shifting
each one forward one space.

The last case that solved the problem was to handle the diamond shape,
which would cause the top/bottom of the diamond to get stacked for movement
twice. 

      1 2 3 4 5
  1       . .
  2       [ ]
  3     [ ] [ ]
  4   [ ]     [ ]
  5     [ ] [ ]
  2       [ ]
  1       @
