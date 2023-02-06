import re
text =  'N/508cb1cb59e8/relays/0/Relay/2/State'
print(bool(re.compile (r'Relay/\d/State($| )').search(text)))