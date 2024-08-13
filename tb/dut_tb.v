`timescale 1ps / 1ps

module dut_tb
#(
	parameter integer D_W 	    = 16,		//Data width
	parameter integer X_DIM     = 4,		//X dimension of torus
	parameter integer Y_DIM     = 4,		//Y dimension of torus
	parameter integer MAX_RATE  = 5,		//1/injection rate (>= 1)
	parameter integer MAX_TOKEN = 2,		//max burst of consecutive packets (>=1)
	parameter integer MEM_D     = 20 		//Testing memory depth
)
();

    localparam REP = MEM_D * X_DIM * Y_DIM * MAX_RATE;

    reg        clk = 1'b0;
    reg  [1:0] rst;

    always #1 clk = ~clk;

    always@(posedge clk) begin
        rst <= rst>>1;
    end

    initial begin
        $timeformat(-9, 2, " ns", 20);
        rst <= 2'b11;
        repeat(REP) @(posedge clk);
        $finish;
    end

    torus_tb
    #(
	    .D_W 	  ( D_W       ),
	    .X_DIM    ( X_DIM     ),
	    .Y_DIM    ( Y_DIM     ),
	    .MAX_RATE ( MAX_RATE  ),
	    .MAX_TOKEN( MAX_TOKEN ),
	    .MEM_D    ( MEM_D     )
    )
    tor
    (
        .clk(clk),
        .rst(rst[0])
    );

endmodule
