`timescale 1ns/1ps

`define START_TESTBENCH error_o = 0; pass_o = 0; #10;
`define FINISH_WITH_FAIL error_o = 1; pass_o = 0; #10; $finish();
`define FINISH_WITH_PASS pass_o = 1; error_o = 0; #10; $finish();
module testbench
  // You don't usually have ports in a testbench, but we need these to
  // signal to cocotb/gradescope that the testbench has passed, or failed.
  (output logic error_o = 1'bx
  ,output logic pass_o = 1'bx);

   localparam width_lp = 1;
   logic [width_lp-1:0] a_i;
   logic [width_lp-1:0] b_i;
   logic [width_lp-1:0] sum_o;
   logic [width_lp-1:0] carry_o;
   logic [width_lp-1:0] carry_i;


   // You can use this 
   logic [0:0] error;
   
   full_add
     #()
   dut
     (
      .a_i(a_i), 
      .b_i(b_i), 
      .carry_i(carry_i), 
      .carry_o(carry_o), 
      .sum_o(sum_o)
     );

   wire sum_correct;
   assign sum_correct = a_i ^ b_i ^ carry_i;
   wire carry_correct;
   assign carry_correct =  (a_i & carry_i) | (b_i & carry_i) | (a_i & b_i);
   logic [10:0] i;
   logic [10:0] errors;
   initial begin
      `START_TESTBENCH
      errors = '0;
      for (i = 0; i < 8; i++) begin
        a_i = i[0];
        b_i = i[1];
        carry_i = i[2];
        #10;
        $display("TEST:%2d a_i=%b, b_i=%b, carry_i=%b | sum_o: %b | carry_o: %b | Expected sum_o: %b | Expected carry_o: %b | %s", 
               i, a_i, b_i, carry_i, sum_o, carry_o, sum_correct, carry_correct, 
               ((sum_o === sum_correct) && (carry_o === carry_correct)) ? "PASS" : "FAIL");
        if ((sum_correct !== sum_o) || (carry_correct !== carry_o)) begin
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
