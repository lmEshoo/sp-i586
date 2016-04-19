
module psram_ctrlr
(
    //System signals
    input              clk,         //100MHz system clock
    input              rst_n,       //reset
    output reg         controller_ready,

    //FML Interface
    input      [22:0]  fml_adr,
    input              fml_stb,
    input              fml_we,
    output reg         fml_eack,
    input      [2:0]   fml_cti,
    input      [3:0]   fml_sel,
    input      [31:0]  fml_di,
    output reg [31:0]  fml_do,

    //Memory interface
    output reg         mem_clk_en,
    input      [15:0]  mem_data_i_int,
    output reg [15:0]  mem_data_o_int,
    output reg         mem_data_oe_int,
    output     [22:0]  mem_addr_int,
    output reg [ 1:0]  mem_be_int,
    output reg         mem_wen_int,
    output reg         mem_oen_int,
    output reg         mem_cen_int,
    output reg         mem_adv_int,
    output reg         mem_cre_int,
    input              mem_wait_int
);

reg [11:0] state;
reg [11:0] next_state;

parameter s_startup = 0;
parameter s_write_bcr1 = 1;
parameter s_write_bcr2 = 2;
parameter s_write_bcr3 = 3;
parameter s_idle = 4;
parameter s_write1 = 5;
parameter s_write2 = 6;
parameter s_write3 = 7;
parameter s_write4 = 8;
parameter s_write5 = 9;
parameter s_write6 = 10;
parameter s_write7 = 11;
parameter s_write8 = 12;
parameter s_write9 = 13;
parameter s_write10 = 14;
parameter s_write11 = 15;
parameter s_read1 = 16;
parameter s_read2 = 17;
parameter s_read3 = 18;
parameter s_read4 = 19;
parameter s_read5 = 20;
parameter s_read6 = 21;
parameter s_read7 = 22;
parameter s_read8 = 23;
parameter s_read9 = 24;
parameter s_read10 = 25;
parameter s_read11 = 26;
parameter s_read12 = 27;

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        state <= s_startup;
    end else begin
        state <= next_state;
    end
end

reg [14:0] cntr;
reg [14:0] cntr_reload_val;
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        cntr <= 15001;
    end else if(cntr != 0)
        cntr <= cntr - 1'b1;
    else
        cntr <= cntr_reload_val;
end

//Address, data and byte select registers
reg [22:0] addr;
reg [31:0] data;
reg [3:0]  be;
reg        latch_addr;
reg        latch_data;
reg        latch_be;
reg [15:0] temp16;

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        addr <= 23'b000_10_00_0_0_011_1_0_1_0_0_01_1_111;
        data <= 32'b0;
        be <= 8'b0;
    end else begin
        if(latch_addr)
            addr <= fml_adr;
        if(latch_data)
            data <= fml_di;
        if(latch_be)
            be <= ~fml_sel;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        fml_do <= 0;
    end else begin
        if(state == s_read10)  temp16 <= mem_data_i_int; else
        if((state == s_read11)|(state == s_read8)) fml_do <= {mem_data_i_int,temp16};
        if((state == s_read11)|(state == s_read8)|(state == s_write9)) fml_eack <= 1; else fml_eack <= 0;
    end
end


assign mem_addr_int = addr;


