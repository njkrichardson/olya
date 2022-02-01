/*
 * =====================================================================================
 *
 *       Filename:  datapath.sv 
 *
 *    Description:  This module implements the 32-bit datapath of the processor,
 *    which operates on words of data, containing structures like memories,
 *    registers, artihmetic logic units, and multiplexers. 
 *
 *    Roughly speaking,
 *    one can think of a microarchitecture as comprised by the datapath and
 *    the control unit. The datapath implemented in this module constitutes
 *    most of the controlled combinational logic which computes the next state
 *    of the processor given the current state. The control unit inspects the
 *    current instruction instruction in the datapath and produces control
 *    signals which tell the datapath elements how to execute the instruction. 
 *
 *        Version:  1.0
 *        Created:  12/26/2021 13:01:15
 *       Revision:  none
 *       Compiler:  iverilog 
 *
 *         Author:  NJKR
 *   Reference(s):  Harris D., Harris S., Digital Design and Computer
 *   Architecture Edition 4, Morgan Kaufmann Publications
 *
 * =====================================================================================
 */

module datapath(input  logic clock, reset,
                input  logic [1:0] register_source,
                input  logic register_write,
                input  logic [1:0] immediate_source,
                input  logic alu_source,
                input  logic [1:0] alu_control,
                input  logic memory_to_register_file,
                input  logic program_counter_source,
                output logic [3:0] alu_flags,
                output logic [31:0] program_counter,
                input  logic [31:0] instruction,
                output logic [31:0] alu_result, register_file_out2,
                input  logic [31:0] read_data
            );

    // --- internal datapath nodes 
    logic [31:0] next_program_counter, program_counter_plus_four, program_counter_plus_eight;
    logic [31:0] extended_immediate, register_file_out1, source_b, result;
    logic [3:0] register_address1, register_address2;

    // --- immediate extension 
    extender ext(instruction[23:0], immediate_source, extended_immediate);

    // next program_counter logic
    mux_two_to_one #(32) pcmux(program_counter_plus_four, result, program_counter_source, next_program_counter);
    resettable_flop #(32) pcreg(clock, reset, next_program_counter, program_counter);
    adder #(32) pcadd1(program_counter, 32'b100, program_counter_plus_four);
    adder #(32) pcadd2(program_counter_plus_four, 32'b100, program_counter_plus_eight);

    // --- register file address muxes 
    mux_two_to_one #(4) ra1mux(instruction[19:16], 4'b1111, register_source[0], register_address1);
    mux_two_to_one #(4) ra2mux(instruction[3:0], instruction[15:12], register_source[1], register_address2);

    // --- register file 
    register_file rf(clock, register_write, register_address1, register_address2, instruction[15:12], result, program_counter_plus_eight, register_file_out1, register_file_out2);

    // --- alu result mux 
    mux_two_to_one #(32) resmux(alu_result, read_data, memory_to_register_file, result);

    // --- alu source b mux; alu 
    mux_two_to_one #(32) srcbmux(register_file_out2, extended_immediate, alu_source, source_b);
    alu alu(register_file_out1, source_b, alu_control, alu_result, alu_flags);

endmodule
