#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# Copyright (c) 2024, Bob Lied
#=============================================================================
# Advent of Code 2024 Day 17 Part 2 "Chronospatial Computer" 
#=============================================================================

use v5.40;
use FindBin qw($Bin); use lib "$FindBin::Bin/../../lib"; use AOC;

my ($rA,$rB,$rC,$PROG);
AOC::setup({ "a:i" => \$rA, "b:i" => \$rB, "c:i" => \$rC, "p:s" => \$PROG });

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

$register[0] = $rA if defined $rA;
$register[0] = $rB if defined $rB;
$register[0] = $rC if defined $rC;

#  0  2,4  bst 4  bst A    B = A & 7   # B is last 3 bits of A
#  2  1,7  bxl 7  bxl 7    B = B ^ 7   # Last three bits of B inverted
#  4  7,5  cdv 5  cdv B    C = A >> B  # Only way to get something into C
#  6  0,3  adv 3  adv 3    A = A >> 3  # Only place where A decrements, shift 3 bits
#  8  4,0  bxc 0  bxc B^C  B = B ^ C
# 10  1,7  bxl 7  bxl 7    B = B ^ 7   # Last three bits of b inverted
# 12  5,5  out 5  out B    out (B & 7) # Output always comes from register B
# 14  3,0  jnz 0  jnz 0    jnz 0       # Repeat until A is zero

# We're operating on octal digits, 3 bits at a time. Work backwards, starting
# from the end of the sequence. Each time we get a digit, shift left 3, and
# look for the next one. That is, 
# for 1 to 7, find the 0 at the end, found at 7,
# a = 7 = 111b. a << 3 = 111000b = 56 (\070)
# a = loop until we hit 3,0, a << 3
#    found at 24, \030, 11000b. a << 3 = 11000000b, \0300
# a = loop until we hit 5,3,0, a << 3
# a = loop until we hit 5,5,3,0, a << 3
# etc. for the whole sequence. Answer is a 15-digit number.

my $aReg = 1;
my $Computer = Computer->new(A=>$aReg, B=>$register[1],
                             C=>$register[2], memory=>\@mem, logger=>$logger);

my @x = @mem;
for my $n ( 0 .. $#x )
{
    my $target = join(",", @x[ $#x-$n .. $#x ]);
    say $target;

    my $output = $Computer->reset($aReg)->run();
    while ( substr($output, 0, length($target)) ne $target )
    {
        $aReg++;
        $output = $Computer->reset($aReg)->run();
    }
    say "$target found at $aReg";
    $aReg <<= 3;
}

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
    if ( $PC > $memory->$#* )
    {
        "HALT: A=$A\tB=$B\tC=$C\tPC=$PC\tout=@output";
    }
    else
    {
        my $op = $memory->[$PC];
        my $operand = $memory->[$PC+1];
        " RUN: A=$A\tB=$B C=$C PC=$PC\tinstr=($op)", $opName[$op], ",$operand", "\t@output"
    }
}

method reset($a, $b = 0, $c = 0)
{
    $A = $a; $B = $b; $C = $c;
    $PC = 0;
    @output = ();
    return $self;
}

method run()
{
    while ( $PC < $memory->$#* )
    {
        $logger->trace("PC=$PC");
        my ($opcode, $operand) = ( $memory->[$PC], $memory->[$PC+1] );
        $self->execute($opcode, $operand);
        $logger->debug($self->show());
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
