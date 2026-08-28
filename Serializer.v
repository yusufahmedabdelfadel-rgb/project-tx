module serializer (
    input wire clk,            
    input wire rst_n,              
    input wire load_data,        
    input wire [7:0] data_in,     
    input wire shift_en,     
    output wire serial_out    
);

    // سجل الإزاحة الداخلي (8 بت)
    reg [7:0] shift_reg;

    // عملية الإزاحة والتحميل
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // عند إعادة التعيين، نمسح السجل
            shift_reg <= 8'b0;
        end else if (load_data) begin
            // تحميل البيانات الجديدة (متوازية)
            shift_reg <= data_in;
        end else if (shift_en) begin
            // إزاحة لليمين مع إدخال صفر في البت الأكثر أهمية (MSB)
            // هكذا يخرج البت الأقل أهمية (LSB) أولاً
            shift_reg <= {1'b0, shift_reg[7:1]};
        end
    end

    assign serial_out = shift_reg[0];

endmodule