# Adventure of Code 2024 Day 09
[Disk Fragmenter](https://adventofcode.com/2024/day/9)

## Part 1
Implement exactly the description: big array, swap from
right to left. Move from opposite ends, swapping indexes.

## Part 2
Completely different.
Keep free lists of each size, ordered by start position.
[1] -> [18 21 26 31 35]
[2] -> []
[3] -> [2 8 12]

Built a memory allocator object, Free.pm with an allocate method.

Given a file that has to move left, find a big enough size that has some
free blocks, and choose the one that's furthest left.
NB: it must be left of where the file is.

Keep list of files, with id,size,and start. Change start when moving.
{ id=>0, start=>0, size=>2}
{ id=>1, start=>4, size=3} 

That part of always choosing the left-most tripped me up twice.
Final insight was a Reddit comment to be sure to get the right'
answer for "12345".  It should be 132 (nothing moves).

Checksum can be done by iterating over the file list (or map the
file onto a huge DISK array and reuse the calculation from part 1).
