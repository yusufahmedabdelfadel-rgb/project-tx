module uart_tx (
    input clk,
    input rst_n,
    input [7:0] P_DATA,
    input V_INPUT,
    input P_EN,
    input P_BIT,
    output TX_OUT,
    output busy
);

wire load_data, shift_en, serial_out, parity_bit;
wire [2:0] state;

control ctrl (
    .clk(clk),
    .rst_n(rst_n),
    .V_INPUT(V_INPUT),
    .P_EN(P_EN),
    .busy(busy),
    .load_data(load_data),
    .shift_en(shift_en),
    .state(state)
);

serializer ser (
    .clk(clk),
    .rst_n(rst_n),
    .load_data(load_data),
    .data_in(P_DATA),
    .shift_en(shift_en),
    .serial_out(serial_out)
);

parity_calc pc (
    .data_in(P_DATA),
    .P_BIT(P_BIT),
    .parity_bit(parity_bit)
);

mux mux_inst (
    .state(state),
    .serial_out(serial_out),
    .parity_bit(parity_bit),
    .TX_OUT(TX_OUT)
);

endmodule

