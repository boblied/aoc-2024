
# Advent of Code 2024 Day 12
[Garden Groups(https://adventofcode.com/2024/day/12)

# Part 1

Finding the regions is flood-fill using breadth-first search.
Went off on a wrong direction trying to do it recursively to cover
nested regions. The winning strategy was to build a mask of the
region in a copy of the garden, then clear the garden after the
data was available.

Edge detection can also be done on the mask copy -- it eliminates
all complications from tripping on any other region. Edge detection
is a walk in from each edge, looking for the transitions from empty
space to covered region. The edge case to watch out for is the
insides of concave curves.

# Part 2

All of part 1 applies, but now the edge detection becomes side detection.
Start with creating a bit map of the edge transitions, looking in from
each direction, then count groups of ones. From the left and right count
columns; for the top and bottom count rows.

               - - - 1 1 -  1
           |   - - - - - 1  1       Total sides: 5 + 5 + 6 + 7 = 22
           |   - - 1 - - -  1
           V   1 1 - - - -  1
               - - 1 - - -  1 = 5
               - - - - - -
         ---->              <---
  _ _ _ 1 _ _  # # # C C #  _ 1 _ _ _ _
  _ _ _ 1 _ _  # # # C C C  1 _ _ _ _ _
  _ _ 1 _ _ _  # # C C # #  _ _ 1 _ _ _
  1 _ _ _ _ _  C C C # # #  _ _ _ 1 _ _
  _ 1 _ _ _ _  # C # # # #  _ _ _ _ 1 _
  _ 1 _ _ _ _  # C C # # #  _ _ _ 1 _ _
  _ _ 1 _ _ _  # # C # # #  _ _ _ 1 _ _

  1 1 2 1 = 5               1 1 1 2 1 = 6
               
               - - 1 - - -  1
               - 1 - - - -  1
               - - - - - -  0   ^
               - - 1 - - -  1   |
               1 - - - - -  1   |
               - - - 1 - -  1
               - - - - 1 1  1
               - - - - - -  0 = 6

