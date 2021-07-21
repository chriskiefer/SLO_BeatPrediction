/*
Copyright 2021 Chris Kiefer.
Supported by the AHRC MIMIC project https://mimicproject.com
Licensed under the MIT license.
See license.md file in the project root for full license information.
*/


module lutNode(
    input lut0,
    input lut1,
    input lut2,
    input lut3,
    input clock,
    output nodeOut
);

wire lutOut;
SB_LUT4 SB_LUT4_inst (.O (lutOut),// output
        .I0 (lut0),// data input 0
        .I1 (lut1),// data input 1
        .I2 (lut2),// data input 2
        .I3 (lut3) // data input 3
        );

parameter TT = 16'b1111111111111111;

defparam SB_LUT4_inst.LUT_INIT=TT;


SB_DFF SB_DFF_inst (
    .Q(nodeOut), // Registered Output
    .C(clock), // Clock
    .D(lutOut), // Data
);

endmodule