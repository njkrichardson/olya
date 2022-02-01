/*
 * =====================================================================================
 *
 *       Filename:  conditional_logic.sv
 *
 *    Description:  Implementation of the conditional logic component of the
 *    arm core controller. The conditional logic determines whether an
 *    instruction should be executed based on the `cond` field of the
 *    instruction and the current flag values. If the instruction should not
 *    be exececuted, the control signals are adjusted so that the instruction
 *    cannot alter the architectural state. 
 *
 *        Version:  1.0
 *        Created:  12/06/2021 16:56:54
 *       Revision:  none
 *       Compiler:  iverilog
 *
 *         Author:  NJKR
 *
 * =====================================================================================
 */

module condlogic(input  logic        clock, 
                 input  logic        reset,
                 input  logic [3:0]  condition,
                 input  logic [3:0]  alu_flags,
                 input  logic [1:0]  potential_flag_write,
                 input  logic        potential_program_counter, 
                 input  logic        potential_register_write, 
                 input  logic        potential_memory_write,
                 output logic        program_counter_source, 
                 output logic        register_write,
                 output logic        memory_write
             );

    logic [1:0] flag_write;
    logic [3:0] flags;
    logic conditional_execution;

    // --- flag state 
    flopenr #(2)flagreg1(clk, reset, flag_write[1], alu_flags[3:2], flags[3:2]);
    flopenr #(2)flagreg0(clk, reset, flag_write[0], alu_flags[1:0], flags[1:0]);

    // --- combinational condition check logic 
    condcheck cc(condition, flags, conditional_execution);

    // --- conditional control signals 
    assign flag_write = potential_flag_write & {2{conditional_execution}};
    assign register_write = potential_register_write & conditional_execution;
    assign memory_write = potential_memory_write & conditional_execution;
    assign program_counter_source = potential_program_counter & conditional_execution;

endmodule

module condcheck(input  logic [3:0] condition,
                 input  logic [3:0] flags,
                 output logic conditional_execution
             );


    // --- conditions 
    logic negative, zero, carry, overflow, greater_or_equal;

    assign {negative, zero, carry, overflow} = flags;
    assign greater_or_equal = (negative == overflow);

    always_comb 
        case(condition)
            4'b0000: conditional_execution = zero; // EQ
            4'b0001: conditional_execution = ~zero; // NE
            4'b0010: conditional_execution = carry; // CS
            4'b0011: conditional_execution = ~carry; // CC
            4'b0100: conditional_execution = negative; // MI
            4'b0101: conditional_execution = ~negative; // PL
            4'b0110: conditional_execution = overflow; // VS
            4'b0111: conditional_execution = ~overflow; // VC
            4'b1000: conditional_execution = carry & ~zero; // HI
            4'b1001: conditional_execution = ~(carry & ~zero); // LS
            4'b1010: conditional_execution = greater_or_equal; // GE
            4'b1011: conditional_execution = ~greater_or_equal; // LT
            4'b1100: conditional_execution = ~zero & greater_or_equal; // GT
            4'b1101: conditional_execution = ~(~zero & greater_or_equal); // LE
            4'b1110: conditional_execution = 1'b1; // Always
            default: conditional_execution = 1'bx; // undefined
        endcase
endmodule
