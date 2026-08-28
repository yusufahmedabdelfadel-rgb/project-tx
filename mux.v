module mux (
    input [2:0] state,
    input serial_out,
    input parity_bit,
    output TX_OUT
);
    reg TX_OUT_reg;

    always @(*) begin
        case (state)
            3'd0: TX_OUT_reg = 1'b1;   
            3'd1: TX_OUT_reg = 1'b0;   
            3'd2: TX_OUT_reg = serial_out;  
            3'd3: TX_OUT_reg = parity_bit;  
            3'd4: TX_OUT_reg = 1'b1;   
            default: TX_OUT_reg = 1'b1;
        endcase
    end

    assign TX_OUT = TX_OUT_reg;
endmodule
