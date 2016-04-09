
module psram_clk_iob
(
    input              clk,
    input              clk_en,
    output             clk_q
);

reg clk_en_int;

// latch
always @(clk_en or clk)
 if (clk == 0) clk_en_int <= clk_en; 

assign clk_q = clk & clk_en_int;

endmodule

