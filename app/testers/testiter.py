string = "["
for controller in range(5):
    string += str(controller)
    string += ', ' 
string = f'{string[:-2] }]'
print( f'CONTROLLER SET:  HEAD --->  {string}')