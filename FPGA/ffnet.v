/*
Copyright 2021 Chris Kiefer.
Supported by the AHRC MIMIC project https://mimicproject.com
Licensed under the MIT license.
See license.md file in the project root for full license information.
*/


module ffnet
    #(parameter N_INPUTS=4,
     parameter N_LAYERS=3,
     parameter N_OUTPUTS=1)
    (
        input clock,
        input trigger,
        input [N_INPUTS-1:0] inputBus,
        output [N_OUTPUTS-1:0] outputBus,
        output resultReady
    );




/* Counter register */
reg [31:0] counter = 32'b0;

//layer processing
reg [N_LAYERS-1:0] layerTriggers = N_LAYERS'd0; // shift register

reg layerClock;

parameter CLOCK_DIVIDE = 32'd1;
reg[31:0] clk_divide_counter;
parameter S_IDLE = 0;
parameter S_RUNNING = 1;
reg[2:0] state;

initial begin
  resultReady <= 0;
  clk_divide_counter<=1;
  state <= S_IDLE;
end



always @ (posedge clock) begin
  clk_divide_counter <= clk_divide_counter -1;
  
  if (!clk_divide_counter) begin
    clk_divide_counter <= CLOCK_DIVIDE;

    //shift the bit shifter
    layerTriggers <= layerTriggers << 1;   
    
    // layerClock = ! layerClock;
  end

  case(state)
    S_IDLE:begin
      if (trigger) begin
        //state calculation by inserting a 1 into the bit shifter chain
        state <= S_RUNNING;
        layerTriggers<=N_LAYERS'd1;
      end
      resultReady <= 1'b0;
    end
    S_RUNNING:begin
      if (!layerTriggers) begin
        resultReady <= 1'b1;
        state <= S_IDLE;
      end
    end
  endcase
end


//import auto generated code here
//make sure that the parameters in the module declaration are configured correctly to match this code (numbers of inputs, outputs, layers)

`include "lutnet_gen_code.v"

//end generated code

endmodule

