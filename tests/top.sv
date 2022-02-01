/*
 * =====================================================================================
 *
 *       Filename:  top.sv
 *
 *    Description:  The top-level module instantiates the single cycle Armv4 processor 
 *    and associated data/instruction memories (RAMs). 
 *
 *        Version:  1.0
 *        Created:  02/01/2022 16:36:47
 *       Revision:  none
 *       Compiler:  iverilog
 *
 *         Author:  NJKR
 *
 * =====================================================================================
 */

module top(input logic clk, reset,
           output logic [31:0] write_data, data_memory_address,
           output logic data_memory_write_enable);
    // internal nodes of the processor datapath 
    logic [31:0] program_counter, instruction, read_data;

    // instantiate the processor 
    arm arm(clk, reset, program_counter, instruction, data_memory_write_enable, data_memory_address, write_data, read_data);

    // instantiate the instruction and data memory 
    instruction_memory imem(program_counter, instruction);
    data_memory dmem(clk, data_memory_write_enable, data_memory_address, write_data, read_data);
endmodule
