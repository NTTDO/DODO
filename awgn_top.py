import numpy as np
import float_to_float_point
import hex_to_bin


def add_awgn_to_ifft(output_ifft, SNRdB=40, Es=10, seed=1):
    """
    Hàm cộng nhiễu AWGN với output IFFT

    Parameters:
        output_ifft : list hoặc numpy array các giá trị complex từ IFFT (length = 64)
        SNRdB : Signal-to-Noise Ratio in dB
        Es : Năng lượng trung bình mỗi symbol
        seed : seed cho np.random để tái lập

    Returns:
        noisy_output : numpy array complex (output_ifft + noise)
        hex_real : list chứa chuỗi HEX 32 bit của phần thực
        hex_imag : list chứa chuỗi HEX 32 bit của phần ảo
    """
    np.random.seed(seed)

    SNR = 10 ** (SNRdB / 10)
    noise_std = np.sqrt((Es / SNR) / 2)

    # Tạo nhiễu AWGN (64 mẫu complex)
    real_noise = np.random.randn(64)
    imag_noise = np.random.randn(64)
    awgn_noise = (real_noise + 1j * imag_noise) * noise_std

    # Cộng nhiễu vào output_ifft
    output_ifft = np.array(output_ifft)
    noisy_output = output_ifft + awgn_noise

    # In dạng float
    print('REAL:')
    for val in noisy_output:
        print(val.real)

    print('----------')
    print('IMAG:')
    for val in noisy_output:
        print(val.imag)

    # Chuyển sang định dạng HEX (IEEE 754)
    print('----------')
    print('REAL_HEX:')
    hex_real = []
    for val in noisy_output:
        hex_val = hex_to_bin.bin_to_hex(float_to_float_point.float_to_ieee754(val.real))
        hex_real.append(hex_val)
        print(hex_val)

    print('----------')
    print('IMAG_HEX:')
    hex_imag = []
    for val in noisy_output:
        hex_val = hex_to_bin.bin_to_hex(float_to_float_point.float_to_ieee754(val.imag))
        hex_imag.append(hex_val)
        print(hex_val)

        # Chuyển sang định dạng HEX (IEEE 754)
        print('----------')
        print('REAL_HEX_AWGN:')
        hex_real = []
        for val in awgn_noise:
            hex_val = hex_to_bin.bin_to_hex(float_to_float_point.float_to_ieee754(val.real))
            hex_real.append(hex_val)
            print(hex_val)

        print('----------')
        print('IMAG_HEX_AWGN:')
        hex_imag = []
        for val in awgn_noise:
            hex_val = hex_to_bin.bin_to_hex(float_to_float_point.float_to_ieee754(val.imag))
            hex_imag.append(hex_val)
            print(hex_val)










    return noisy_output, hex_real, hex_imag
