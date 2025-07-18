def convolutional_encode(data):
    """
    Convolutional encoder (rate 1/2, K=3, G1=111 (7), G2=101 (5))
    """
    data_in = data[::-1]
    g1 = 0b111
    g2 = 0b101
    shift_reg = 0
    encoded = []
    for bit in data_in:
        shift_reg = ((shift_reg << 1) | bit) & 0b111  # keep last 3 bits
        out1 = bin(shift_reg & g1).count('1') % 2
        out2 = bin(shift_reg & g2).count('1') % 2
        encoded.extend([out1, out2])
    data_encoded = encoded[::-1]
    return data_encoded




def viterbi_decode(encoded):
    """
    Viterbi decoder for rate 1/2 convolutional code with G1=111, G2=101
    """
    data_in = encoded[::-1]
    n = 2  # number of output bits per input bit
    k = 3  # constraint length
    num_states = 2 ** (k - 1)

    # Transition table: (next_state, output_bits)
    transitions = {}
    for state in range(num_states):
        for bit in [0, 1]:
            shift_reg = ((state << 1) | bit) & 0b111
            out1 = bin(shift_reg & 0b111).count('1') % 2
            out2 = bin(shift_reg & 0b101).count('1') % 2
            next_state = shift_reg & 0b11  # only keep last 2 bits
            transitions[(state, bit)] = (next_state, [out1, out2])

    # Trellis initialization
    path_metrics = [float('inf')] * num_states
    path_metrics[0] = 0
    paths = {s: [] for s in range(num_states)}

    # Process encoded bits in chunks of 2
    for i in range(0, len(data_in), 2):
        received = data_in[i:i + 2]
        new_metrics = [float('inf')] * num_states
        new_paths = {s: [] for s in range(num_states)}

        for state in range(num_states):
            if path_metrics[state] < float('inf'):
                for bit in [0, 1]:
                    next_state, expected = transitions[(state, bit)]
                    # Hamming distance
                    dist = sum([a ^ b for a, b in zip(received, expected)])
                    metric = path_metrics[state] + dist
                    if metric < new_metrics[next_state]:
                        new_metrics[next_state] = metric
                        new_paths[next_state] = paths[state] + [bit]

        path_metrics = new_metrics
        paths = new_paths


    best_state = path_metrics.index(min(path_metrics))
    viterbi_data = paths[best_state][::-1]
    return viterbi_data

import random


def hex_to_bit_list(hex_str, total_bits=192):
    """Chuyển chuỗi hex thành danh sách bit (list of int) đủ `total_bits`."""
    bit_str = bin(int(hex_str, 16))[2:].zfill(total_bits)
    return [int(b) for b in bit_str]
# ==== Mã hóa & Giải mã từng khối 8-bit ====

def decode_to_hex(encoded_stream):
    chunks = [encoded_stream[i:i+16] for i in range(0, len(encoded_stream), 16)]

    recovered_bits = ""

    for chunk in chunks:
        decoded_block = viterbi_decode(chunk)
        recovered_bits += ''.join(map(str, decoded_block))

    return recovered_bits, bin_to_hex(recovered_bits)

def encode_hex_string(hex_str):
    bit_list = hex_to_bit_list(hex_str)
    chunks = [bit_list[i:i+8] for i in range(0, len(bit_list), 8)]

    encoded_stream = []

    for chunk in chunks:
        block = [int(b) for b in chunk]
        encoded_block = convolutional_encode(block)
        encoded_stream.extend(encoded_block)

    return encoded_stream
def bin_to_hex(bin_str):
    # Bổ sung thêm các số 0 ở đầu nếu độ dài không chia hết cho 4
    pad_len = (4 - len(bin_str) % 4) % 4
    bin_str = '0' * pad_len + bin_str
    return hex(int(bin_str, 2))[2:]  # Bỏ '0x' đầu


hex_str = "ad0ba8a5a29d94746f6e6bfcdd82e5867d164cd5f04ab604"  # chuỗi hex có 6 ký tự = 24 bits
encoded = encode_hex_string(hex_str)
print("Encoded bits:", encoded)
recovered_bits, recovered_hex = decode_to_hex(encoded)
print("Recovered hex:", recovered_hex)

