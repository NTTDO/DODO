import math
import cmath
def dft_2_point (data_0,data_1,W):
    result_0 = data_0 + data_1*W
    result_1 = data_0 - data_1*W
    return result_0,result_1

x0,x1 = dft_2_point(3-1j,7-5j,1)
print(f"x0 = {x0} and x1 = {x1}")