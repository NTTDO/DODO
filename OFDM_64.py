import IFFT
import FFT
import  numpy as np
import float_to_float_point
import float_point_to_float
import bin_to_hex
import bin_to_hex_2
import convolutioncode as cc
import awgn_top
import math
import cmath
import matplotlib.pyplot as plt
import numpy as np
import ber
def deqam_qam64(quantized_symbols):

    reverse_map = {v: k for k, v in qam_64_gray_map.items()}

    bitstream = []
    for sym in quantized_symbols:
        i, q = int(sym.real), int(sym.imag)
        bit = reverse_map.get((i, q))
        if bit is None:
            raise ValueError(f"Symbol ({i},{q}) không tồn tại trong QAM-64 map")
        bitstream.append(bit)

    return bitstream
# Tập các mốc QAM bạn muốn lượng tử hóa về
qam_levels = np.array([-7, -5, -3, -1, 1, 3, 5, 7])

def quantize_to_nearest_qam(complex_array):
    quantized = []
    for z in complex_array:
        real_part = z.real
        imag_part = z.imag

        # Làm tròn từng phần thực và ảo về mốc gần nhất
        real_q = qam_levels[np.argmin(np.abs(qam_levels - real_part))]
        imag_q = qam_levels[np.argmin(np.abs(qam_levels - imag_part))]

        quantized.append(complex(real_q, imag_q))

    return np.array(quantized)

np.set_printoptions(suppress=True) #bo e
# W hằng số
N = 64
kn = np.arange(32)
w = np.cos(-2 * np.pi * kn / N) + 1j * np.sin(-2 * np.pi * kn / N)

for i, val in enumerate(w):
    print(f"w[{i}] = {val.real:.13f} + {val.imag:.13f}j")

hex_str = "a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1"  # hex string input

# Mã hóa
encoded_data = cc.encode_hex_string(hex_str)

print("🔐 Encoded HEX:", cc.bin_to_hex(''.join(str(bit) for bit in encoded_data)))

bit_array = np.array(encoded_data)

# Chia thành các nhóm 6 bit
bit_groups = bit_array.reshape(-1, 6)

# Chuyển từng nhóm thành chuỗi nhị phân
bit_strings = [''.join(str(b) for b in bits) for bits in bit_groups]

# In ra danh sách bit_strings để kiểm tra
print("🧮 Bit strings (nhóm 6 bit):")
for i, bstr in enumerate(bit_strings):
    print(f"{i:02d}: {bstr}")
qam_64_gray_map = {
    '000000': (-7, 7), '000001': (-5, 7), '000011': (-3, 7), '000010': (-1, 7),
    '000110': (1, 7), '000111': (3, 7), '000101': (5, 7), '000100': (7, 7),
    '001100': (7, 5), '001101': (5, 5), '001111': (3, 5), '001110': (1, 5),
    '001010': (-1, 5), '001011': (-3, 5), '001001': (-5, 5), '001000': (-7, 5),
    '011000': (-7, 3), '011001': (-5, 3), '011011': (-3, 3), '011010': (-1, 3),
    '011110': (1, 3), '011111': (3, 3), '011101': (5, 3), '011100': (7, 3),
    '010100': (7, 1), '010101': (5, 1), '010111': (3, 1), '010110': (1, 1),
    '010010': (-1, 1), '010011': (-3, 1), '010001': (-5, 1), '010000': (-7, 1),
    '110000': (-7, -1), '110001': (-5, -1), '110011': (-3, -1), '110010': (-1, -1),
    '110110': (1, -1), '110111': (3, -1), '110101': (5, -1), '110100': (7, -1),
    '111100': (7, -3), '111101': (5, -3), '111111': (3, -3), '111110': (1, -3),
    '111010': (-1, -3), '111011': (-3, -3), '111001': (-5, -3), '111000': (-7, -3),
    '101000': (-7, -5), '101001': (-5, -5), '101011': (-3, -5), '101010': (-1, -5),
    '101110': (1, -5), '101111': (3, -5), '101101': (5, -5), '101100': (7, -5),
    '100100': (7, -7), '100101': (5, -7), '100111': (3, -7), '100110': (1, -7),
    '100010': (-1, -7), '100011': (-3, -7), '100001': (-5, -7), '100000': (-7, -7)
}
qam_64_gray_map_complex = {k: complex(*v) for k, v in qam_64_gray_map.items()}
# Lấy 64 ký hiệu từ bit random
qam_symbols = [qam_64_gray_map_complex[bits] for bits in bit_strings]

