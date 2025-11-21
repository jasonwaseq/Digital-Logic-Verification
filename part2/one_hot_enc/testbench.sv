`timescale 1ns/1ps

`define START_TESTBENCH error_o = 0; pass_o = 0; #10;
`define FINISH_WITH_FAIL error_o = 1; pass_o = 0; #10; $finish();
`define FINISH_WITH_PASS pass_o = 1; error_o = 0; #10; $finish();
module testbench
  #(parameter width_p = 8)
  // You don't usually have ports in a testbench, but we need these to
  // signal to cocotb/gradescope that the testbench has passed, or failed.
  (output logic error_o = 1'bx
  ,output logic pass_o = 1'bx);

   // You can use this 
   logic [0:0] error;
   // The one-hot mux we are testing is from here: https://github.com/bespoke-silicon-group/basejump_stl/blob/master/bsg_misc/bsg_encode_one_hot.sv
   // (Don't worry, the one in the repository works :p, but please don't use it as the reference design)
   // I obfuscated with the parameters : #(parameter width_p=8, parameter lo_to_hi_p=1, parameter debug_p=0)
  logic [width_p-1:0] i;
  logic [$clog2(width_p)-1:0] addr_o;
  logic v_o;

  integer errors;

  one_hot_enc #() dut (
    .i(i),
    .addr_o(addr_o),
    .v_o(v_o)
  );

  initial begin
    `START_TESTBENCH
    errors = 0;
    for (int j = 0; j < width_p; j++) begin
      i = 1 << j;
      #10
      $display("Test:%2d i=%b | addr_o: %b | v_o: %b | %s", 
               j, i, addr_o, v_o,
               ((j === addr_o) && (v_o === 1'b1)) ? "PASS" : "FAIL");
      if ((j !== addr_o) || (v_o !== 1'b1)) begin
        errors++;
      end
    end

    // Test all-zeros input
    i = '0;
    #10
    $display("Test: all zeros i=%b | addr_o: %b | v_o: %b | %s",
             i, addr_o, v_o,
             (v_o === 1'b0) ? "PASS" : "FAIL");
    if (v_o !== 1'b0) begin
      errors++;
    end

    if (errors > 0) begin
      `FINISH_WITH_FAIL
    end
    `FINISH_WITH_PASS;
  end

   // This block executes after $finish() has been called.
   final begin
      $display("Simulation time is %t", $time);
      if(error_o === 1) begin
	 $display("\033[0;31m    ______                    \033[0m");
	 $display("\033[0;31m   / ____/_____________  _____\033[0m");
	 $display("\033[0;31m  / __/ / ___/ ___/ __ \\/ ___/\033[0m");
	 $display("\033[0;31m / /___/ /  / /  / /_/ / /    \033[0m");
	 $display("\033[0;31m/_____/_/  /_/   \\____/_/     \033[0m");
	 $display("Simulation Failed");
     end else if (pass_o === 1) begin
	 $display("\033[0;32m    ____  ___   __________\033[0m");
	 $display("\033[0;32m   / __ \\/   | / ___/ ___/\033[0m");
	 $display("\033[0;32m  / /_/ / /| | \\__ \\\__ \ \033[0m");
	 $display("\033[0;32m / ____/ ___ |___/ /__/ / \033[0m");
	 $display("\033[0;32m/_/   /_/  |_/____/____/  \033[0m");
	 $display();
	 $display("Simulation Succeeded!");
     end else begin
        $display("   __  ___   ____ __ _   ______ _       ___   __");
        $display("  / / / / | / / //_// | / / __ \\ |     / / | / /");
        $display(" / / / /  |/ / ,<  /  |/ / / / / | /| / /  |/ / ");
        $display("/ /_/ / /|  / /| |/ /|  / /_/ /| |/ |/ / /|  /  ");
        $display("\\____/_/ |_/_/ |_/_/ |_/\\____/ |__/|__/_/ |_/   ");
	$display("Please set error_o or pass_o!");
     end
   end

endmodule
