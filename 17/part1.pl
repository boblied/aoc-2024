#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# Copyright (c) 2024, Bob Lied
#=============================================================================
# Advent of Code 2024 Day 17 Part 1 "Chronospatial Computer" 
#=============================================================================

use v5.40;
use FindBin qw($Bin); use lib "$FindBin::Bin/../../lib"; use AOC;
AOC::setup;

$logger->info("START");

my @register;
my @mem;
while (<>)
{
    chomp;
    if    ( m/^Register A: (\d+)/ ) { $register[0] = $1; }
    elsif ( m/^Register B: (\d+)/ ) { $register[1] = $1; }
    elsif ( m/^Register C: (\d+)/ ) { $register[2] = $1; }
    elsif ( m/^Program: (.+)$/    ) { @mem = split(",", $1); }
}

my $Computer = Computer->new(A=>$register[0], B=>$register[1],
                             C=>$register[2], memory=>\@mem, logger=>$logger);

$logger->debug($Computer->show);

my $output = $Computer->run();

say "OUTPUT: $output";

$logger->info("FINISH");

use feature "class"; no warnings "experimental::class";

class Computer;

field $A :param //= 0;
field $B :param //= 0;
field $C :param //= 0;
field $logger :param;
field $memory :param = [0,0];

field $PC = 0;

field @output;

method show()
{
state @opName = qw(adv bxl bst jnz bxc out bdv cdv);
    my $op = $memory->[$PC];
    my $operand = $memory->[$PC+1];
    "A=$A B=$B C=$C PC=$PC instr=($op)", $opName[$op], ",$operand  [@$memory]"
}

method run()
{
    while ( $PC < $memory->$#* )
    {
        $logger->trace("PC=$PC");
        my ($opcode, $operand) = ( $memory->[$PC], $memory->[$PC+1] );
        $logger->debug("RUN:", $self->show());
        $self->execute($opcode, $operand)
    }
    return join(",", @output);
}

method combo($op)
{
    if    ( $op == 0 ) { return 0; }
    elsif ( $op == 1 ) { return 1; }
    elsif ( $op == 2 ) { return 2; }
    elsif ( $op == 3 ) { return 3; }
    elsif ( $op == 4 ) { return $A; }
    elsif ( $op == 5 ) { return $B; }
    elsif ( $op == 6 ) { return $C; }
    else  { die "ILLEGAL OPERAND $op".$self->show();  }
}

method adv($arg) { $A = int($A / (2**$self->combo($arg)))    ; $PC += 2 ; }
method bxl($arg) { $B ^= $arg                                ; $PC += 2 ; }
method bst($arg) { $B = ($self->combo($arg) & 0x7)           ; $PC += 2 ; }
method jnz($arg) { if ( $A != 0 ) { $PC = $arg } else        { $PC += 2 } }
method bxc($arg) { $B = ($B ^ $C)                            ; $PC += 2 ; }
method out($arg) { push @output, ($self->combo($arg) & 0x7)  ; $PC += 2 ; }
method bdv($arg) { $B = int($A / (2**$self->combo($arg)))    ; $PC += 2 ; }
method cdv($arg) { $C = int($A / (2**$self->combo($arg)))    ; $PC += 2 ; }

method execute($opcode, $operand)
{
    if    ( $opcode == 0 ) { $self->adv($operand) }
    elsif ( $opcode == 1 ) { $self->bxl($operand) }
    elsif ( $opcode == 2 ) { $self->bst($operand) }
    elsif ( $opcode == 3 ) { $self->jnz($operand) }
    elsif ( $opcode == 4 ) { $self->bxc($operand) }
    elsif ( $opcode == 5 ) { $self->out($operand) }
    elsif ( $opcode == 6 ) { $self->bdv($operand) }
    elsif ( $opcode == 7 ) { $self->cdv($operand) }
    else  { die "ILLEGAL INSTRUCTION $opcode,$operand".$self->show(); }
}
