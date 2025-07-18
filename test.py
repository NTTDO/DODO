import numpy as np
import matplotlib.pyplot as plt

# Bản đồ 64-QAM (Gray Mapping)
# Mapping 64-QAM theo Gray code
qam_64_gray_map = {
    format(i, '06b'): (2 * (i % 8) - 7, 2 * (i // 8) - 7) for i in range(64)
}

# Chuyển sang số phức (complex)
qam_64_gray_map_complex = {k: complex(*v) for k, v in qam_64_gray_map.items()}

# In thử để kiểm tra
for bits, symbol in qam_64_gray_map_complex.items():
    print(f"{bits}: {symbol}")

# Hàm AWGN
def add_awgn_noise(signal, snr_dB):
    signal_power = np.mean(np.abs(signal)**2)  # Công suất tín hiệu
    snr_linear = 10**(snr_dB / 10)
    noise_power = signal_power / snr_linear
    noise = np.sqrt(noise_power) * (np.random.normal(0, 1, signal.shape) +
                                    1j * np.random.normal(0, 1, signal.shape))
    return signal + noise

# Hàm tính BER
def calculate_ber(bits_tx, bits_rx):
    errors = np.sum(np.array(bits_tx) != np.array(bits_rx))
    return errors / len(bits_tx)

# Số lượng OFDM symbols
num_symbols = 64
cp_len = 16  # Độ dài Cyclic Prefix
snr_dB_values = np.arange(0, 21, 2)  # SNR từ 0 đến 20 dB

ber_results = []

for snr_dB in snr_dB_values:
    # Bước 1: Tạo bit ngẫu nhiên và điều chế QAM-64
    bit_strings = [format(np.random.randint(0, 64), '06b') for _ in range(num_symbols)]
    qam_symbols = np.array([qam_64_gray_map_complex[bits] for bits in bit_strings])

    # Bước 2: IFFT để tạo tín hiệu OFDM
    ofdm_signal = np.fft.ifft(qam_symbols) * np.sqrt(64)  # Chuẩn hóa công suất

    # Bước 3: Thêm CP
    cp = ofdm_signal[-cp_len:]
    ofdm_tx = np.concatenate([cp, ofdm_signal])

    # Bước 4: Truyền qua kênh AWGN
    ofdm_rx = add_awgn_noise(ofdm_tx, snr_dB)

    # Bước 5: Bỏ CP và thực hiện FFT
    ofdm_rx_no_cp = ofdm_rx[cp_len:]
    qam_symbols_rx = np.fft.fft(ofdm_rx_no_cp) / np.sqrt(64)

    # Giải mã 64-QAM
    bit_strings_rx = []
    for symbol in qam_symbols_rx:
        min_dist = float('inf')
        closest_bits = None
        for bits, constellation in qam_64_gray_map_complex.items():
            dist = np.abs(symbol - constellation)
            if dist < min_dist:
                min_dist = dist
                closest_bits = bits
        bit_strings_rx.append(closest_bits)

    # Tính BER
    ber = calculate_ber(bit_strings, bit_strings_rx)
    ber_results.append(ber)
    print(f"SNR = {snr_dB} dB, BER = {ber:.6f}")

# Vẽ đồ thị BER
plt.figure(figsize=(8, 5))
plt.semilogy(snr_dB_values, ber_results, marker='o', linestyle='-')
plt.xlabel("SNR (dB)")
plt.ylabel("BER")
plt.title("OFDM-64 với nhiễu AWGN")
plt.grid(True, which='both')
plt.show()