always @(state or cntr or fml_stb or fml_we or data or be or fml_eack or mem_wait_int) begin
    controller_ready = 1'b1;

    next_state = state;

    mem_clk_en = 1'b0;
    //fml_eack = 1'b0;

    mem_data_o_int = 16'b0;
    mem_data_oe_int = 1'b0;

    mem_be_int = 2'b0;
    mem_wen_int = 1'b1;
    mem_oen_int = 1'b1;
    mem_cen_int = 1'b1;
    mem_adv_int = 1'b1;
    mem_cre_int = 1'b0;

    cntr_reload_val = 15'b0;

    latch_addr = 1'b0;
    latch_data = 1'b0;
    latch_be = 1'b0;

    case(state)
        s_startup: begin
            controller_ready = 1'b0;
            if(cntr == 0)
                next_state = s_write_bcr1;
        end

        s_write_bcr1: begin
            controller_ready = 1'b0;
            mem_cre_int = 1'b1;
            mem_cen_int = 1'b0;
            mem_adv_int = 1'b0;
            next_state = s_write_bcr2;
        end

        s_write_bcr2: begin
            controller_ready = 1'b0;
            mem_cre_int = 1'b1;
            mem_cen_int = 1'b0;
            cntr_reload_val = 15'd5;
            next_state = s_write_bcr3;
        end

        s_write_bcr3: begin
            controller_ready = 1'b0;
            mem_cen_int = 1'b0;
            mem_wen_int = 1'b0;
            if(cntr == 0)
                next_state = s_idle;
        end

        s_idle: begin
     	    mem_oen_int = 1'b1;
     	    mem_be_int  = 2'b0;
     	    mem_wen_int = 1'b1;
     	    mem_oen_int = 1'b1;
     	    mem_cen_int = 1'b1;
     	    mem_adv_int = 1'b1;
     	    mem_cre_int = 1'b0;
            mem_clk_en = 1'b1;
            if(fml_stb && fml_we && !fml_eack) begin
                latch_addr = 1'b1;
                latch_data = 1'b1;
                latch_be = 1'b1;
                next_state = s_write1;
            end else if(fml_stb && !fml_we && !fml_eack) begin
                latch_addr = 1'b1;
                next_state = s_read1;
            end
        end

        //-------------- read --------------

        s_read1: begin
           mem_clk_en = 1'b1;
           mem_cen_int = 1'b0;
           mem_adv_int = 1'b0;
           if (fml_stb == 0) next_state = s_idle; else
           next_state = s_read7;
        end
		  
        s_read7: begin
	       mem_clk_en  = 1'b1; 
           mem_cen_int = 1'b0;
           mem_oen_int = 1'b0;
           if (fml_stb == 0) next_state = s_idle; else
	       if (mem_wait_int == 0) next_state = s_read10; else next_state = s_read7;	   
          end

        s_read8: begin
	       mem_clk_en  = 1'b1; 
           mem_cen_int = 1'b0;
           mem_oen_int = 1'b0;
	       if (fml_stb == 0) next_state = s_idle; else
	       if (fml_cti == 7) next_state = s_idle; else
	       if (mem_wait_int == 0) next_state = s_read10; else next_state = s_read9;	   
          end

        s_read9: begin
	       mem_clk_en  = 1'b1; 
           mem_cen_int = 1'b0;
           mem_oen_int = 1'b0;
           if (fml_stb == 0) next_state = s_idle; else
	       if (mem_wait_int == 0) next_state = s_read10; else next_state = s_read9;	   
          end

        s_read10: begin
	       mem_clk_en  = 1'b1;
           mem_cen_int = 1'b0;
           mem_oen_int = 1'b0;
           if (fml_stb == 0) next_state = s_idle; else
	       if ((mem_wait_int == 0) && (fml_cti==2)) next_state = s_read8 ; else 
	       if ((mem_wait_int == 0) && (fml_cti==7)) next_state = s_idle  ; else 
	       if ((mem_wait_int == 0) && (fml_cti==0)) next_state = s_read11; else 
                                                    next_state = s_read10;
	       end

        s_read11: begin
	       mem_clk_en  = 1'b1;
           mem_cen_int = 1'b1;
           mem_oen_int = 1'b1;
		   next_state = s_idle;
         end
			
        //-------------- write --------------

        s_write1: begin
            mem_clk_en = 1'b1;
            mem_cen_int = 1'b0;
            mem_adv_int = 1'b0;
            mem_wen_int = 1'b0;
            next_state = s_write8;
        end

        s_write8: begin
            mem_clk_en = 1'b1;
            mem_cen_int = 1'b0;
            mem_data_oe_int = 1'b1;
            mem_be_int = be[1:0];
            if (mem_wait_int == 0) 
	     begin
	      next_state = s_write9; 
	      mem_data_o_int = data[15:0];
	     end
	     else 
	     begin
	      next_state = s_write8;
              mem_data_o_int = data[31:16];
	     end
        end

        s_write9: begin
            mem_clk_en = 1'b1;
            mem_cen_int = 1'b0;
            mem_data_oe_int = 1'b1;
            mem_data_o_int = data[31:16];
            mem_be_int = be[3:2];
	    if (mem_wait_int == 0) next_state = s_idle; else next_state = s_write9;
        end

        default:
            next_state = s_startup;
    endcase
end

endmodule
