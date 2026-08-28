module control (
    input clk,
    input rst_n,
    input V_INPUT,
    input P_EN,
    output reg busy,
    output reg load_data,
    output reg shift_en,
    output reg [2:0] state
);

// تعريف الحالات الخمس بأسماء step0..step4
localparam step0 = 3'd0,
           step1 = 3'd1,
           step2 = 3'd2,
           step3 = 3'd3,
           step4 = 3'd4;

reg [2:0] bit_count;   // عداد لعدد بتات البيانات (0..7)

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state     <= step0;
        busy      <= 1'b0;
        load_data <= 1'b0;
        shift_en  <= 1'b0;
        bit_count <= 3'd0;
    end else begin
        // القيم الافتراضية
        load_data <= 1'b0;
        shift_en  <= 1'b0;
        
        case (state)
            step0: begin
                // في حالة السكون، ننتظر طلب إرسال جديد
                if (V_INPUT) begin
                    state     <= step1;
                    busy      <= 1'b1;
                    load_data <= 1'b1;   // تحميل البيانات في المسلسل
                    bit_count <= 3'd0;
                end
            end
            
            step1: begin
                // دورة واحدة لبت البداية (0)
                state <= step2;
            end
            
            step2: begin
                // إرسال 8 بتات بيانات (بت واحد كل دورة)
                shift_en <= 1'b1;
                if (bit_count == 3'd7) begin
                    // انتهى إرسال كل البتات
                    if (P_EN)
                        state <= step3;   // باريتي مفعل
                    else
                        state <= step4;   // بدون باريتي، نذهب مباشرة للتوقف
                    bit_count <= 3'd0;
                end else begin
                    bit_count <= bit_count + 1'b1;
                end
            end
            
            step3: begin
                // دورة واحدة لبت الباريتي
                state <= step4;
            end
            
            step4: begin
                // دورة واحدة لبت التوقف (1)، ثم العودة للسكون
                state <= step0;
                busy  <= 1'b0;
            end
            
            default: state <= step0;
        endcase
    end
end

endmodule