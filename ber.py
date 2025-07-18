def count_bit_difference_hex(hex1, hex2):
    """
    Đếm số bit khác nhau giữa hai chuỗi hex.
    Nếu hai chuỗi có độ dài khác nhau, sẽ tự động thêm '0' ở đầu chuỗi ngắn hơn.
    """
    # Đảm bảo độ dài hai chuỗi bằng nhau
    max_len = max(len(hex1), len(hex2))
    hex1 = hex1.zfill(max_len)
    hex2 = hex2.zfill(max_len)

    # Chuyển thành số nguyên
    n1 = int(hex1, 16)
    n2 = int(hex2, 16)

    # XOR để tìm các bit khác nhau
    xor_result = n1 ^ n2

    # Đếm số bit '1' trong kết quả XOR (mỗi bit 1 là 1 vị trí khác nhau)
    return bin(xor_result).count('1')
