`timescale 1ns/1ps

`define START_TESTBENCH error_o = 0; pass_o = 0; #10;
`define FINISH_WITH_FAIL error_o = 1; pass_o = 0; #10; $finish();
`define FINISH_WITH_PASS pass_o = 1; error_o = 0; #10; $finish();
module testbench
  // We won't change these, but they are the parameters for the module:
  #(parameter width_p = 8
   ,parameter depth_p = 8)
  // You don't usually have ports in a testbench, but we need these to
  // signal to cocotb/gradescope that the testbench has passed, or failed.
  (output logic error_o = 1'bx
  ,output logic pass_o = 1'bx);

   // You can use this 
   logic [0:0] error;

   // The one-hot mux we are testing is from here: https://github.com/bespoke-silicon-group/basejump_stl/blob/master/bsg_misc/bsg_mux_one_hot.sv
   // (Don't worry, the one in the repository works :p, but please don't use it as the reference design)
  logic [(depth_p*width_p)-1:0] data_i;
  logic [depth_p-1:0]           sel_one_hot_i;
  logic [width_p-1:0]           data_o;
  logic [width_p-1:0]           data_golden;

  one_hot_mux dut (
    .data_i(data_i),
    .sel_one_hot_i(sel_one_hot_i),
    .data_o(data_o)
  );

  always_comb begin
    data_golden = '0;
    case (sel_one_hot_i)
      8'b0000_0001: data_golden = data_i[7:0];
      8'b0000_0010: data_golden = data_i[15:8];
      8'b0000_0100: data_golden = data_i[23:16];
      8'b0000_1000: data_golden = data_i[31:24];
      8'b0001_0000: data_golden = data_i[39:32];
      8'b0010_0000: data_golden = data_i[47:40];
      8'b0100_0000: data_golden = data_i[55:48];
      8'b1000_0000: data_golden = data_i[63:56];
      default:      data_golden = '0;  
    endcase
  end

  initial begin
    `START_TESTBENCH

    data_i[7:0]   = 8'hA1;
    data_i[15:8]  = 8'hB2;
    data_i[23:16] = 8'hC3;
    data_i[31:24] = 8'hD4;
    data_i[39:32] = 8'hE5;
    data_i[47:40] = 8'hF6;
    data_i[55:48] = 8'h07;
    data_i[63:56] = 8'h18;

    for (int i = 0; i < depth_p; i++) begin
      sel_one_hot_i = '0;
      sel_one_hot_i[i] = 1'b1;
      #1;
      if (data_o !== data_golden) begin
        $display("FAIL: sel=%b expected=%h got=%h", sel_one_hot_i, data_golden, data_o);
        `FINISH_WITH_FAIL
      end else begin
        $display("PASS: sel=%b output=%h", sel_one_hot_i, data_o);
      end
    end

    sel_one_hot_i = '0;
    #1;
    if (data_o !== '0) begin
      $display("FAIL: sel=00000000 expected=00000000 got=%h", data_o);
      `FINISH_WITH_FAIL
    end else begin
      $display("PASS: all-zero select output=%h", data_o);
    end

    sel_one_hot_i = 8'b0011_0000; 
    #1;
    $display("INFO: Undefined input (multi-hot) sel=%b output=%h", sel_one_hot_i, data_o);

    sel_one_hot_i = 8'b1100_0000; 
    #1;
    $display("INFO: Undefined input (multi-hot) sel=%b output=%h", sel_one_hot_i, data_o);

    $display("All valid one-hot tests passed!");
    `FINISH_WITH_PASS
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
