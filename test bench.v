`timescale 1ns / 1ps

module uart_tb;

    // 1. الإشارات الأساسية
    reg  clk, rst_n;
    reg  [7:0] P_DATA;
    reg  V_INPUT, P_EN, P_BIT;
    wire TX_OUT, busy;

    // 2. تعريف المتغيرات العامة التي ستستخدمها المهام
    reg [7:0] exp_bits [0:15];   // مصفوفة البتات المتوقعة
    integer i, test_id;          // العدادات

    // 3. تركيب الوحدة العليا
    uart_tx dut (.*);

    // 4. توليد الساعة
    always #5 clk = ~clk;

    // 5. دالة حساب الباريتي
    function calc_parity;
        input [7:0] data;
        input p_bit;
        begin
            calc_parity = ^data;
            if (p_bit) calc_parity = ~calc_parity;
        end
    endfunction

    // 6. مهمة إرسال نبضة V_INPUT
    task send_trigger;
        begin
            @(posedge clk);
            V_INPUT = 1'b1;
            @(posedge clk);
            V_INPUT = 1'b0;
        end
    endtask

    // 7. مهمة التحقق من الإطار (تستخدم exp_bits العامة)
    task check_frame;
        input integer len;
        begin
            @(posedge clk);
            if (busy !== 1'b1) $error("busy not high");
            for (i = 0; i < len; i = i + 1) begin
                @(posedge clk);
                if (TX_OUT !== exp_bits[i]) begin
                    $error("Bit %0d: expected %b, got %b", i, exp_bits[i], TX_OUT);
                    $finish;
                end
            end
            @(posedge clk);
            if (TX_OUT !== 1'b1 || busy !== 1'b0) $error("End of frame error");
            $display("Test %0d passed!", test_id);
        end
    endtask

    // 8. إجراءات الاختبار الرئيسية
    initial begin
        // تهيئة الإشارات
        clk = 0; rst_n = 0; P_DATA = 0; V_INPUT = 0; P_EN = 0; P_BIT = 0;
        #15 rst_n = 1;
        #10;

        // ---------- Test 1: No parity ----------
        test_id = 1;
        P_EN = 0; P_DATA = 8'hA5;
        exp_bits[0] = 1'b0; // START
        for (i = 0; i < 8; i = i + 1) exp_bits[i+1] = P_DATA[i];
        exp_bits[9] = 1'b1; // STOP
        send_trigger();
        check_frame(10);
        #20;

        // ---------- Test 2: Even parity ----------
        test_id = 2;
        P_EN = 1; P_BIT = 0; P_DATA = 8'h01;
        exp_bits[0] = 1'b0;
        for (i = 0; i < 8; i = i + 1) exp_bits[i+1] = P_DATA[i];
        exp_bits[9] = calc_parity(P_DATA, P_BIT);
        exp_bits[10] = 1'b1;
        send_trigger();
        check_frame(11);
        #20;

        // ---------- Test 3: Odd parity ----------
        test_id = 3;
        P_EN = 1; P_BIT = 1; P_DATA = 8'h01;
        exp_bits[0] = 1'b0;
        for (i = 0; i < 8; i = i + 1) exp_bits[i+1] = P_DATA[i];
        exp_bits[9] = calc_parity(P_DATA, P_BIT);
        exp_bits[10] = 1'b1;
        send_trigger();
        check_frame(11);
        #20;

        $display("All tests passed successfully!");
        $finish;
    end

endmodule