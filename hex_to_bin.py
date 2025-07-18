def hex_to_bin(hex_str):
    hex_str = hex_str.replace("0x", "").replace("0X", "")  # bỏ tiền tố
    try:
        bin_str = bin(int(hex_str, 16))[2:]  # chuyển sang nhị phân, bỏ '0b'
        bin_str = bin_str.zfill(len(hex_str) * 4)  # làm đầy đủ số bit
        return bin_str
    except ValueError:
        return "Giá trị hex không hợp lệ."
def bin_to_hex(bin_str):
    # Chuyển từ chuỗi nhị phân sang số nguyên
    decimal_value = int(bin_str, 2)
    # Chuyển từ số nguyên sang chuỗi hexa
    hex_str = hex(decimal_value)[2:]  # [2:] để bỏ '0x' ở đầu
    return hex_str.upper()  # hoặc .lower() nếu muốn chữ thường
# Nhập từ bàn phím
#hex_input = input("Nhập giá trị hex (ví dụ 1F hoặc 0x1F): ")
#binary_output = bin_to_hex(hex_input)
#print(f"Giá trị nhị phân tương ứng: {binary_output}")
