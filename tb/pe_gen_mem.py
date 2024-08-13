import math
import random
import argparse
import sys

parser = argparse.ArgumentParser(description="This script generates random destination addresses for each PE packet.")
parser.add_argument('--x_dim', default=4, type=int, help="X dimension of PE array.")
parser.add_argument('--y_dim', default=4, type=int, help="Y dimension of PE array.")
parser.add_argument('--mem_d', default=20, type=int, help="Number of outgoing packets per PE.")

args = parser.parse_args()

_X_DIM = args.x_dim
_Y_DIM = args.y_dim
_MEM_D = args.mem_d

_X_W = math.ceil(math.log2(_X_DIM))
_Y_W = math.ceil(math.log2(_Y_DIM))

def addr_fill(x, y):
    addr =  '{0:b}'.format(x).zfill(_X_W)
    addr += '{0:b}'.format(y).zfill(_Y_W)
    return addr

def gen_addr(x, y):
    addrs = []
    xalwd = list(range(_X_DIM))
    xalwd.remove(x)
    yalwd = list(range(_Y_DIM))
    yalwd.remove(y)

    xalwd = [el[0] for el in sorted([[xidx, abs(x - xidx)] for xidx in xalwd], key=lambda k: k[1])]
    yalwd = [el[0] for el in sorted([[yidx, abs(y - yidx)] for yidx in yalwd], key=lambda k: k[1])]
    
    for i in range(_MEM_D//4):
        xi = i % (_X_DIM - 1)
        yi = i % (_Y_DIM - 1)
        # 's_short'
        addrs.append(addr_fill(x, yalwd[yi]))              # same xpos, dif ypos   01
        # 's_long'
        addrs.append(addr_fill(x, yalwd[-1-yi]))           # same xpos, dif ypos   01
        # 'e_same'
        addrs.append(addr_fill(xalwd[xi], y))              # dif xpos, same ypos   10
        # 'e_long'
        addrs.append(addr_fill(xalwd[-1-xi], yalwd[-1-yi])) # dif xpos, diff ypos   11
        # # invalid
        # addrs.append('0' + addr_fill(xalwd[i], yalwd[i]))
        # print(f'{x, yalwd[yi]},{x, yalwd[-1-yi]},{xalwd[xi], y},{xalwd[-1-xi], yalwd[-1-yi]}')
    return addrs


for x in range(_X_DIM):
    for y in range(_Y_DIM):
        # print(f'Generating for pe[{x}][{y}]:')
        mem_file = open(f"mem/pe_in_{x}_{y}.mem", "w")
        pe_addr = gen_addr(x, y)
        random.shuffle(pe_addr)
        for addr in pe_addr:
            mem_file.write(addr + "\n")
        mem_file.close()
