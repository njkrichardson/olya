/*
 * =====================================================================================
 *
 *       Filename:  testbench.sv
 *
 *    Description:  This module contains a simple testbench to exercise the
 *    single-cycle Armv4 core implemented in `arm_single_cycle_core.sv`. The
 *    testbench instantiates the core as the device-under-test (DUT), loads
 *    machine code from a hexadecimal file `memory_file.dat`. The processor
 *    reset is asserted for 22 ns, and then goes low. Then the testbench
 *    generates a 200MHz clock (period 5ns); the program counter was reset to
 *    0x00000000 which is the address of the first instruction of the test
 *    program. Thus the processor begins executing the program. The desired
 *    ultimate processor state resultant from executing the program correctly
 *    is the value 7 begin written to the data memory at address 100. The
 *    testbench tests this condition on every negative clock edge, and exits
 *    with a success/failure message to the commandline. 
 *
 *        Version:  1.0
 *        Created:  02/01/2022 16:22:15
 *       Revision:  none
 *       Compiler:  iverilog
 *
 *         Author:  NJKR
 *   Reference(s):  Harris D., Harris S., Digital Design and Computer
 *   Architecture Edition 4, Morgan Kaufmann Publications
 *
 * =====================================================================================
 */
module testbench();

  logic        clock;
  logic        reset;

  logic [31:0] write_data, data_memory_address;
  logic        memory_write_enable;

  // instantiate device to be tested
  top dut(clock, reset, write_data, data_memory_address, memory_write_enable);
  
  // initialize test
  initial
    begin
      reset <= 1; # 22; reset <= 0;
    end

  // generate clock to sequence tests
  always
    begin
      clock <= 1; # 5; clock <= 0; # 5;
    end

  // check results
  always @(negedge clock)
    begin
      if(memory_write_enable) begin
        if(data_memory_address === 100 & write_data === 7) begin
          $display("Simulation succeeded");
          $stop;
        end else if (data_memory_address !== 96) begin
          $display("Simulation failed");
          $stop;
        end
      end
    end
endmodule
