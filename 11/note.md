# Advent of Code 2024 Day 11 Part 11
[Plutonian Pebbles](https://adventofcode.com/2024/day/11)

# Part 1
Do what the instructions say.
Only tricky part is that the size of the array changes while
looping over it.

# Part 2

There was already a noticeable pause at 25, and the array grew to six figures.
75 is going to be computationally ridiculous.  Is there a recurrence relation
that would tell us what any particular number evolves to?

We notice that the pebbles are independent, so we can consider one at a time.

    0: 1 1 2 4 4 7 14 16 20 39 62  81 110 200 328 418 667 1059 1546 2377 3572: 
    1:   1 2 4 4 7 14 16 20 39 62  81 110 200 328 418 667 1059 1546 2377 3572
    2:   1 2 4 4 6 12 16 19 30 57  92 111 181 295 414 661  977 1501 2270 3381
    3:   1 2 4 4 5 10 16 26 35 52  79 114 202 294 401 642  987 1556 2281 3347
    4:   1 2 4 4 4  8 16 27 30 47  82 115 195 269 390 637  951 1541 2182 3204
    5:   1 2 4 8 8 11 22 32 45 67 109 163 223 383 597 808 1260 1976 3053 4529
    6:   1 2 4 8 8 11 22 32 54 68 103 183 250 401 600 871 1431 2033 3193
    7:   1 2 4 8 8 11 22 32 52 72 106 168 242 413 602 832 1369 2065 3165
    8:   1 1 2 4 7  7 11 22 31 48  69 103 161 239 393 578  812 1322 2011 3034

Each number in the input will grow to its own tree, so they can be done
independently. If we start with the smallest and memoize?

Recursion with a cache is plenty fast.
