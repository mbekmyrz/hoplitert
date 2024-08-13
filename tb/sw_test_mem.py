import math

# parse from arguments
_IN_MEM_FILE = "mem/sw_in.mem"
_OUT_MEM_FILE = "mem/sw_out.mem"
_X_DIM = 4
_Y_DIM = 4
_X_POS = 0
_Y_POS = 0
_D_W = 4

_X_W = math.ceil(math.log2(_X_DIM))
_Y_W = math.ceil(math.log2(_Y_DIM))
_A_W = _X_W + _Y_W

in_mem_file = open(_IN_MEM_FILE, "r")
out_mem_file = open(_OUT_MEM_FILE, "r")

in_mem = in_mem_file.readlines()
out_mem = out_mem_file.readlines()

print('Hey! Started checking switch output...')

for i in range(len(in_mem)//3):
    xin_line, yin_line, pein_line = in_mem[3*i:3*(i+1)]
    xout_line, yout_line, peout_line = out_mem[3*i:3*(i+1)]

    xin_valid, xin_addr, xin_data = xin_line[0], xin_line[1:1+_A_W], xin_line[1+_A_W:]
    yin_valid, yin_addr, yin_data = yin_line[0], yin_line[1:1+_A_W], yin_line[1+_A_W:]
    pein_valid, pein_addr, pein_data = pein_line[0], pein_line[1:1+_A_W], pein_line[1+_A_W:]

    sw_ready = xout_line[0]
    xout_valid, xout_addr, xout_data = xout_line[1], xout_line[2:2+_A_W], xout_line[2+_A_W:]
    yout_valid, yout_addr, yout_data = yout_line[1], yout_line[2:2+_A_W], yout_line[2+_A_W:]
    peout_valid, peout_addr, peout_data = peout_line[1], peout_line[2:2+_A_W], peout_line[2+_A_W:]

    xin_wants_xout = (int(xin_addr[:_X_W], 2) != _X_POS)
    xin_wants_yout = (int(xin_addr[:_X_W], 2) == _X_POS)
    xin_may_arrived = xin_wants_yout and (int(xin_addr[_X_W:], 2) == _Y_POS)
    if xin_valid == '1':
        if xin_wants_yout: 
            if (xin_addr + xin_data) != (yout_addr + yout_data):
                print(f'line{3*i+1}: w->s/pe, {xin_line[:-1]} - {yout_line[:-1]}')
                print(f'line{3*i+1}: w->s/pe, yout.data should be xin.data')
            if xin_may_arrived:
                if yout_valid != '0': print(f'line{3*i+1}: w->pe, yout.valid should be 0')
                if peout_valid != '1': print(f'line{3*i+1}: w->pe, peout.valid should be 1')
            else:
                if yout_valid != '1': print(f'line{3*i+1}: w->s, yout.valid should be 1')
                if peout_valid != '0': print(f'line{3*i+1}: w->s, peout.valid should be 0')
        else:
            if (xin_addr + xin_data) != (xout_addr + xout_data):
                print(f'line{3*i+1}: w->e, {xin_line[:-1]} - {xout_line[:-1]}')
                print(f'line{3*i+1}: w->e, xout.data should be xin.data')
            if xout_valid != '1':
                print(f'line{3*i+1}: w->e, xout.valid should be 1')

    yin_allowed_yout = (xin_valid == '0') or (xin_wants_yout is False)
    yin_may_arrived = (int(yin_addr[_X_W:], 2) == _Y_POS)
    if yin_valid == '1':
        if yin_allowed_yout:
            if (yin_addr + yin_data) != (yout_addr + yout_data):
                print(f'line{3*i+2}: n->s/pe, {yin_line[:-1]} - {yout_line[:-1]}')
                print(f'line{3*i+2}: n->s/pe, yout.data should be yin.data')
            if yin_may_arrived:
                if yout_valid  != '0': print(f'line{3*i+2}: n->pe, yout.valid should be 0')
                if peout_valid != '1': print(f'line{3*i+2}: n->pe, peout.valid should be 1')
            else:
                if yout_valid  != '1': print(f'line{3*i+2}: n->s, yout.valid should be 1')
                if peout_valid != '0': print(f'line{3*i+2}: n->s, peout.valid should be 0')
        else:
            if (yin_addr + yin_data) != (xout_addr + xout_data):
                print(f'line{3*i+2}: n->e, {yin_line[:-1]} - {xout_line[:-1]}')
                print(f'line{3*i+2}: n->e, xout.data should be yin.data')
            if xout_valid != '1':
                print(f'line{3*i+2}: n->e, xout.valid should be 1')
    
    pe_wants_xout = (int(pein_addr[:_X_W], 2) != _X_POS)
    pe_wants_yout = (int(pein_addr[:_X_W], 2) == _X_POS)
    pe_allowed_xout = (xin_valid == '0')
    pe_allowed_yout = (xin_valid == '0' or xin_wants_yout is False) and (yin_valid == '0')
    if pein_valid == '1':
        if pe_wants_xout and pe_allowed_xout:
            if (pein_addr + pein_data) != (xout_addr + xout_data):
                print(f'line{3*i+3}: pe->e, {pein_line[:-1]} - {xout_line[:-1]}')
                print(f'line{3*i+3}: pe->e, xout.data should be pein.data')
            if xout_valid != '1': print(f'line{3*i+3}: pe->e, xout.valid should be 1')
        if pe_wants_yout and pe_allowed_yout:
            if (pein_addr + pein_data) != (yout_addr + yout_data):
                print(f'line{3*i+3}: pe->s, {pein_line[:-1]} - {yout_line[:-1]}')
                print(f'line{3*i+3}: pe->s, yout.data should be pein.data')
            if yout_valid != '1': print(f'line{3*i+3}: pe->s, yout.valid should be 1')

in_mem_file.close()
out_mem_file.close()

print('Finished checking switch output!')
