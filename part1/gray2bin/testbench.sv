`timescale 1ns/1ps

`define START_TESTBENCH error_o = 0; pass_o = 0; #10;
`define FINISH_WITH_FAIL error_o = 1; pass_o = 0; #10; $finish();
`define FINISH_WITH_PASS pass_o = 1; error_o = 0; #10; $finish();
module testbench
  // You don't usually have ports in a testbench, but we need these to
  // signal to cocotb/gradescope that the testbench has passed, or failed.
  (output logic error_o = 1'bx
  ,output logic pass_o = 1'bx);

   localparam width_lp = 5;
   logic [width_lp-1:0] gray_i;
   logic [width_lp-1:0] bin_o;
  
   // You can use this 
   logic [0:0] error;
   
   gray2bin
     #()
   dut
     (.gray_i(gray_i),
      .bin_o(bin_o)
     );

  logic [width_lp-1:0] bin_correct;
  always_comb begin
    bin_correct[width_lp-1] = gray_i[width_lp-1];
    for (int i = width_lp-2; i >= 0; i--) begin
      bin_correct[i] = bin_correct[i+1] ^ gray_i[i];
    end
  end
    
  logic [10:0] errors;
  integer i;
  initial begin
  `START_TESTBENCH
  errors = '0;
  for (i = 0; i < (1 << width_lp); i++) begin
    gray_i = i[width_lp-1:0];
    #10;
    $display("Test:%2d gray_i=%b | DUT bin_o: %b | Expected: %b | %s", 
              i, gray_i, bin_o, bin_correct,
    (bin_o === bin_correct) ? "PASS" : "FAIL");
    if (bin_o !== bin_correct) begin
      errors = errors + 1;
    end
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
