def chordal_a(base_freq: float) -> list:
    return [("Base", base_freq),
            ("3m", base_freq * 6 / 5),
            ("3M", base_freq * 5 / 4),
            ("5J", base_freq * 3 / 2),
            ("6m", base_freq * 8 / 5),
            ("6M", base_freq * 5 / 3),
            ("7m", base_freq * 7 / 4),
            ]


def chord_b_gen(base_freq: float) -> list:
    target = base_freq * 64
    freq_list = [base_freq]
    operations = [5/4,    # M3
                  3/2,    # m3
                  81/48    # M2
                  ]
    op_idx = 0
    total_factor = 1
    base_factor = 1
    cycles = 0
    while cycles < 24:
        print(total_factor, freq_list[-1])
        total_factor = base_factor * operations[op_idx]
        next_freq = operations[op_idx] * base_freq
        freq_list.append(next_freq)
        cycles += 1
        op_idx += 1
        if op_idx >= len(operations):
            op_idx = 0
            base_freq = freq_list[-1]
            base_factor = total_factor
    print(total_factor, freq_list[-1])
    return freq_list


if __name__ == "__main__":
    # base_value = 1864.6666
    # chordal_values = chordal_a(base_value)
    # for name, freq in chordal_values:
    #    print(f"{name}: {freq: <5.5f}")
    for freq in chord_b_gen(49):
        print(f"{freq: <2.2f}, ", end="")

