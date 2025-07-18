x = 0
for i in range(63, 0, -1):
    print(f"data_real_out_temp[{32*i-1} : {32*i-32}] <= data_real_out[{32*(63-i)+31}:{32*(63-i)}];")
    x += 1
