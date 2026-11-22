# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

SEG_PATTERNS = {
    0: 0b0111111,
    1: 0b0000110,
    2: 0b1011011,
    3: 0b1001111,
    4: 0b1100110,
    5: 0b1101101,
    6: 0b1111101,
    7: 0b0000111,
    8: 0b1111111,
    9: 0b1101111,
}


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)

    # Should start at 9 with done_zero = 0
    assert int(dut.uo_out.value) & 0x7F == SEG_PATTERNS[9]
    assert (int(dut.uo_out.value) >> 7) & 0x1 == 0

    # Enable countdown from 9 down to 0
    dut._log.info("Test countdown 9 -> 0")
    dut.ui_in.value = 1
    for expected_digit in range(8, -1, -1):
        await ClockCycles(dut.clk, 1)
        uo = int(dut.uo_out.value)
        seg = uo & 0x7F
        done_zero = (uo >> 7) & 0x1
        assert seg == SEG_PATTERNS[expected_digit], (
            f"Expected digit {expected_digit} ({SEG_PATTERNS[expected_digit]:#09b}), got {seg:#09b}"
        )
        assert done_zero == (1 if expected_digit == 0 else 0)

    # Stay at 0 on subsequent clock cycles while enabled
    await ClockCycles(dut.clk, 2)
    uo = int(dut.uo_out.value)
    assert (uo & 0x7F) == SEG_PATTERNS[0]
    assert ((uo >> 7) & 0x1) == 1
