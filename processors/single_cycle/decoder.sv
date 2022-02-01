/*
 * =====================================================================================
 *
 *       Filename:  decoder.sv
 *
 *    Description:  Instruction decoder of the arm core. The decoder generates
 *    control signals for the datapath; including the arithmetic unit and the
 *    program counter. 
 *
 *        Version:  1.0
 *        Created:  12/06/2021 16:56:54
 *       Revision:  none
 *       Compiler:  iverilog 
 *
 *         Author:  NJKR
 *   Reference(s):  Harris D., Harris S., Digital Design and Computer
 *   Architecture Edition 4, Morgan Kaufmann Publications
 *
 * =====================================================================================
 */

module decoder(input    logic   [1:0] operation_code,
               input    logic   [5:0] function_id,
               input    logic   [3:0] destination_register,
               output   logic   [1:0] flag_write,
               output   logic         potential_program_counter,
               output   logic         register_write_enable,
               output   logic         memory_write_enable,
               output   logic         memory_to_register,
               output   logic         alu_source, 
               output   logic   [1:0] immediate_source,
               output   logic   [1:0] register_source,
               output   logic   [1:0] alu_control
               ); 

    logic [9:0] controls; 
    logic       branch; 
    logic       alu_operation; 

    // --- first determine the (incomplete) control signals from the function
    always_comb 
        casex(operation_code) 
            2'b00: if (function_id[5]) controls = 10'b0000101001; 
                   else controls = 10'b0000001001; 
            2'b01: if (function_id[0]) controls = 10'b0001111000; 
                   else controls = 10'b1001110100; 
            2'b10: controls = 10'b0110100010; 
            default: controls = 10'bx; 
        endcase

    assign {register_source, 
            immediate_source,
            alu_source, 
            memory_to_register, 
            register_write_enable, 
            memory_write_enable, 
            branch, 
            alu_operation
            } = controls; 

    // --- arithmetic logical unit control signals
    always_comb 
        if (alu_operation) begin 
            case(function_id[4:1])
                4'b0100: alu_control = 2'b00;   // ADD
                4'b0010: alu_control = 2'b01;   // SUB
                4'b0000: alu_control = 2'b10;   // AND (bitwise)
                4'b1100: alu_control = 2'b11;   // ORR (bitwise)
                default: alu_control = 2'bx;    // Not implemented 
            endcase

            // --- alu flag control 
            flag_write[1] = function_id[0]; 
            flag_write[0] = function_id[0] & (alu_control == 2'b00 | alu_control == 2'b01); 
        end else begin 
            // --- not a data processing instruction 
            alu_control = 2'b00; // ADD for non-DP instructions 
            flag_write = 2'b00;  // flags are not updated 
        end 

    // --- program counter logic 
    assign potential_program_counter = ((destination_register == 4'b1111) & register_write_enable) | branch; 

endmodule

