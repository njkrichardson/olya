/*
 * =====================================================================================
 *
 *       Filename:  alu.sv
 *
 *    Description:  This module implements an arithmetic-logic unit (ALU)
 *    which exposes four status flags (negative, zero, carry, overflow). The
 *    ALU's operation is modulated by a 2-bit ALU control signal, which
 *    selects one of three unique operations (sum, bitwise and, bitwise or)
 *    and updates the status flags accordingly. 
 *
 *        Version:  1.0
 *        Created:  01/31/2022 21:07:10
 *       Revision:  none
 *       Compiler:  iverilog
 *
 *         Author:  NJKR
 *   Reference(s):  Harris D., Harris S., Digital Design and Computer
 *   Architecture Edition 4, Morgan Kaufmann Publications
 *
 * =====================================================================================
 */
module alu(input logic [31:0] a, b,
           input logic [1:0] alu_control, 
           output logic [31:0] result, 
           output logic [3:0] alu_flags
           ); 
        // --- flags 
        logic negative, zero, carry, overflow; 

        // --- internal node for ~b; 33-bit sum (MSB for overflow) 
        logic [31:0] conditional_inv_b;
        logic [32:0] sum; 

        // --- b is inverted if the first bit of alu_control is high 
        assign conditional_inv_b = alu_control[0] ? ~b : b; 
        assign sum = a + conditional_inv_b + alu_control[0]; 

        // --- a 32-bit 4:1 multiplexer 
        always_comb 
            casex (alu_control[1:0])
                2'b0?: result = sum; 
                2'b10: result = a & b; 
                2'b11: result = a | b; 
            endcase

        // --- flag logic 
        assign negative = result[31]; 
        assign zero = (result == 32'b0); 
        assign carry = (alu_control[1] == 1'b0) & sum[32]; 
        assign overflow = (alu_control[1] == 1'b0) & ~(a[31] ^ b[31] ^ alu_control[0]) & (a[31] ^ sum[31]); 
        
        // --- collect the alu flags onto a multi-bit bus 
        assign alu_flags = {negative, zero, carry, overflow}; 
endmodule
