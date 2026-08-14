# Synchronous FIFO Buffer Design

A parameterizable synchronous First-In-First-Out (FIFO) memory buffer implemented in Verilog HDL. This module provides data buffering and rate-matching between modules operating on the same clock.

---

## Design Features

* **Configurable Parameters:** Custom data payload width (`DATA_WIDTH`) and memory depth (`FIFO_DEPTH`).
* **Wrap-Bit Pointer Scheme:** Uses an extra pointer bit (`PTR_WIDTH = $clog2(FIFO_DEPTH)`) to track status flags without needing a separate element counter:
  * **Empty:** `wr_ptr == rd_ptr`
  * **Full:** Address bits match (`wr_ptr[PTR_WIDTH-1:0] == rd_ptr[PTR_WIDTH-1:0]`) but wrap bits differ (`wr_ptr[PTR_WIDTH] != rd_ptr[PTR_WIDTH]`).
* **Standard Interface:** 1-cycle registered output delay to avoid long combinational paths.
* **Overflow & Underflow Guard:** Writes are blocked when full (`wr_en && !full`), and reads are blocked when empty (`rd_en && !empty`).

---

## Signal Description

| Signal | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | Input | `1` | System clock |
| `rst_n` | Input | `1` | Active-low asynchronous reset |
| `wr_en` | Input | `1` | Write enable signal |
| `rd_en` | Input | `1` | Read enable signal |
| `data_in` | Input | `DATA_WIDTH` | Input data payload |
| `data_out` | Output | `DATA_WIDTH` | Output data payload |
| `full` | Output | `1` | Asserted when FIFO is full |
| `empty` | Output | `1` | Asserted when FIFO is empty |

---

## Parameters

| Parameter | Default | Description |
| :--- | :--- | :--- |
| `DATA_WIDTH` | `8` | Bit width of each data word |
| `FIFO_DEPTH` | `8` | Total capacity in words (must be a power of 2) |

---

## Implementation Notes

1. **Standard vs. FWFT Mode:**
   * This is a **standard FIFO**, meaning data appears on `data_out` one cycle after `rd_en` is asserted.
   * To convert this into a **First-Word Fall-Through (FWFT)** FIFO, assign `data_out` combinationally from `fifo_mem[rd_ptr]`. In FWFT, `rd_en` acts purely as a pop signal to advance the pointer.

2. **ASIC Synthesis Optimization:**
   * Memory array `fifo_mem` is intentionally excluded from the reset block. This allows synthesis tools to map the array directly to efficient Block RAM macros instead of individual flip-flops.

3. **Simultaneous Read & Write:**
   * When `wr_en` and `rd_en` are both high at the same time (and FIFO is neither full nor empty), data is written and read concurrently without altering overall usage.


# View waveform
gtkwave dump.vcd
