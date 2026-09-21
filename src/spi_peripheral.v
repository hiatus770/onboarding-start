`default_nettype none


module spi_peripheral #(
    parameter MAX_ADDRESS = 7'h04 // max addressable address is 0x04 according to spec
)(
    input wire clk,
    input wire rst_n,
    input wire sclk,
    input wire cs, // chip select
    input wire copi, // controller out, peripheral in, we aren't doing any reads only writes to the registers
    output wire [7:0] en_reg_out_7_0, en_reg_out_15_8, en_reg_pwm_7_0, en_reg_pwm_15_8, pwm_duty_cycle
);
    reg [7:0] regfile [0:4]; // this means i have 5 registers, each of 8 bits

    reg [1:0] cs_sync;
    reg [1:0] sclk_sync;
    reg [1:0] copi_sync;
    wire cs_stable;
    wire rise_cs;
    wire sclk_stable;
    wire copi_stable;
    wire rise_sclk;

    reg sclk_prev = 1'b0;
    reg cs_prev = 1'b1;

    // First stage, setup the metastability flip flops on the sclk, we should sample at a higher rate which is clk
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cs_sync <= 2'b11;
            sclk_sync <= 2'b00;
            copi_sync <= 2'b00;
        end else begin
            // shift the least significant to most significant, meaning the most significant has the stable outputs
            cs_sync <= {cs_sync[0], cs};
            copi_sync <= {copi_sync[0], copi};
            sclk_sync <= {sclk_sync[0], sclk};
            sclk_prev <= sclk_stable;
            cs_prev   <= cs_stable;
        end
    end

    // determine when it is a rising or falling edge
    assign cs_stable   = cs_sync[1];
    assign sclk_stable = sclk_sync[1];
    assign copi_stable = copi_sync[1];


    assign rise_sclk = (!sclk_prev) & sclk_stable; // regular active high so we go from 0 -> 1
    assign rise_cs   = (!cs_stable) & cs_prev; // this is the negated rise, so we go from 1 -> 0

    reg [4:0] bits;
    reg [15:0] shift;

    // the logic for the data, transmission mode and when the edge goes down
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            regfile[0] <= 8'h00;
            regfile[1] <= 8'h00;
            regfile[2] <= 8'h00;
            regfile[3] <= 8'h00;
            regfile[4] <= 8'h00;
            bits <= 5'd0;
        end else if (rise_cs) begin
            bits <= 5'b00000; // reset our count once we get the chip select set low
        end else if (rise_sclk && !cs_stable) begin
            bits <= bits + 1'h1;
            shift <= {shift[14:0], copi_stable};
        end else if (bits == 5'd16) begin // once we reach 16 bits we reset
            bits <= 5'b00000; // reset our count once we reset our protocol
            // check if transaction bit was set
            if (shift[15] && (shift[14:8] <= MAX_ADDRESS)) begin
                if (shift[14:8] == 7'h00) begin
                    regfile[0] <= shift[7:0];
                end
                if (shift[14:8] == 7'h01) begin
                    regfile[1] <= shift[7:0];
                end
                if (shift[14:8] == 7'h02) begin
                    regfile[2] <= shift[7:0];
                end
                if (shift[14:8] == 7'h03) begin
                    regfile[3] <= shift[7:0];
                end
                if (shift[14:8] == 7'h04) begin
                    regfile[4] <= shift[7:0];
                end
            end
        end
    end

    // assign outputs from the regfile
    assign en_reg_out_7_0   = regfile[0];
    assign en_reg_out_15_8  = regfile[1];
    assign en_reg_pwm_7_0   = regfile[2];
    assign en_reg_pwm_15_8  = regfile[3];
    assign pwm_duty_cycle   = regfile[4];

endmodule
