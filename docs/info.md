## How it works

This project implements a 1-digit countdown timer from 9 to 0 for Tiny Tapeout. When reset (`rst_n` low) is released, the counter starts at 9 and decrements by 1 on each rising clock edge while `ui[0]` (`enable`) is high until reaching 0. The current digit is decoded to a 7-segment display pattern on `uo[6:0]`, and `uo[7]` (`done_zero`) asserts high when the counter reaches 0.

## How to test

Drive `rst_n` low to reset the counter to 9, then set `rst_n` high and assert `ui[0]` (`enable`) high across clock cycles. Observe the 7-segment outputs on `uo[6:0]` stepping down to 0 and verify `uo[7]` (`done_zero`) turns high when the count reaches 0.
