# Advent of Code 2024 Day 24
[Crossed Wires](https://adventofcode.com/2024/day/24)

## Part 1

Convert circuit description into a recursive-descent parser binary tree.

## Part 2

Description says output is supposed to be X+Y, but it's wrong. Let's see
which bits are different.

        x=20901217964857 =  10011 00000010 01110001 10101100 00010011 00111001
        y=21476937000453 =  10011 10001000 01111101 00110011 01100110 00000101
    x+y = 42378154965310 = 100110 10001010 11101110 11011111 01111001 00111110
 input -> 43559017878162 = 100111 10011101 11011111 11001001 10010010 10010010
           input ^ (x+y) = 000001 00010111 00110001 00010110 11101011 10101100
                                ^    ^ ^^^   ^^   ^      ^^  ^^^ ^ ^^ ^ ^ ^^
