import random

def random_hex_string(length):
    hex_chars = '0123456789abcdef'
    return ''.join(random.choice(hex_chars) for _ in range(length))

random_hex = random_hex_string(288)
print(random_hex)
