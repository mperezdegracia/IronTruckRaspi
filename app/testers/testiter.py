bin  = int('10000001',2)
bin |=int('01000010',2)
'''
bin2 ='01110000'
bin3 ='00000010'
dec = int(bin, 2)
res = int(bin, 2) | int(bin2, 2) | int(bin3,2)
'''
res = bin
print(res)
print(f'{res:08b}')

