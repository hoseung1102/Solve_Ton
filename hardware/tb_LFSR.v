
module tb_LFSR;
    parameter DATA_WIDTH = 16;
    integer file;

    reg clk;
    reg rst;
    reg [DATA_WIDTH-1:0] seed_in;
    reg seed_valid;
    wire [DATA_WIDTH-1:0] random_number;
    wire random_number_valid;
    reg [DATA_WIDTH-1:0] random_number_array[9:0];
    reg [3:0] cnt;

    LFSR u_LFSR (
        .clk(clk), 
        .rst(rst), 
        .seed_in(seed_in),
        .seed_valid(seed_valid),
        .random_number(random_number),
        .random_number_valid(random_number_valid)
        );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        #10 rst = 0;
        #10 
        seed_in = 16'hffff;
        seed_valid = 1;
        #8 seed_valid = 0;

        wait(cnt == 10);
        file = $fopen("output.bin", "wb");
        if (!file) begin
            $display("Error: Could not open file.");
            $finish;
        end
        for (integer i = 0; i < 10; i = i + 1) begin
            $fdisplay(file, "%b", random_number_array[i]);
        end
        // $fwrite(file, "%b", random_number_array);
        $fclose(file);
        $display("Binary data written to output.bin.");
        $finish;
    end
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            cnt <= 0;
        end
        else begin
            if(random_number_valid) begin
                cnt <= cnt + 1;
                random_number_array[cnt] <= random_number;
            end
        end
    end

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, tb_LFSR);
    end
endmodule