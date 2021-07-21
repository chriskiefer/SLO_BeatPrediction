
/*
Copyright 2021 Chris Kiefer.
Supported by the AHRC MIMIC project https://mimicproject.com
Licensed under the MIT license.
See license.md file in the project root for full license information.
*/
`include "osdvu/uart.v"





module ffnet_top(
    input CLK_i, //12MHz
    input RSTn_i,
    input RS232_RX_i,
    output RS232_TX_o,
    output [7:0] LED_o
);

reg transmit =0 ;
reg [7:0] tx_byte = 0;
wire [7:0] rx_byte;
wire received;
reg transmitting;
reg receiving;
wire resultReady;
reg ffnetTrigger=0;

uart #(.CLOCK_DIVIDE( 312 )) my_uart (
    CLK_i,          //  master clock for this component
    ,               // synchronous reset line (resets if high)
    RS232_RX_i,     // receive data on this line
    RS232_TX_o,     // transmit data on this line
    transmit,       // signal o indicate that the UART should start a transmission
    tx_byte,        // 8-bit bus with byte to be transmitted when transmit is raised high
    received,       // output flag raised high for one cycle of clk when a byte is received
    rx_byte,        // byte which has just been received when received is raise
    receiving,               // indicates that we are currently receiving data on the rx lin
    transmitting, 		// indicates that we are currently sending data on the tx line
    );


//states

parameter S_IDLE=0;
parameter S_NET_RUNNING=1;
parameter S_SENDING_RESULT=2;
reg[2:0] state = S_IDLE;

//net
parameter FFNET_INPUTS=4;
parameter FFNET_OUTPUTS=1;

reg[FFNET_INPUTS-1:0] netInputs;
reg[FFNET_OUTPUTS-1:0] netOutputs;

// assign LED_o[FFNET_INPUTS-1:0] = rx_byte[FFNET_INPUTS-1:0];
assign LED_o[3:0] = rx_byte[3:0];
assign LED_o[7] = receiving; 

always @(posedge CLK_i) begin
    case(state)
        S_IDLE:begin
            if (received) begin
                netInputs <= rx_byte[FFNET_INPUTS-1:0];
                ffnetTrigger <= 1;
                state <= S_NET_RUNNING;
                // LED_o[7] <= 1;
            end
        end
        S_NET_RUNNING:begin
            ffnetTrigger <= 0;
            if (resultReady) begin
                state <= S_SENDING_RESULT;
                tx_byte[FFNET_OUTPUTS-1:0] <= netOutputs;
                // tx_byte[7:0] <= rx_byte[7:0] + 8'b1;
                transmit <= 1'b1;  
            end
        end
        S_SENDING_RESULT:begin
            transmit <= 1'b0;
            state = S_IDLE;
            // LED_o[7] <= 0;
        end
    endcase

end

//n_layers exludes the input layer
ffnet #(.N_INPUTS(FFNET_INPUTS),.N_LAYERS(8),.N_OUTPUTS(FFNET_OUTPUTS)) net (CLK_i, ffnetTrigger, netInputs, netOutputs, resultReady);



endmodule // uart_top
