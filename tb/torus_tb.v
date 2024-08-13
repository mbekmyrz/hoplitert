`timescale 1ps / 1ps

module torus_tb
#(
	parameter integer D_W 	    = 16,		//Data width
	parameter integer X_DIM     = 4,		//X dimension of torus
	parameter integer Y_DIM     = 4,		//Y dimension of torus
	parameter integer MAX_RATE  = 1,		//1/injection rate (>= 1)
	parameter integer MAX_TOKEN = 1,		//max burst of consecutive pkts (>=1)
	parameter integer MEM_D     = 20 		//Testing memory depth
)
(
	input wire clk,
	input wire rst
);

    localparam X_AW = $clog2(X_DIM);			//X address width
	localparam Y_AW = $clog2(Y_DIM);			//Y address width
    localparam A_W 	= X_AW + Y_AW;		        //Address width
    localparam P_W 	= D_W + A_W;		        //pkt width

	wire [P_W-1:0] x_pkt [X_DIM-1:0][Y_DIM-1:0];
	wire  		   x_vld  [X_DIM-1:0][Y_DIM-1:0];
	
	wire [P_W-1:0] y_pkt [X_DIM-1:0][Y_DIM-1:0];
	wire  		   y_vld  [X_DIM-1:0][Y_DIM-1:0];

	wire [P_W-1:0] pe_pkt[X_DIM-1:0][Y_DIM-1:0];
	wire  		   pe_vld [X_DIM-1:0][Y_DIM-1:0];
	
	wire  		   sw_vld [X_DIM-1:0][Y_DIM-1:0];
	wire  		   sw_rdy [X_DIM-1:0][Y_DIM-1:0];

	genvar x, y;
	generate
		for(x=0; x<X_DIM; x=x+1) begin: row
			for(y=0; y<Y_DIM; y=y+1) begin: col
				pewrap_tb
				#(
					.P_W		( P_W 			  ),
                    .X_AW		( X_AW			  ),
					.Y_AW		( Y_AW			  ),
					.X_POS		( x 			  ),
					.Y_POS		( y 			  ),
					.MAX_RATE	( MAX_RATE		  ),
					.MAX_TOKEN	( MAX_TOKEN		  ),
					.MEM_D      ( MEM_D           )
				)
				pw
				(
					.clk		( clk			  ),
					.rst		( rst 			  ),
					.in_pkt	    ( y_pkt [x][y]    ),
					.in_vld	    ( sw_vld[x][y]    ),
					.sw_rdy	    ( sw_rdy[x][y]    ),
					.out_pkt	( pe_pkt[x][y]    ),
					.out_vld	( pe_vld[x][y]    )
				);

				switch
				#(
					.P_W		( P_W   		  ),
					.X_AW		( X_AW			  ),
					.Y_AW		( Y_AW			  ),
					.X_POS		( x				  ),
					.Y_POS		( y				  )
				)
				sw
				(
					.clk		( clk			  ),
					.rst		( rst			  ),
					
					.xin_pkt	( (x==0) ? x_pkt[X_DIM-1][y] : x_pkt[x-1][y] ),
					.xin_vld	( (x==0) ? x_vld[X_DIM-1][y] : x_vld[x-1][y] ),
					.yin_pkt	( (y==0) ? y_pkt[x][Y_DIM-1] : y_pkt[x][y-1] ),
					.yin_vld	( (y==0) ? y_vld[x][Y_DIM-1] : y_vld[x][y-1] ),
					.pein_pkt   ( pe_pkt[x][y]    ),
					.pein_vld   ( pe_vld[x][y]    ),

					.xout_pkt   ( x_pkt [x][y]    ),		
					.xout_vld   ( x_vld [x][y]    ),	
					.yout_pkt   ( y_pkt [x][y]    ),	
					.yout_vld   ( y_vld [x][y]    ),
					.peout_vld  ( sw_vld[x][y]    ),
					.peout_rdy  ( sw_rdy[x][y]    )
				);

			end
		end
	endgenerate

endmodule
