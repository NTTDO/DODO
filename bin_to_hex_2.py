def binary_to_hex(binary_str):
    # Kiểm tra xem chuỗi có rỗng không
    if not binary_str:
        raise ValueError("Chuỗi nhị phân không được rỗng")
    # Nếu độ dài không chia hết cho 4, thêm các số 0 vào đầu để làm tròn
    if len(binary_str) % 4 != 0:
        binary_str = binary_str.zfill(len(binary_str) + (4 - len(binary_str) % 4))
    # Chuyển đổi từng nhóm 4 bit sang hex
    hex_str = hex(int(binary_str, 2))[2:].upper()

    return hex_str
binary_input = "01000000010010001111010111000011"
hex_output = binary_to_hex(binary_input)

print(f"Binary: {binary_input}")
print(f"Hex: {hex_output}")