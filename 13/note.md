# Advent of Code 2024 Day 13
[Claw Contraption](https://adventofcode.com/2024/day/13)

## Part 1

This is not a search problem. All the machines only move in positive directions,
so we have two variables (a presses of the A button, b presses of the B button)
and two equations (aAx + bBx = Px, bAy + bBy = Py). Solve with Cramer's rule.

## Part 2

Still not a search problem. Move Prize as directed. The 100-press rule no longer applies.
