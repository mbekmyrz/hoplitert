`timescale 1ps / 1ps

module counter_tb 
#(
	parameter integer MAX_RATE  = 10,	//1/injection rate (>= 1)
	parameter integer MAX_TOKEN = 5		//max burst of consecutive packets (>=1)
)
();

    reg clk = 1'b0;
    reg [1:0] rst;
    reg [11:0] valid_reg; 
    wire ack, token;

    // initial begin
    //   $readmemh("counter_in.mem", in_mem);
    // end

    // final begin
    //   $writememh("counter_out.mem", out_mem);
    // end

    always #1 clk = ~clk;

    always @(posedge clk) begin
        rst <= rst>>1;
        valid_reg <= {valid_reg[0], valid_reg[11:1]};
    end

    assign ack = valid_reg[0] & token;

    initial begin
        $timeformat(-9, 2, " ns", 20);
        rst <= 2'b11;
        valid_reg <= 0;
        repeat(MAX_RATE*MAX_TOKEN) @(posedge clk);
        valid_reg <= 12'b0111_0100_1111_1100;
        repeat(MAX_RATE*MAX_TOKEN) @(posedge clk);
        valid_reg <= 0;
        repeat(MAX_RATE*MAX_TOKEN) @(posedge clk);
        $finish;
    end

    counter
    #(
        .MAX_RATE(MAX_RATE),
        .MAX_TOKEN(MAX_TOKEN)
    )
    counter_inst
    (
        .clk(clk),
        .rst(rst[0]),
        .ack(ack),
        .token(token)
    );

endmodule
