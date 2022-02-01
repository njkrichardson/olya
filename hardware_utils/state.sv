/*
 * =====================================================================================
 *
 *       Filename:  state.sv
 *
 *    Description:  This module implements hardware elements with state, that
 *    is, strictly more than one stable state such that the element can act as
 *    a "memory" which conditionally retains its state and thus enables the
 *    implementation of sequential logic elements like latches, flip flops,
 *    registers, memories (RAMs and ROMs), and finite state machines. 
 *
 *        Version:  1.0
 *        Created:  02/01/2022 16:42:32
 *       Revision:  none
 *       Compiler:  iverilog 
 *
 *         Author:  NJKR
 *   Reference(s):  Harris D., Harris S., Digital Design and Computer
 *   Architecture Edition 4, Morgan Kaufmann Publications
 *
 * =====================================================================================
 */
module register_file(input logic clock,
               input logic write_enable,
                input logic [3:0] port_one_address, port_two_address, write_address,
                input logic [31:0] write_data, register_15,
                output logic [31:0] port_one_read, port_two_read);

    logic [31:0] rf[14:0];

    // three ported register file (two read, one rising edge write)
    // register 15 is hard-coded to (program_counter + 8)
    always_ff @(posedge clock)
    if (write_enable) rf[write_address] <= write_data;
        assign port_one_read = (port_one_address == 4'b1111) ? register_15 : rf[port_one_address];
        assign port_two_read = (port_two_address == 4'b1111) ? register_15 : rf[port_two_address];
endmodule

module random_access_memory #(parameter address_width = 6, parameter word_width = 32)
    (input logic clock,
     input logic write_enable,
     input logic [address_width-1:0] address, 
     input logic [word_width-1:0] data_in, 
     output logic [word_width-1:0] data_out); 

    logic [word_width-1:0] memory [2**address_width-1:0]; 

    always_ff @(posedge clock)
        if (write_enable) memory[address] <= data_in;
            assign data_out = memory[address];
endmodule

module read_only_memory(
            input logic [1:0] address, 
            output logic [2:0] data_out); 

    always_comb
        case(address)
            2'b00: data_out = 3'b011;
            2'b01: data_out = 3'b110;
            2'b10: data_out = 3'b100;
            2'b11: data_out = 3'b010;
        endcase
endmodule

module data_memory(
            input  logic clock, write_enable,
            input  logic [31:0] address, write_data,
            output logic [31:0] read_data);

  logic [31:0] RAM[63:0];

  // truncate the least signifcant two bits of the address (word alignment)
  assign read_data = RAM[address[31:2]]; 

  always_ff @(posedge clock)
    if (write_enable) RAM[address[31:2]] <= write_data;
endmodule

module instruction_memory(
            input  logic [31:0] address,
            output logic [31:0] read_data);

  logic [31:0] RAM[63:0];

  initial
      $readmemh("../../programs/basic.dat", RAM);

  // truncate the least signifcant two bits of the address (word alignment)
  assign read_data = RAM[address[31:2]]; 
endmodule
