bit = '1'
inverse = False
mask = '0'
value = (int(bit) ^ inverse) if mask == 'x' else (int(bit) ^ inverse) or int(mask)
print(value)