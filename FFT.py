import numpy as np
from DFT_2 import dft_2_point
import state_result_fft

def FFT_64(line,W):
    print("RESULT_STATE_ONE")
    result_one = state_result_fft.state_result_one(line, W)
    #for i, val in enumerate(result_one):
    #    print(f"line_state_1[{i}]={val.real:.13f} + {val.imag:.13f}j")

    print("RESULT_STATE_TWO")
    result_two = state_result_fft.state_result_two(result_one, W)
    #for i, val in enumerate(result_two):
    #    print(f"line_state_2[{i}]={val.real:.13f} + {val.imag:.13f}j")

    print("RESULT_STATE_THREE")
    result_three = state_result_fft.state_result_three(result_two, W)
    #for i, val in enumerate(result_three):
    #   print(f"line_state_3[{i}]={val.real:.13f} + {val.imag:.13f}j")

    print("RESULT_STATE_FOUR")
    result_four = state_result_fft.state_result_four(result_three, W)
    #for i, val in enumerate(result_four):
    #    print(f"line_state_4[{i}]={val.real:.13f} + {val.imag:.13f}j")

    print("RESULT_STATE_FIVE")
    result_five = state_result_fft.state_result_five(result_four, W)
    #for i, val in enumerate(result_five):
    #    print(f"line_state_5[{i}]={val.real:.13f} + {val.imag:.13f}j")

    print("RESULT_STATE_SIX")
    result_6 = state_result_fft.state_result_six(result_five, W)
    #for i, val in enumerate(result_6):
    #    print(f"line_state_6[{i}]={val.real:.13f} + {val.imag:.13f}j")

    return result_6