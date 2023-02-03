mask = 0
mask |= int('10000001',2)
mask = f'{mask:08b}'
for relay_number, bit in enumerate(mask):
    print(f'RELAY NUMBER: {relay_number}, bit : {bit}')
