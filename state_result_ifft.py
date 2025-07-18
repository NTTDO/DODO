import cmath
from DFT_2 import dft_2_point

def state_result_one (line,W):
    data_state = [0] * len(line)
    for i in range(32):
        data_state[i]=line[i]+line[i+32]*W
        data_state[i+32]=line[i]-line[i+32]*W
    return data_state

def state_result_two (line,W):
    data_state = [0] * len(line)
    for i in range(0,16):
        data_state[i]=line[i]+line[i+16]*W[0]
        data_state[i+16]=line[i]-line[i+16]*W[0]
    for i in range(32,48):
        data_state[i]=line[i]+line[i+16]*W[16]
        data_state[i+16]=line[i]-line[i+16]*W[16]
    return data_state

def state_result_three(line,W):
    data_state = [0] * len(line)
    for i in range(0,8):
        data_state[i]=line[i]+line[i+8]*W[0]
        data_state[i+8]=line[i]-line[i+8]*W[0]
    for i in range(16,24):
        data_state[i]=line[i]+line[i+8]*W[16]
        data_state[i+8]=line[i]-line[i+8]*W[16]
    for i in range(32,40):
        data_state[i]=line[i]+line[i+8]*W[8]
        data_state[i+8]=line[i]-line[i+8]*W[8]
    for i in range(48,56):
        data_state[i]=line[i]+line[i+8]*W[24]
        data_state[i+8]=line[i]-line[i+8]*W[24]
    return data_state

def state_result_four(line,W):
    data_state = [0] * len(line)
    for i in range(0,4):
        data_state[i]=line[i]+line[i+4]*W[0]
        data_state[i+4]=line[i]-line[i+4]*W[0]
    for i in range(8,12):
        data_state[i]=line[i]+line[i+4]*W[16]
        data_state[i+4]=line[i]-line[i+4]*W[16]
    for i in range(16,20):
        data_state[i]=line[i]+line[i+4]*W[8]
        data_state[i+4]=line[i]-line[i+4]*W[8]
    for i in range(24,28):
        data_state[i]=line[i]+line[i+4]*W[24]
        data_state[i+4]=line[i]-line[i+4]*W[24]
    for i in range(32,36):
        data_state[i]=line[i]+line[i+4]*W[4]
        data_state[i+4]=line[i]-line[i+4]*W[4]
    for i in range(40,44):
        data_state[i]=line[i]+line[i+4]*W[20]
        data_state[i+4]=line[i]-line[i+4]*W[20]
    for i in range(48,52):
        data_state[i]=line[i]+line[i+4]*W[12]
        data_state[i+4]=line[i]-line[i+4]*W[12]
    for i in range(56,60):
        data_state[i]=line[i]+line[i+4]*W[28]
        data_state[i+4]=line[i]-line[i+4]*W[28]
    return data_state

