def binary_to_hex(binary_str):
    if len(binary_str) != 32:
        raise ValueError("Chuỗi nhị phân phải có đúng 32 bit")

    hex_str = hex(int(binary_str, 2))[2:].upper()
    return hex_str.zfill(8)

binary_input = "01000000010010001111010111000011"
hex_output = binary_to_hex(binary_input)

print(f"Binary: {binary_input}")
print(f"Hex: {hex_output}")