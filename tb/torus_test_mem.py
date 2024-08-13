
_FILE = "mem/network.txt"
_X_DIM = 4
_Y_DIM = 4


f = open(_FILE, "r")

# array of PEs
pes = {}

for x in range(_X_DIM):
    pes[x] = {}
    for y in range(_Y_DIM):
        pes[x][y] = {}
        pes[x][y]['sent'] = []  # someone sent, waiting to rcv
        pes[x][y]['rcvd'] = []
        pes[x][y]['isent'] = []  # i sent to someone

datas = []
for line in f.readlines():
    line = line.split()
    cords = line[2][:-1].replace(']','').split('[')
    x, y = int(cords[1]), int(cords[2])
    data = line[3]
    if line[0] == 'Send':
        datas.append(data)
        pes[x][y]['sent'].append(data)

        cords = line[5].replace(']','').split('[')
        xh, yh = int(cords[1]), int(cords[2])
        pes[xh][yh]['isent'].append(data)
    elif line[0] == 'Received':
        pes[x][y]['rcvd'].append(data)

s0r1 = 0
s1r0 = 0
s1r2 = 0

for x in range(_X_DIM):
    for y in range(_Y_DIM):
        print(f'PE[{x}][{y}] check started...')

        if len(pes[x][y]['isent']) != 8 or len(set(pes[x][y]['isent'])) != 8:
            print('isent', len(pes[x][y]['isent'])) 

        s0r1_list = []
        for rcvd in pes[x][y]['rcvd']:
            if rcvd not in pes[x][y]['sent']:
                s0r1 += 1
                s0r1_list.append(rcvd)
        if len(s0r1_list) > 0:
            print('heeeey, I rcvd, but not sent to me:', s0r1_list)
        
        s1r0_list = []
        for sent in pes[x][y]['sent']:
            if sent not in pes[x][y]['rcvd']:
                s1r0 += 1
                s1r0_list.append(sent)
        if len(s1r0_list) > 0:
            total = len(pes[x][y]['sent'])
            print(f'heeeey, smn sent, but I not rcvd ({len(s1r0_list)}/{total}):', s1r0_list)
        
        rxcount = [(data, pes[x][y]['rcvd'].count(data)) for data in pes[x][y]['rcvd']]
        s1r2_list = []
        for count in rxcount:
            if count[1] > 1:
                s1r2 += 1
                s1r2_list.append(count)
        if len(s1r2_list) > 0:
            print('heeeey, rcvd multiple times:', set(s1r2_list))
        
        print(f'Check finished...')
        print('--')

if s0r1 == 0 and s1r0 == 0 and s1r2 == 0:
    print('All good!')
# to check if all data sent is unique
print(len(datas), len(set(datas)))



