import random

# Tạo số ngẫu nhiên 192-bit
num = random.getrandbits(192)

# Chuyển sang chuỗi nhị phân, thêm số 0 phía trước nếu thiếu
binary_str = bin(num)[2:].zfill(192)

print(f"Số 192-bit ngẫu nhiên (binary):\n{binary_str}")
print(f"Hex: {hex(num)}")