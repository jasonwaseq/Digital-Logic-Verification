`timescale 1ns/1ps

`define START_TESTBENCH error_o = 0; pass_o = 0; #10;
`define FINISH_WITH_FAIL error_o = 1; pass_o = 0; #10; $finish();
`define FINISH_WITH_PASS pass_o = 1; error_o = 0; #10; $finish();
module testbench
  // You don't usually have ports in a testbench, but we need these to
  // signal to cocotb/gradescope that the testbench has passed, or failed.
  (output logic error_o = 1'bx
  ,output logic pass_o = 1'bx);

   localparam width_lp = 16;
   logic [width_lp-1:0] a_i;
   logic [width_lp-1:0] b_i;
   logic [(2*width_lp)-1:0] product_o;

   // You can use this 
   logic [0:0] error;
   
   logic [(2*width_lp)-1:0] product_golden;
   logic errors;

   multiplier
     #()
   dut
     (.a_i(a_i)
     ,.b_i(b_i)
     ,.c_o(product_o)
     );

   always_comb begin
      product_golden = a_i * b_i;
   end

   initial begin
      `START_TESTBENCH
      errors = 0;
      for (int a = 0; a < 65536; a = a+1000) begin
         for (int b = 0; b < 65536; b = b+1000) begin
            a_i = a;
            b_i = b;
            #5;
            $display("a_i=%0d, b_i=%0d -> DUT=%0d, GOLDEN=%0d", 
                      a_i, b_i, product_o, product_golden);
            if (product_o !== product_golden) begin
               $display(" MISMATCH: expected %0d, got %0d",
                         product_golden, product_o);
               errors = 1;
            end
         end
      end
      if (errors) begin
         `FINISH_WITH_FAIL;
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
