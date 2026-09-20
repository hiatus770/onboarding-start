`default_nettype none


module spi_peripheral #(
    parameter MAX_ADDRESS = 7'h04 // max addressable address is 0x04 according to spec
)(
    input wire sclk,
    input wire cs, // chip select
    input wire copi, // controller out, peripheral in, we aren't doing any reads only writes to the registers
    output wire [7:0] en_reg_out_7_0, en_reg_out_15_8, en_reg_pwm_7_0, en_reg_pwm_15_8, pwm_duty_cycle
);
    reg [7:0] regfile [0:4]; // this means i have 5 registers, each of 8 bits


    // First stage, setup the metastability flip flops on the sclk, we should sample at a higher rate to avoid error

    // Then figure out when there is a rising edge or falling edge and perform necessary function

    // assign outputs from the regfile
    assign en_reg_out_7_0   = regfile[0];
    assign en_reg_out_15_8  = regfile[1];
    assign en_reg_pwm_7_0   = regfile[2];
    assign en_reg_pwm_15_8  = regfile[3];
    assign pwm_duty_cycle   = regfile[4];
endmodule
