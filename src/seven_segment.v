`default_nettype none
`timescale 1ns/1ps
module seven_segment (
    input wire          clk,
    input wire          reset,
    input wire          load,
    input wire [3:0]    ten_count,
    input wire [3:0]    unit_count,
    output reg [6:0]    segments,
    output reg          digit
);

    reg [3:0] ten_count_buf;
    reg [3:0] unit_count_buf;
    reg [3:0] selected_count;

    assign selected_count = digit ? ten_count_buf : unit_count_buf;

    always @(*) begin
        case (selected_count)
            7'd0: segments = 7'b0111111; // a, b, c, d, e, f
            7'd1: segments = 7'b0000110; // b, c
            7'd2: segments = 7'b1011011; // a, b, d, e, g
            7'd3: segments = 7'b1001111; // a, b, c, d, g
            7'd4: segments = 7'b1100110; // b, c, f, g
            7'd5: segments = 7'b1101101; // a, c, d, f, g
            7'd6: segments = 7'b1111100; // c, d, e, f, g
            7'd7: segments = 7'b0000111; // a, b, c
            7'd8: segments = 7'b1111111; // a, b, c, d, e, f, g
            7'd9: segments = 7'b1100111; // a ,b, c, f, g
            default: segments = 7'b0000000;
        endcase
    end

    always @(posedge clk) begin
        if (reset) begin
            digit <= 1'b0;
            ten_count_buf <= 4'b0;
            unit_count_buf <= 4'b0;
        end
        else if (load) begin
            ten_count_buf <= ten_count;
            unit_count_buf <= unit_count;
        end
        else
            digit <= ~digit;
    end

endmodule
