// Synchronous FIFO Design

// A FIFO(Fist In First Out) is a memory storage device that acts like a buffer in between two modules.
// It is also known as a Circular Queue(because the first element that comes in is the first to go out, and the pointers wrap around once the FIFO is full).
// FIFO Depth refers to the no. of data elements it can store and Data Width is the size of each data it receives. Here the depth has to be a power of 2 for the wrap bit full/ empty scheme to work
// In modern processors, there can be many sub modules and they need to communicate(transfer data) with each other.
// The one which sends the data is called a "Producer" and the one which receives it is called a "Consumer".
// A synchronous FIFO is used when both the producer and consumer operate at the same clock frequency(rd_clk == wr_clk).
// As the data is released in bursts, we need a temporary buffer in between, that ensures no data is lost.
// This module consists of three sections : write module, fifo memory and read module.
// The write module writes data into the FIFO memory when the write enable signal is asserted and the FIFO is not full(it cannot write the data further once the FIFO is full).
// The read module reads data from the FIFO memory when the read enable signal is asserted and the FIFO is not empty(it cannot read anything if the FIFO is empty)
// It's good to note that this is a standard FIFO(data_out is registered, one cycle delay) -> The other being FWFT, First-Word Fall Through(combinational data_out, data is direclty available, no delay of one clk cycle) 
// The write pointer points to the location in the FIFO memory where the next write happens("next" indicates the upcoming posedge of clk).
// The read pointer points to the location in the FIFO memory where the next read happens.
// The full and empty signals are asserted by comparing the read and write pointers.
// We have an extra wrap bit in the pointer which is used for checking if the pointer as wrapped around(after reaching it's maximum value).
// If the wrap bits are different, it means the one of the pointer has come all the way back to the other pointer(which is still at the same place) -> this means the FIFO is full.
// If both pointers are equal, including the wrap bit, then one of the pointer has catched up the other -> this means the FIFO is empty, just think of these two conditions, you'll get it :) 


module sync_fifo #(parameter DATA_WIDTH = 8,
    FIFO_DEPTH = 8) (
    input clk,
    input wr_en,
    input rd_en,
    input rst_n,
    input [DATA_WIDTH-1 : 0] data_in,
    output reg [DATA_WIDTH-1 : 0] data_out,
    output full,
    output empty);

    // a local parameter for defining the width of pointers
    localparam PTR_WIDTH = $clog2(FIFO_DEPTH);

    // fifo memory
    reg [DATA_WIDTH-1 : 0] fifo_mem [0 : FIFO_DEPTH-1];

    // read and write pointers, note that these two have an extra bit(MSB), which is used for differentiating full and empty conditions
    reg [PTR_WIDTH : 0] wr_ptr;
    reg [PTR_WIDTH : 0] rd_ptr;

    // checking full and empty conditions(the MSB detects if the pointer has wrapped around)
    assign full = (wr_ptr[PTR_WIDTH] != rd_ptr[PTR_WIDTH]) &&
                    (wr_ptr[PTR_WIDTH-1 : 0] == rd_ptr[PTR_WIDTH-1 :0]);
    assign empty = (wr_ptr == rd_ptr);

    // write module(that which writes data into the fifo)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr <= 0;
        end
        else if(wr_en && !full) begin
            fifo_mem[wr_ptr[PTR_WIDTH-1 : 0]] <= data_in;
            wr_ptr <= wr_ptr + 1'b1;
        end
    end

    // read module(that which reads data from the fifo)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_ptr <= 0;
            data_out <= 0;
        end
        else if(rd_en && !empty) begin
            data_out <= fifo_mem[rd_ptr[PTR_WIDTH-1 : 0]];   // this introduces a single cycle delay(as it is registered), if you don't want that, you can use a FWFT FIFO : just assign data_out combinationally -> assign data_out  = fifo_mem[rd_ptr[PTR_WIDTH-1 : 0]]; the notion of rd_en changes, now it is the consumer saying the data was read, and the next one can be shown
            rd_ptr <= rd_ptr + 1'b1;
        end
    end

endmodule
