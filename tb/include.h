`define A_W X_AW+Y_AW
`define addr [P_W-1:P_W-X_AW-Y_AW]
`define data [P_W-X_AW-Y_AW-1:0]
`define addrx [P_W-1:P_W-X_AW]
`define addry [P_W-X_AW-1:P_W-X_AW-Y_AW]