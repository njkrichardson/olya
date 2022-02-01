/*
 * =====================================================================================
 *
 *       Filename:  controller.sv
 *
 *    Description:  Implementation of the arm core controller, which is
 *    comprised of a decoder and conditional logic to generate control signals
 *    which modulate the datapath's operation. 
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

module controller(input   logic         clock, 
                  input   logic         reset, 
                  input   logic [31:12] instruction, 
                  input   logic [3:0]   alu_flags, 
                  output  logic [1:0]   register_source, 
                  output  logic         register_write,
                  output  logic [1:0]   immediate_source, 
                  output  logic         alu_source,
                  output  logic [1:0]   alu_control, 
                  output  logic         memory_write,
                  output  logic         memory_to_register,
                  output  logic         program_counter_source
                  ); 

        logic [1:0] flag_write; 
        logic       program_counter_s; 
        logic       register_write_enable; 
        logic       memory_write_enable; 

        decoder dec(instruction[27:26], 
                    instruction[25:20],
                    instruction[15:12], 
                    flag_write, 
                    program_counter_s, 
                    register_write_enable, 
                    memory_write_enable, 
                    memory_to_register, 
                    alu_source, 
                    immediate_source, 
                    register_source, 
                    alu_control
                    ); 

        conditional_logic cl(clock,
                             reset, 
                             instruction[31:28], 
                             alu_flags, 
                             flag_write, 
                             program_counter_s, 
                             register_write_enable, 
                             memory_write_enable, 
                             program_counter_source, 
                             register_write, 
                             memory_write
                             ); 
endmodule