def state_result_five(line,W):
    data_state = [0] * len(line)
    for i in range(0,2):
        data_state[i]=line[i]+line[i+2]*W[0]
        data_state[i+2]=line[i]-line[i+2]*W[0]
    for i in range(4,6):
        data_state[i]=line[i]+line[i+2]*W[16]
        data_state[i+2]=line[i]-line[i+2]*W[16]
    for i in range(8,10):
        data_state[i]=line[i]+line[i+2]*W[8]
        data_state[i+2]=line[i]-line[i+2]*W[8]
    for i in range(12,14):
        data_state[i]=line[i]+line[i+2]*W[24]
        data_state[i+2]=line[i]-line[i+2]*W[24]
    for i in range(16,18):
        data_state[i]=line[i]+line[i+2]*W[4]
        data_state[i+2]=line[i]-line[i+2]*W[4]
    for i in range(20,22):
        data_state[i]=line[i]+line[i+2]*W[20]
        data_state[i+2]=line[i]-line[i+2]*W[20]
    for i in range(24,26):
        data_state[i]=line[i]+line[i+2]*W[12]
        data_state[i+2]=line[i]-line[i+2]*W[12]
    for i in range(28,30):
        data_state[i]=line[i]+line[i+2]*W[28]
        data_state[i+2]=line[i]-line[i+2]*W[28]
    for i in range(32,34):
        data_state[i]=line[i]+line[i+2]*W[2]
        data_state[i+2]=line[i]-line[i+2]*W[2]
    for i in range(36,38):
        data_state[i]=line[i]+line[i+2]*W[18]
        data_state[i+2]=line[i]-line[i+2]*W[18]
    for i in range(40,42):
        data_state[i]=line[i]+line[i+2]*W[10]
        data_state[i+2]=line[i]-line[i+2]*W[10]
    for i in range(44,46):
        data_state[i]=line[i]+line[i+2]*W[26]
        data_state[i+2]=line[i]-line[i+2]*W[26]
    for i in range(48,50):
        data_state[i]=line[i]+line[i+2]*W[6]
        data_state[i+2]=line[i]-line[i+2]*W[6]
    for i in range(52,54):
        data_state[i]=line[i]+line[i+2]*W[22]
        data_state[i+2]=line[i]-line[i+2]*W[22]
    for i in range(56,58):
        data_state[i]=line[i]+line[i+2]*W[14]
        data_state[i+2]=line[i]-line[i+2]*W[14]
    for i in range(60,62):
        data_state[i]=line[i]+line[i+2]*W[30]
        data_state[i+2]=line[i]-line[i+2]*W[30]
    return data_state

def state_result_six(line,W):
    data_state = [0] * len(line)

    data_state[0],data_state[1] = dft_2_point(line[0],line[1],W[0])
    data_state[2], data_state[3] = dft_2_point(line[2], line[3], W[16])
    data_state[4], data_state[5] = dft_2_point(line[4], line[5], W[8])
    data_state[6], data_state[7] = dft_2_point(line[6], line[7], W[24])
    data_state[8], data_state[9] = dft_2_point(line[8], line[9], W[4])
    data_state[10], data_state[11] = dft_2_point(line[10], line[11], W[20])
    data_state[12], data_state[13] = dft_2_point(line[12], line[13], W[12])
    data_state[14], data_state[15] = dft_2_point(line[14], line[15], W[28])
    data_state[16], data_state[17] = dft_2_point(line[16], line[17], W[2])
    data_state[18], data_state[19] = dft_2_point(line[18], line[19], W[18])
    data_state[20], data_state[21] = dft_2_point(line[20], line[21], W[10])
    data_state[22], data_state[23] = dft_2_point(line[22], line[23], W[26])
    data_state[24], data_state[25] = dft_2_point(line[24], line[25], W[6])
    data_state[26], data_state[27] = dft_2_point(line[26], line[27], W[22])
    data_state[28], data_state[29] = dft_2_point(line[28], line[29], W[14])
    data_state[30], data_state[31] = dft_2_point(line[30], line[31], W[30])
    data_state[32], data_state[33] = dft_2_point(line[32], line[33], W[1])
    data_state[34], data_state[35] = dft_2_point(line[34], line[35], W[17])
    data_state[36], data_state[37] = dft_2_point(line[36], line[37], W[9])
    data_state[38], data_state[39] = dft_2_point(line[38], line[39], W[25])
    data_state[40], data_state[41] = dft_2_point(line[40], line[41], W[5])
    data_state[42], data_state[43] = dft_2_point(line[42], line[43], W[21])
    data_state[44], data_state[45] = dft_2_point(line[44], line[45], W[13])
    data_state[46], data_state[47] = dft_2_point(line[46], line[47], W[29])
    data_state[48], data_state[49] = dft_2_point(line[48], line[49], W[3])
    data_state[50], data_state[51] = dft_2_point(line[50], line[51], W[19])
    data_state[52], data_state[53] = dft_2_point(line[52], line[53], W[11])
    data_state[54], data_state[55] = dft_2_point(line[54], line[55], W[27])
    data_state[56], data_state[57] = dft_2_point(line[56], line[57], W[7])
    data_state[58], data_state[59] = dft_2_point(line[58], line[59], W[23])
    data_state[60], data_state[61] = dft_2_point(line[60], line[61], W[15])
    data_state[62], data_state[63] = dft_2_point(line[62], line[63], W[31])
    return data_state