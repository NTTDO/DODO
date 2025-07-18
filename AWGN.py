import numpy as np
import float_to_float_point
import hex_to_bin
# Thiết lập thông số
SNRdB = 10               # SNR theo dB cong suat tin hieu / cong suat nhieu
SNR = 10**(SNRdB/10)      # SNR dạng tuyến tính
Es = 10                   # Công suất tín hiệu Es , năng lượng trung bình mỗi symbol

# Đặt random seed để tái lập kết quả
np.random.seed(1)

real_noise = np.random.randn(64)
imag_noise = np.random.randn(64)
awgn_output = (real_noise + 1j*imag_noise) * np.sqrt((Es/SNR)/2)
print('REAL')
for k in range(64):
    print(f'{awgn_output[k].real}')

print('----------')
print('IMAG')
for k in range(64):
    print(f'{awgn_output[k].imag}')
print('----------')
# In từng mẫu ra màn hình
print('REAL_HEX')
for k in range(64):
    print(f'{hex_to_bin.bin_to_hex(float_to_float_point.float_to_ieee754(awgn_output[k].real))}')

print('----------')
print('IMAG_HEX')
for k in range(64):
    print(f'{hex_to_bin.bin_to_hex(float_to_float_point.float_to_ieee754(awgn_output[k].imag))}')