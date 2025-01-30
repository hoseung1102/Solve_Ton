module LFSR #(
    parameter DATA_WIDTH = 16,
    parameter MAX_PERIOD = 65535, // 2^16 - 1
    parameter LOG2_DATA_WIDTH = 4
    // primitive polimonials to be changed as DATA_WIDTH changes // xor_data
)
(
    input clk,
    input rst,
    input [DATA_WIDTH-1:0] seed_in,
    input seed_valid,
 
    output [DATA_WIDTH-1:0] random_number,
    output random_number_valid
);
    parameter IDLE = 0, EXECUTE = 1, LAST = 2;

    reg [1:0] state;
    reg [DATA_WIDTH-1:0] random_number_cnt;
    // reg [$log2(DATA_WIDTH)-1:0] shift_cnt;
    reg [LOG2_DATA_WIDTH-1:0] shift_cnt;
    reg [DATA_WIDTH-1:0] data;
    wire xor_data;

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            state <= IDLE;
        end
        else begin
            case(state)
            IDLE: begin
                if(seed_valid) state <= EXECUTE;
            end
            EXECUTE: begin
                if(random_number_cnt >= MAX_PERIOD - 1) begin
                    state <= LAST;
                end
            end
            LAST: begin
                state <= IDLE;
            end
            endcase 
        end
    end

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            random_number_cnt <= 0;
        end
        else if(state == EXECUTE) begin
            if(random_number_cnt >= MAX_PERIOD - 1) random_number_cnt <= 0;
            else random_number_cnt <= random_number_cnt + 1;
        end
    end
    
    assign xor_data = data[0] + data[1] + data[3] + data[12]; // 16 bits primitive polynomial

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            shift_cnt <= 0;
            data <= 0;
        end
        else begin
            if(state == IDLE && seed_valid) begin
                data <= seed_in;
            end
            else if(state == EXECUTE) begin
                shift_cnt <= shift_cnt + 1; // overflow makes it 0

                data[DATA_WIDTH-2:0] <= data[DATA_WIDTH-1:1];
                data[DATA_WIDTH-1] <= xor_data;
            end
        end
    end

    assign random_number = data;
    assign random_number_valid = (state == EXECUTE) && (shift_cnt == 0);
endmodule
