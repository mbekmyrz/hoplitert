import math

# parse from arguments
_MEM_FILE = "mem/sw_in.mem"
_X_DIM = 4
_Y_DIM = 4
_X_POS = 0
_Y_POS = 0
_D_W = 4

_X_W = math.ceil(math.log2(_X_DIM))
_Y_W = math.ceil(math.log2(_Y_DIM))

mem_file = open(_MEM_FILE, "w")

to_pe = {'x': _X_POS, 'y': _Y_POS}          # same xpos, same ypos  00
to_s  = {'x': _X_POS, 'y': _Y_POS + 1}      # same xpos, dif ypos   01
to_e0 = {'x': _X_POS + 1, 'y': _Y_POS}      # dif xpos, same ypos   10
to_e1 = {'x': _X_POS + 1, 'y': _Y_POS + 1}  # dif xpos, diff ypos   11

addr = {'xin':  [to_pe, to_s, to_e0, to_e1],
        'yin':  [to_pe, to_s],
        'pein': [to_s, to_e0, to_e1]}

x_data  = '{0:0b}'.format(0).zfill(_D_W)
y_data  = '{0:0b}'.format(1).zfill(_D_W)
pe_data = '{0:0b}'.format(2).zfill(_D_W)

for v in range(8):
    x_valid, y_valid, pe_valid = '{0:03b}'.format(v)
    for xaddr in addr['xin']:
        x_addr =  '{0:b}'.format(xaddr['x']).zfill(_X_W)
        x_addr += '{0:b}'.format(xaddr['y']).zfill(_Y_W)
        for yaddr in addr['yin']:
            y_addr =  '{0:b}'.format(yaddr['x']).zfill(_X_W)
            y_addr += '{0:b}'.format(yaddr['y']).zfill(_Y_W)
            for peaddr in addr['pein']:
                pe_addr =  '{0:b}'.format(peaddr['x']).zfill(_X_W)
                pe_addr += '{0:b}'.format(peaddr['y']).zfill(_Y_W)
        
                x_line  = f"{x_valid}{x_addr}{x_data}" + "\n"
                y_line  = f"{y_valid}{y_addr}{y_data}" + "\n"
                pe_line = f"{pe_valid}{pe_addr}{pe_data}" + "\n"

                mem_file.write(x_line)
                mem_file.write(y_line)
                mem_file.write(pe_line)

mem_file.close()

