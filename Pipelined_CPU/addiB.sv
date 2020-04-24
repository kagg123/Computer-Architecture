// Test of ADDI instruction, with a final B(ranch) instruction to stay in one place.
// Requires:
// ADDI & B instructions
// Expected results:
// X0 = 0
// X1 = 1
// X2 = 2
// X3 = 3
// X4 = 4

//ADDI: I-type, Reg[Rd] = Reg[Rn] + {'0, Imm12}
//OP         Imm12        Rn    Rd
//3322222222 221111111111 00000 00000
//1098765432 109876543210 98765 43210
//1001000100 Unsigned     0..31 0..31

//B: B-type, PC = PC + SignExtend({Imm26, 2'b00})
//OP     Imm26
//332222 22222211111111110000000000
//109876 54321098765432109876543210
//000101 2's Comp Imm26

//Note: X31 is always 0.
               // MAIN:
1001000100_000000000000_11111_00000    // ADDI X0, X31, #0     // X0 = 0
1001000100_000000000001_00000_00001    // ADDI X1, X0, #1      // X1 = 1
1001000100_000000000001_00001_00010    // ADDI X2, X1, #1      // X2 = 2
1001000100_000000000010_00001_00011    // ADDI X3, X1, #2      // X3 = 3
1001000100_000000000100_00000_00100    // ADDI X4, X0, #4      // X4 = 4
000101_00000000000000000000000000      // HALT:B HALT          // HALT = 0
1001000100_000000000000_11111_11111    // ADDI X31, X31, #0    // Bogus instruction - pipelined CPU may need it.