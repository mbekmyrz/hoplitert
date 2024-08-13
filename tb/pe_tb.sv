`timescale 1ps / 1ps
`include "include.h"

module pe_tb
#(
	parameter integer P_W 	= 16,			//Data width
	parameter integer X_AW  = 2,			//X addr width of torus
	parameter integer Y_AW  = 2,			//Y addr width of torus
	parameter integer X_POS = 0,			//X position of PE
	parameter integer Y_POS = 0, 			//Y position of PE
	parameter integer MEM_D = 20 			//Testing memory depth
)
(
	input  wire 		  clk,
	input  wire 		  rst,
	input  wire [P_W-1:0] in_pkt,	    //input packet (from South port of switch)
	input  wire 		  in_vld,		//input packet valid
	input  wire 		  sw_rdy,		//switch received packet sent by this pe, sw_rcvd
	output wire [P_W-1:0] out_pkt,	    //output packet = {addr, data}
	output wire 		  out_vld		//output packet valid
);

    localparam [`A_W-1:0]    MYPOS              = {X_POS[X_AW-1:0], Y_POS[Y_AW-1:0]};
	
	reg [`A_W:0]             pe_mem[0:MEM_D-1];            // contains random addresses
	
    reg [$clog2(MEM_D):0]    mem_addr           = 0;
    reg [P_W-1:0]            out_pkt_reg        = 0;
    reg                      out_vld_reg        = 0;

    initial begin
`ifdef TERMINAL
        $readmemb($sformatf("mem/pe_in_%0d_%0d.mem", X_POS, Y_POS), pe_mem);
`else
        $readmemb($sformatf("pe_in_%0d_%0d.mem", X_POS, Y_POS), pe_mem); //for vivado
`endif
    end

    wire tran_done = sw_rdy & out_vld_reg;

    //mem_addr management
	always @(posedge clk) begin
		if (rst) begin
            mem_addr         <= 0;
            out_vld_reg      <= 0;
		end else begin
            if (mem_addr < MEM_D-1) begin
                out_vld_reg  <= 1'b1;
                if (tran_done) begin
                    mem_addr <= mem_addr + 1;
                end
            end
            
            if ((mem_addr == MEM_D-1) && tran_done) begin
		        out_vld_reg  <= 1'b0;
		    end
		end
    end    

    //data management
    always @(posedge clk) begin
		if (rst) begin
            out_pkt_reg`data <= {MYPOS, {$clog2(MEM_D){1'b0}}};
            out_pkt_reg`addr <= pe_mem[mem_addr];
		end else begin
            if (tran_done) begin
                $display("Send to PE[%0d][%0d]: %h from PE[%0d][%0d]", out_pkt_reg`addrx, out_pkt_reg`addry, out_pkt_reg`data, X_POS, Y_POS);
                out_pkt_reg`data <= out_pkt_reg`data + 1'b1;
                out_pkt_reg`addr <= pe_mem[mem_addr + 1'b1];
            end

            if (in_vld) begin
                $display("Received by PE[%0d][%0d]: %h", X_POS, Y_POS, in_pkt`data);
            end
		end
    end

    assign out_pkt = out_pkt_reg;
    assign out_vld = out_vld_reg;

endmodule
