# Advent of Code 2024 Day 17
[https://adventofcode.com/2024/day/17](https://adventofcode.com/2024/day/17)

## Part 1
Straight-forward simulation of the machine. Make an object that holds the registers
and memory; method for each opcode; and execute the instructions, moving the program
counter.

## Part 2

Analysis of the input: There's only one output statement, and one loop.
2,4,1,7,7,5,0,3,4,0,1,7,5,5,3,0

0   2,4  bst 4  bst A    B = A & 7   # B is last 3 bits of A
2   1,7  bxl 7  bxl 7    B = B ^ 7   # Last three bits of B inverted
4   7,5  cdv 5  cdv B    C = A >> B  # Only way to get something into C
6   0,3  adv 3  adv 3    A = A >> 3  # Only place where A decrements, shift 3 bits
8   4,0  bxc 0  bxc B^C  B = B ^ C
10  1,7  bxl 7  bxl 7    B = B ^ 7   # Last three bits of b inverted
12  5,5  out 5  out B    out (B & 7) # Output always comes from register B
14  3,0  jnz 0  jnz 0    jnz 0       # Repeat until A is zero

We're taking A three bits at a time (lines 0 and 6). C can be 0 to 7 bits
of A, but still on the LSB end of the number.

If we work backward, the last three bits determine the last output,
Find that one by searching starting from A=1.
Shift left 3 to preserve that number, then try to find the 3,0 sequence.
Continue shifting to get one octal digit at a time.
