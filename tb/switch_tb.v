`timescale 1ps / 1ps

module switch_tb 
#(
	parameter integer D_W 	= 4,				//Data width
	parameter integer A_W 	= 4,				//Address width
	parameter integer X_DIM = 4,				//X dimension of torus
	parameter integer Y_DIM = 4,				//Y dimension of torus
	parameter integer X_POS = 0,				//X position of switch
	parameter integer Y_POS = 0 				//Y position of switch
)
();
    
    reg                clk = 1'b0;
    reg  [1:0]         rst;
    
    //inputs
    reg  [D_W-1:0]     x_in_data,   y_in_data,  pe_in_data;
	reg  [A_W-1:0]     x_in_addr,   y_in_addr,  pe_in_addr;
	reg			       x_in_valid,  y_in_valid, pe_in_valid;
    //outputs
    wire [D_W-1:0]     x_out_data,  y_out_data;
	wire [A_W-1:0]     x_out_addr,  y_out_addr;
	wire		       x_out_valid, y_out_valid;
    wire               valid,       ready;

    localparam integer PKT_N = (4 * 2 * 3) * 8 * 3;   //Number of input packets
    //memories
    reg  [D_W+A_W:0]   in_mem  [0:PKT_N-1];       //{valid,addr,data}
    reg  [D_W+A_W+1:0] out_mem [0:PKT_N+5];       //{ready,valid,addr,data}
    reg  [$clog2(PKT_N)  -1:0] in_mem_addr;
    reg  [$clog2(PKT_N+6)-1:0] out_mem_addr;
    
    initial begin
      $readmemb("mem/sw_in.mem", in_mem);
    end

    always #1 clk = ~clk;

    always@(posedge clk) begin
        rst <= rst>>1;
    end

    initial begin
        $timeformat(-9, 2, " ns", 20);
        rst <= 2'b11;
        repeat(PKT_N) @(posedge clk);
        $writememb("mem/sw_out.mem", out_mem);
        $finish;
    end

    always@(posedge clk) begin
        if(rst[0]) begin
            {x_in_valid,  x_in_addr,  x_in_data}  <= 0;
            {y_in_valid,  y_in_addr,  y_in_data}  <= 0;
            {pe_in_valid, pe_in_addr, pe_in_data} <= 0;
            in_mem_addr  <= 0;
            out_mem_addr <= 0;
        end else begin
            if(in_mem_addr < PKT_N/3)
                in_mem_addr  <= in_mem_addr  + 1;
            if(out_mem_addr < PKT_N/3 + 2)
                out_mem_addr <= out_mem_addr + 1;

            {x_in_valid,  x_in_addr,  x_in_data}  <= in_mem[in_mem_addr*3];
            {y_in_valid,  y_in_addr,  y_in_data}  <= in_mem[in_mem_addr*3+1];
            {pe_in_valid, pe_in_addr, pe_in_data} <= in_mem[in_mem_addr*3+2];
            // $display("inmem: line%d, %b", in_mem_addr*3,   in_mem[in_mem_addr*3]);
            // $display("inmem: line%d, %b", in_mem_addr*3+1, in_mem[in_mem_addr*3+1]);
            // $display("inmem: line%d, %b", in_mem_addr*3+2, in_mem[in_mem_addr*3+2]);

            out_mem[out_mem_addr*3]   <= {ready, x_out_valid, x_out_addr, x_out_data};
            out_mem[out_mem_addr*3+1] <= {ready, y_out_valid, y_out_addr, y_out_data};
            out_mem[out_mem_addr*3+2] <= {ready, valid,       y_out_addr, y_out_data};
            // $display("outmem: line%d, %b", out_mem_addr*3,   {ready, x_out_valid, x_out_addr, x_out_data});
            // $display("outmem: line%d, %b", out_mem_addr*3+1, {ready, y_out_valid, y_out_addr, y_out_data});
            // $display("outmem: line%d, %b", out_mem_addr*3+2, {ready, valid,       y_out_addr, y_out_data});
        end
    end

    switch
    #(
        .P_W   ( P_W   ),
        .X_AW  ( X_AW  ),
        .Y_AW  ( Y_AW  ),
        .X_POS ( X_POS ),
        .Y_POS ( Y_POS )
    )
    sw
    (
        .clk         ( clk         ),
        .rst         ( rst[0]      ),
        .x_in_data   ( x_in_data   ),	//West packet data
        .x_in_valid  ( x_in_valid  ),	//West packet valid
        .y_in_data   ( y_in_data   ),	//North packet data
        .y_in_valid  ( y_in_valid  ),	//North packet valid
        .pe_in_data  ( pe_in_data  ),	//PE packet data
        .pe_in_valid ( pe_in_valid ),	//PE packet valid
        .x_out_data  ( x_out_data  ),	//East output data
        .x_out_valid ( x_out_valid ),	//East outout valid
        .y_out_data  ( y_out_data  ),	//South output data
        .y_out_valid ( y_out_valid ),	//South output valid for next router
        .valid       ( valid       ),	//South output valid for PE
        .ready       ( ready       )	//received packet from PE
    );


endmodule


