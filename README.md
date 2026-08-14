# Parameterized Synchronous FIFO Buffer Design

A fully parameterizable **Synchronous First-In-First-Out (FIFO)** memory buffer implemented in Verilog HDL. This module provides efficient data buffering and rate-matching between modules operating within the same clock domain (`wr_clk == rd_clk`).

---

## Architecture & Design Highlights

* **Parameterized Configuration:** Configurable data payload width via `DATA_WIDTH` (Default: `8`) and storage capacity via `FIFO_DEPTH` (Default: `8`).
* **Wrap-Bit Pointer Scheme:** Utilizes an extra Most Significant Bit (MSB) in read and write pointers (`PTR_WIDTH = $clog2(FIFO_DEPTH)`). This eliminates the need for an explicit element counter register to track status flags:
  * **Empty Condition:** `wr_ptr == rd_ptr` (Both memory address pointers and wrap bits are identical).
  * **Full Condition:** Memory address pointers match (`wr_ptr[PTR_WIDTH-1:0] == rd_ptr[PTR_WIDTH-1:0]`) while MSB wrap bits differ (`wr_ptr[PTR_WIDTH] != rd_ptr[PTR_WIDTH]`).
* **Standard FIFO Interface:** Features a 1-cycle latency registered output (`data_out`) to isolate memory access paths and prevent long combinational delay propagation.
* **Underflow & Overflow Protection:** Guarded write (`wr_en && !full`) and read (`rd_en && !empty`) execution paths prevent memory corruption.

---

## Signal Description

| Signal Name  | Direction | Width        | Description                                           |
| :----------- | :-------- | :----------- | :---------------------------------------------------- |
| `clk`        | Input     | `1`          | System Clock Signal                                   |
| `rst_n`      | Input     | `1`          | Active-Low Asynchronous Reset                         |
| `wr_en`      | Input     | `1`          | Write Enable / Push Signal                            |
| `rd_en`      | Input     | `1`          | Read Enable / Pop Signal                              |
| `data_in`    | Input     | `DATA_WIDTH` | Data Input                                            |
| `data_out`   | Output    | `DATA_WIDTH` | Data Output (1-cycle registered latency)              |
| `full`       | Output    | `1`          | High when FIFO memory is completely filled            |
| `empty`      | Output    | `1`          | High when FIFO memory contains no valid data          |

---

## Parameter Settings

| Parameter    | Default Value | Description                                                    |
| :----------- | :------------ | :------------------------------------------------------------- |
| `DATA_WIDTH` | `8`           | Bit-width of each stored data word                             |
| `FIFO_DEPTH` | `8`           | Number of words the FIFO can hold (Must be a power of 2)       |

---

## Key Notes

1. **Standard vs. FWFT (First-Word Fall-Through):**
   * **Standard FIFO (Current):** Data becomes available on `data_out` one clock cycle **after** `rd_en` is asserted.
   * **FWFT FIFO:** Can be achieved by combinational memory read assignment (`assign data_out = fifo_mem[rd_ptr[PTR_WIDTH-1:0]]`), where `rd_en` serves purely as an explicit pop signal to advance the read pointer.
2. **ASIC Synthesis & RAM Inference:**
   * The array structure `fifo_mem` is deliberately left uninitialized on reset. Leaving memory arrays out of asynchronous reset logic enables synthesis tools to infer efficient Block RAM / Memory Macros instead of instantiating individual D-Flip-Flops.
3. **Simultaneous Read/Write Operations:**
   * When both `wr_en` and `rd_en` are asserted simultaneously on a non-empty, non-full FIFO, data is written and read in parallel, maintaining stable pointer spacing.
