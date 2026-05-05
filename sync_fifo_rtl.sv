// =============================================================================
// Module    : sync_fifo
// Project   : FIFO Verification Project
// Author    : RTL Design Team
// Version   : 1.0
// Date      : 2026-05-05
//
// Description:
//   Synchronous FIFO with parameterizable depth and data width.
//   Supports standard push/pop interface with full/empty flags,
//   almost-full/almost-empty thresholds, and fill-level output.
//
// Parameters:
//   DATA_WIDTH      - Width of data bus (default: 8)
//   DEPTH           - Number of entries (must be power of 2, default: 16)
//   ALMOST_FULL_TH  - Almost-full threshold (default: 14)
//   ALMOST_EMPTY_TH - Almost-empty threshold (default: 2)
// =============================================================================

module sync_fifo #(
    parameter int DATA_WIDTH      = 8,
    parameter int DEPTH           = 16,
    parameter int ALMOST_FULL_TH  = 14,
    parameter int ALMOST_EMPTY_TH = 2
)(
    input  logic                   clk,
    input  logic                   rst_n,

    // Write port
    input  logic                   wr_en,
    input  logic [DATA_WIDTH-1:0]  wr_data,

    // Read port
    input  logic                   rd_en,
    output logic [DATA_WIDTH-1:0]  rd_data,

    // Status flags
    output logic                   full,
    output logic                   empty,
    output logic                   almost_full,
    output logic                   almost_empty,
    output logic                   overflow,
    output logic                   underflow,

    // Fill level
    output logic [$clog2(DEPTH):0] fill_level
);

    localparam int PTR_WIDTH = $clog2(DEPTH);

    // Memory array
    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    // Pointers
    logic [PTR_WIDTH-1:0] wr_ptr;
    logic [PTR_WIDTH-1:0] rd_ptr;

    // Count register (correct width = PTR_WIDTH+1 to hold 0..DEPTH)
    logic [PTR_WIDTH:0] count;

    // =========================================================================
    // BUG #1 — fill_level uses raw pointer subtraction (no MSB carry)
    // After a full wrap cycle, wr_ptr - rd_ptr loses the overflow bit and
    // reports 0 even when FIFO holds data. Symptom: fill_level reads as 0
    // or wraps unexpectedly after DEPTH writes.
    // =========================================================================
    assign fill_level = wr_ptr - rd_ptr;   // BUG: should use 'count'

    // =========================================================================
    // Count tracking (this part is correct)
    // =========================================================================
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            count <= '0;
        end else begin
            case ({wr_en & ~full, rd_en & ~empty})
                2'b10   : count <= count + 1'b1;
                2'b01   : count <= count - 1'b1;
                default : count <= count;
            endcase
        end
    end

    assign full        = (count == DEPTH[PTR_WIDTH:0]);
    assign empty       = (count == '0);
    assign almost_full = (count >= ALMOST_FULL_TH[PTR_WIDTH:0]);

    // =========================================================================
    // BUG #2 — almost_empty uses strict-less-than instead of less-than-or-equal
    // Spec: assert when count <= ALMOST_EMPTY_TH
    // Bug : asserts when count <  ALMOST_EMPTY_TH  (off-by-one)
    // Symptom: when count == ALMOST_EMPTY_TH, almost_empty stays LOW.
    // =========================================================================
    assign almost_empty = (count < ALMOST_EMPTY_TH[PTR_WIDTH:0]);   // BUG

    // =========================================================================
    // Write logic
    // =========================================================================
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            wr_ptr <= '0;
        end else if (wr_en && !full) begin
            mem[wr_ptr] <= wr_data;
            wr_ptr      <= wr_ptr + 1'b1;
        end
    end

    // =========================================================================
    // BUG #3 — Registered (non-FWFT) read output
    // Spec requires First-Word-Fall-Through: rd_data must present the head
    // of the FIFO combinatorially without needing rd_en to be pulsed first.
    // This implementation flops the output, causing 1-cycle read latency and
    // breaking back-to-back consecutive read sequences.
    // =========================================================================
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            rd_ptr  <= '0;
            rd_data <= '0;
        end else if (rd_en && !empty) begin
            rd_data <= mem[rd_ptr];   // BUG: should be combinatorial assign
            rd_ptr  <= rd_ptr + 1'b1;
        end
    end

    // =========================================================================
    // Overflow / Underflow sticky flags
    // =========================================================================
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            overflow  <= 1'b0;
            underflow <= 1'b0;
        end else begin
            if (wr_en &&  full)  overflow  <= 1'b1;
            if (rd_en && empty)  underflow <= 1'b1;
        end
    end

endmodule
