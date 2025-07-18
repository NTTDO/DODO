import math
import cmath
import  numpy as np
import float_to_float_point

np.set_printoptions(suppress=True) #bo e
# W hằng số
N = 64
kn = np.arange(32)
w = np.cos(-2 * np.pi * kn / N) + 1j * np.sin(-2 * np.pi * kn / N)

for i, val in enumerate(w):
    print(f"w_real[{i}] = 32'b{float_to_float_point.float_to_ieee754(val.real)};//{val.real}")
    #print(f"parameter w_imag_{i} = 32'b{float_to_float_point.float_to_ieee754(val.imag)};//{val.imag}")

for i, val in enumerate(w):
    print(f"w_imag[{i}] = 32'b{float_to_float_point.float_to_ieee754(val.imag)};//{val.imag}")