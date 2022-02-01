/*
 * =====================================================================================
 *
 *       Filename:  core.sv 
 *
 *    Description:  This module contains the top-level module implementing
 *    a single-cycle Armv4 microprocessor. The microarchitecture is comprised
 *    of the datapath and the controller. The processor takes as input: a clock
 *    signal, an asychronous reset signal, the current 32-bit instruction, and
 *    the current value of the output bus of the datamemory (some 32-bit word).
 *     
 *
 *    The processor exposes as outputs: the 32-bit program counter, the data
 *    memory write enable control signal, the 32-bit arithmetic logic unit
 *    result, and the value of the 32-bit data word to be (conditionally)
 *    written to the data memory (this is the same as the value on the second
 *    read port of the register file). 
 *
 *        Version:  1.0
 *        Created:  02/01/2022 16:09:20
 *       Revision:  none
 *       Compiler:  iverilog
 *
 *         Author:  NJKR
 *   Reference(s):  Harris D., Harris S., Digital Design and Computer
 *   Architecture Edition 4, Morgan Kaufmann Publications
 *
 * =====================================================================================
 */
module arm(input  logic        clock, reset,
           output logic [31:0] program_counter,
           input  logic [31:0] instruction,
           output logic        data_memory_write_enable,
           output logic [31:0] alu_result, write_data,
           input  logic [31:0] read_data);

  logic [3:0] alu_flags;
  logic       register_write_enable, 
              alu_source, memory_to_register, program_counter_source;
  logic [1:0] register_source, immediate_source, alu_control;

  controller controller(clock, reset, instruction[31:12], alu_flags, 
               register_source, register_write_enable, immediate_source, 
               alu_source, alu_control,
               data_memory_write_enable, memory_to_register, program_counter_source);
  datapath datapath(clock, reset, 
              register_source, register_write_enable, immediate_source,
              alu_source, alu_control,
              memory_to_register, program_counter_source,
              alu_flags, program_counter, instruction,
              alu_result, write_data, read_data);
endmodule
