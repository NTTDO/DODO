def ieee754_to_float(binary_str):
    if len(binary_str) != 32:
        raise ValueError("Chuỗi nhập phải có đúng 32 ký tự.")

    # Tách bit dấu, phần exponent và phần fraction
    sign_bit = int(binary_str[0], 2)
    exponent_bits = int(binary_str[1:9], 2)
    fraction_bits = binary_str[9:]

    bias = 127  # Hệ số bù của exponent đối với 32-bit IEEE 754

    # Xử lý số đặc biệt: 0, số không, vô cực, NaN
    if exponent_bits == 255:
        if int(fraction_bits, 2) == 0:
            return float('inf') if sign_bit == 0 else float('-inf')
        else:
            return float('nan')
    elif exponent_bits == 0:
        # Số gần 0 (denormalized number)
        exponent = 1 - bias
        mantissa = 0
        # Không có bit 1 ngầm định
        for i, bit in enumerate(fraction_bits):
            mantissa += int(bit) * 2 ** -(i + 1)
    else:
        exponent = exponent_bits - bias
        # Có bit 1 ngầm định ở phần đầu của mantissa
        mantissa = 1
        for i, bit in enumerate(fraction_bits):
            mantissa += int(bit) * 2 ** -(i + 1)

    result = (-1) ** sign_bit * mantissa * 2 ** exponent
    return result


def main():
    try:
        binary_str = input("Nhập chuỗi nhị phân 32-bit biểu diễn số floating point (IEEE 754): ")
        result = ieee754_to_float(binary_str)
        print(f"Số thực tương ứng: {result}")
    except ValueError as e:
        print(f"Lỗi: {e}")


if __name__ == "__main__":
    main()
