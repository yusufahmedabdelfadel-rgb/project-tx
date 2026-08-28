module parity_calc (
    input [7:0] data_in,
    input P_BIT,       // 0: Even, 1: Odd
    output parity_bit
);
    wire xor_all = ^data_in;
    assign parity_bit = (P_BIT == 0) ? xor_all : ~xor_all;
endmodule

