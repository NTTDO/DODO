import numpy as np
import matplotlib.pyplot as plt

# Nhập chuỗi bit từ người dùng
string = input("Nhập chuỗi bit (vd: 10110000...): ")
string = str(string)

# Khởi tạo
strOutput = []
strOutputLabel = []

def hdb3_output():
    contador = 0              # đếm số bit 0 liên tiếp
    pulsoAnterior = 0         # giá trị xung trước (+1 hoặc -1)
    so_bit_1_tu_vipham = 0    # đếm số bit 1 kể từ lần vi phạm trước
    pulsoViolacion = 0        # giá trị xung vi phạm

    for bit in string:
        if bit == '1':
            # Đảo dấu
            if pulsoAnterior == 1:
                strOutput.append(-1)
                strOutputLabel.append(-1)
                pulsoAnterior = -1
            else:
                strOutput.append(1)
                strOutputLabel.append(1)
                pulsoAnterior = 1

            so_bit_1_tu_vipham += 1
            contador = 0

        elif bit == '0':
            contador += 1
            strOutput.append(0)
            strOutputLabel.append(0)

            if contador == 4:
                # Xóa 4 số 0 vừa thêm
                for _ in range(4):
                    strOutput.pop()
                    strOutputLabel.pop()

                if so_bit_1_tu_vipham % 2 == 0:
                    # Chèn B00V
                    pulsoViolacion = -pulsoAnterior if pulsoAnterior != 0 else 1
                    strOutput.extend([pulsoViolacion, 0, 0, pulsoViolacion])
                    strOutputLabel.extend(['B', 0, 0, 'V'])
                    pulsoAnterior = pulsoViolacion
                else:
                    # Chèn 000V
                    strOutput.extend([0, 0, 0, pulsoAnterior])
                    strOutputLabel.extend([0, 0, 0, 'V'])

                so_bit_1_tu_vipham = 0
                contador = 0

# Gọi hàm mã hóa
hdb3_output()

# Vẽ đồ thị
x = np.arange(1, len(strOutput) + 1, 1)

plt.step(x, strOutput, where='post')
plt.ylim(-1.5, 1.5)
plt.xlim(0, len(strOutput)+1)
plt.title('HDB3 Encoding')
plt.xlabel('Bit Position')
plt.ylabel('Signal Level')

# Hiển thị nhãn từng điểm dưới trục x
plt.xticks(x, strOutputLabel, rotation=90)

plt.grid(True)
plt.tight_layout()
plt.show()
