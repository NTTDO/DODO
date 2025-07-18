import struct


def float_to_ieee754(num):

    packed = struct.pack('!f', num)
    integer_rep = int.from_bytes(packed, byteorder='big')
    binary_str = format(integer_rep, '032b')
    return binary_str

def main():
    try:
        num = float(input("Nhập số thực: "))
        binary_str = float_to_ieee754(num)
        print(f"Chuỗi nhị phân IEEE 754: {binary_str}")
    except ValueError:
        print("Vui lòng nhập một số thực hợp lệ.")


if __name__ == "__main__":
    main()
