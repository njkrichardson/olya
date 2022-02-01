/*
 * =====================================================================================
 *
 *       Filename:  combinational_logic.sv 
 *
 *    Description:  This module contains a variety of combinational digital
 *    building blocks, including adders, extension hardware, multiplexers,
 *    decoders, shifters, rotators, multipliers, and logic gates. 
 *
 *        Version:  1.0
 *        Created:  12/26/2021 13:03:24
 *       Revision:  none
 *       Compiler:  iverilog 
 *
 *         Author:  NJKR 
 *
 * =====================================================================================
 */

module adder #(parameter WIDTH = 8)
    (input  logic [WIDTH-1:0] a, 
     input  logic [WIDTH-1:0] b,
     output logic [WIDTH-1:0] y
    );

    assign y = a + b;

endmodule

module extender(input  logic [23:0] instruction,
              input  logic [1:0]  immediate_source,
              output logic [31:0] extended_immediate
             );

    always_comb
        case(immediate_source) 
            2'b00: extended_immediate = {24'b0, instruction[7:0]};  // 8-bit unsigned immediate
            2'b01: extended_immediate = {20'b0, instruction[11:0]}; // 12-bit unsigned immediate
            2'b10: extended_immediate = {{6{instruction[23]}}, instruction[23:0], 2'b00}; // 24-bit two's complement shifted (branch) 
            default: extended_immediate = 32'bx; // undefined behavior 
        endcase

endmodule

module resettable_flop #(parameter WIDTH = 8)
    (input  logic             clock, 
     input  logic             reset,
     input  logic [WIDTH-1:0] d,
     output logic [WIDTH-1:0] q
    );

    always_ff @(posedge clock, posedge reset)
    if (reset) q <= 0;
        else q <= d;

endmodule

module enabled_resettable_flop #(parameter WIDTH = 8)
    (input  logic clock, 
     input  logic reset, 
     input  logic enable,
     input logic [WIDTH-1:0] d,
     output logic [WIDTH-1:0] q
    );

    always_ff @(posedge clock, posedge reset)
        if (reset) q <= 0;
        else if (enable) q <= d;
endmodule

module mux_two_to_one #(parameter WIDTH = 8)
    (input  logic [WIDTH-1:0] d0, 
     input  logic [WIDTH-1:0] d1,
     input  logic             s,
     output logic [WIDTH-1:0] y);

    assign y = s ? d1 : d0;

endmodule

module full_adder(input logic a, b, carry_in, 
                  output logic sum, carry_out); 

        // internal nodes 
        logic propagate, generate_; 

        // propagate and generate logic 
        assign propagate = a ^ b; 
        assign generate_ = a & b; 

        // compute the sum and carry_out with the propagate and generate
        assign sum = propagate ^ carry_in; 
        assign carry_out = generate_ | propagate & carry_in; 

endmodule 