real_bin = [float_to_float_point.float_to_ieee754(sym.real) for sym in qam_symbols]
imag_bin = [float_to_float_point.float_to_ieee754(sym.imag) for sym in qam_symbols]

for i, (real, imag) in enumerate(zip(real_bin, imag_bin)):
    print(f"Symbol {i}:")
    print(f"  Real Binary: {real} (Length: {len(real)})")
    print(f"  Imaginary Binary: {imag} (Length: {len(imag)})")
# Ghép nối tất cả bit lại với nhau theo thứ tự
bitstream_real = ''.join(real_bin)
bitstream_imag = ''.join(imag_bin)

# Chuyển đổi sang HEX
hex_real = bin_to_hex_2.binary_to_hex(bitstream_real)
hex_imag = bin_to_hex_2.binary_to_hex(bitstream_imag)

print(f"Chuỗi HEX phần thực: {hex_real}")
print(f"Chuỗi HEX phần ảo: {hex_imag}")


# In 64 giá trị ra màn hình
for i, val in enumerate(qam_symbols):
    print(f"Symbol {i}: {val} (Real: {val.real}, Imag: {val.imag})")





#--------ifft
output_ifft = IFFT.IFFT_64(qam_symbols,w)
#for i,val in enumerate(output_ifft):
#    print(f"IFFT_line[{i}] = {val.real:.13f}  +  {val.imag:.13f}j")
output_ifft = np.array(output_ifft) / 64
for i,val in enumerate(output_ifft):
    real_temp =float_to_float_point.float_to_ieee754(val.real)
    imag_temp =float_to_float_point.float_to_ieee754(val.imag)
   # print(f"IFFT_line[{i}] = {val.real:.13f}  +  {val.imag:.13f}j")
   # print(f"Chuỗi nhị phân phần thực: {real_temp}")
  #  print(f"Chuỗi nhị phân phần ảo: {imag_temp}")
  #  print(f"Chuỗi hex phần thực: {bin_to_hex.binary_to_hex(real_temp)}")
  #  print(f"Chuỗi hex phần ảo: {bin_to_hex.binary_to_hex(imag_temp)}")

noisy_ifft, real_hex, imag_hex = awgn_top.add_awgn_to_ifft(output_ifft, SNRdB=30, seed=1)





output_fft = FFT.FFT_64((noisy_ifft),w)

output_fft[1:] = output_fft[:0:-1]
#output_fft = float_to_float_point.float_to_ieee754(output_fft)
for i,val in enumerate(output_fft):
    real_temp =float_to_float_point.float_to_ieee754(val.real)
    imag_temp =float_to_float_point.float_to_ieee754(val.imag)
    print(f"FFT_line[{i}] = {val.real:.13f}  +  {val.imag:.13f}j")

quantized_output = quantize_to_nearest_qam(output_fft)
for i, val in enumerate(quantized_output):
    print(f"Quantized_FFT_line[{i}] = {val.real:.1f}  +  {val.imag:.1f}j")
  #  print(f"Chuỗi nhị phân phần thực: {real_temp}")
  #  print(f"Chuỗi nhị phân phần ảo: {imag_temp}")
   # print(f"Chuỗi hex phần thực: {bin_to_hex.binary_to_hex(real_temp)}")
   # print(f"Chuỗi hex phần ảo: {bin_to_hex.binary_to_hex(imag_temp)}")

demodulated_bits = deqam_qam64(quantized_output)

for i, bits in enumerate(demodulated_bits):
    print(f"Symbol {i}: {bits}")

bitstream = ''.join(demodulated_bits)
print("🔹 ressult:", bitstream)



# Chuyển chuỗi bit thành list[int]
demodulated_bits = [int(b) for b in bitstream]

# Giải mã về dạng nhị phân và hex
recovered_bits, recovered_hex = cc.decode_to_hex(demodulated_bits)

print("🔸 Recovered hex:", recovered_hex)

check = ber.count_bit_difference_hex(recovered_hex,hex_str)
print(" tỉ số ber = ",check)