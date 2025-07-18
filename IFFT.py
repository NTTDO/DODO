import numpy as np
from DFT_2 import dft_2_point
import state_result_ifft



def IFFT_64(line,w):
    print("RESULT_STATE_ONE")
    result_one = state_result_ifft.state_result_one(line,w[0])
    #for i,val in enumerate(result_one):
    # print(f"line_state_1[{i}]={val.real:.13f} + {val.imag:.13f}j")

    print("RESULT_STATE_TWO")
    result_two = state_result_ifft.state_result_two(result_one,w)
    #for i,val in enumerate(result_two):
    #  print(f"line_state_2[{i}]={val.real:.13f} + {val.imag:.13f}j")

    print("RESULT_STATE_THREE")
    result_three = state_result_ifft.state_result_three(result_two,w)
    #for i,val in enumerate(result_three):
    #   print(f"line_state_3[{i}]={val.real:.13f} + {val.imag:.13f}j")

    print("RESULT_STATE_FOUR")
    result_four = state_result_ifft.state_result_four(result_three,w)
    #for i,val in enumerate(result_four):
#    print(f"line_state_4[{i}]={val.real:.13f} + {val.imag:.13f}j")

    print("RESULT_STATE_FIVE")
    result_five = state_result_ifft.state_result_five(result_four,w)
    #for i,val in enumerate(result_five):
#    print(f"line_state_5[{i}]={val.real:.13f} + {val.imag:.13f}j")

    print("RESULT_STATE_SIX")
    result_six = state_result_ifft.state_result_six(result_five,w)
    #for i,val in enumerate(result_six):
    return result_six