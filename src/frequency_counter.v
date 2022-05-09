`default_nettype none
`timescale 1ns/1ps
module frequency_counter #(
    // If a module starts with #() then it is parametisable. It can be instantiated with different settings
    // for the localparams defined here. So the default is an UPDATE_PERIOD of 1200 and BITS = 12
    localparam UPDATE_PERIOD = 1200,
    localparam BITS = 12
)(
    input wire              clk,
    input wire              reset,
    input wire              signal,

    input wire [BITS-1:0]   period,
    input wire              period_load,

    output wire [6:0]       segments,
    output wire             digit
    );

    localparam EDGE_COUNTER_WIDTH = $clog2(99);

    // states
    localparam STATE_COUNT  = 0;
    localparam STATE_TENS   = 1;
    localparam STATE_UNITS  = 2;

    reg [2:0] state = STATE_COUNT;

    reg [BITS-1:0] cycle_count;
    reg [EDGE_COUNTER_WIDTH-1:0] edge_count;
    wire leading_edge_detect;

    reg [3:0] ten_count;
    reg [3:0] unit_count;

    reg load;

    edge_detect edge_detector (.clk, .signal, .leading_edge_detect);

    seven_segment seven_segment_driver (.clk, .reset,
        .load, .ten_count, .unit_count, .segments, .digit);

    always @(posedge clk) begin
        if(reset) begin
            cycle_count <= 0;
            edge_count <= 0;
            ten_count <= 0;
            unit_count <= 0;
            state <= STATE_COUNT;
            load <= 0;
        end else begin
            case(state)
                STATE_COUNT: begin
                    load <= 0;
                    // count edges and clock cycles
                    if (cycle_count < UPDATE_PERIOD) begin
                        cycle_count <= cycle_count + 1;
                        if (leading_edge_detect)
                            edge_count <= edge_count + 1;
                    end
                    // if clock cycles >= UPDATE_PERIOD then go to next state
                    else begin
                        cycle_count <= 0;
                        state <= STATE_TENS;
                        ten_count <= 0;
                        unit_count <= 0;
                    end

                end

                STATE_TENS: begin
                    // count number of tens by subtracting 10 while edge counter >= 10
                    if (edge_count >= 10) begin
                        edge_count <= edge_count - 10;
                        ten_count <= ten_count + 1;
                    end
                    // then go to next state
                    else begin
                        state <= STATE_UNITS;
                    end

                end

                STATE_UNITS: begin
                    // what is left in edge counter is units
                    edge_count <= 0;
                    unit_count <= edge_count;

                    // update the display
                    load <= 1;

                    // go back to counting
                    state <= STATE_COUNT;
                end

                default:
                    state           <= STATE_COUNT;

            endcase
        end
    end

endmodule
