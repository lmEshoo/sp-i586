/* verilator lint_off UNUSED */
/* verilator lint_off CASEX */
/* verilator lint_off COMBDLY */

//
// address calculation Unit
//

module acu (clk, rstn, add_src , to_regf , from_regf, from_dec, db67 , seg_src );

input clk, rstn;
input  [63:0] from_regf;       // base&index  register selected for address calculation
input  [128+1+1+73+8-1:0] from_dec;
input db67;

output reg  [2:0] seg_src;
output reg [31:0] add_src;    // adress to read from
output      [7:0] to_regf;    // base&index  select register for address calculation

wire   [7:0] indrm;          // Decoder intermediate input
wire  [72:0] indic;          // Decoder intermediate input
wire [127:0] in128;          // Decoder intermediate input
wire         sib_dec;        // Decoder intermediate input
wire         mod_dec;        // Decoder intermediate input
wire  [31:0] reg_base;
wire  [31:0] reg_index;
wire  [31:0] shf_index;
wire   [7:0] modrm,modrmr;
wire  [15:0] disp16;
wire  [7:0]  to_regf32,to_regf16;
reg          ov;

// Split from_deco bus
// 
assign {in128,mod_dec,sib_dec,indic,indrm}=from_dec;

// Select Base and index Register
//
assign modrm = in128[15:8];
assign to_regf = db67 ? to_regf32 : to_regf16;
assign to_regf32[3:0] = (&indrm[1:0]) ? {1'b0,in128[18:16]} : {1'b0,in128[10:8]};
assign to_regf32[7:4] = (&indrm[1:0]) ? {1'b0,in128[21:19]} : {4'b1111         };

assign disp16 = ({modrm[7:6],modrm[2:0]}==5'b00110) ? in128[31:16] :
                ({modrm[7:6]}==2'b10) ? in128[31:16] :
                ({modrm[7:6]}==2'b01) ? {{8{in128[23]}},in128[23:16]} :
		16'b0;

assign to_regf16[3:0] = (modrm[2:1]==2'b11) ? {4'b1111} : {1'b0,2'b11,modrm[0]} ;
assign to_regf16[7:4] = ( modrm[2:1]             == 2'b10   ) ? {4'b1111} :
                        ({modrm[7:6],modrm[2:0]} == 5'b00110) ? {4'b1111} :
                        (modrm[2]==1'b0) ? {1'b0, modrm[1], ~modrm[1],1'b1} :
			                   {1'b0, ~modrm[0], modrm[0],1'b1} ;

assign reg_base     = from_regf[31: 0];     
assign reg_index    = ((in128[21:19]==4)&&(db67==1)) ? 0 : from_regf[63:32]; // ESP is illegal index 
assign shf_index    = (in128[23:22]==0) ?   reg_index             :
                      (in128[23:22]==1) ?  {reg_index[30:0],1'b0} :
                      (in128[23:22]==2) ?  {reg_index[29:0],2'b0} :
                                           {reg_index[28:0],3'b0} ;

// Put in FFlops the address of memory location to be used for next operation
//

always @(reg_base or reg_index or shf_index or in128 or mod_dec or indrm or disp16 or to_regf32 or to_regf or db67)
if (db67)
 begin
    seg_src <=0; 
    if (mod_dec)
     casex(indrm[4:0]) 
      5'b00110 : begin     add_src  <=                             in128[47:16] ; end  // 32bit only displc
      5'b10010 : begin {ov,add_src} <= reg_base + {{24{in128[23]}},in128[23:16]}; end  // no sib - 8bit displc
      5'b10011 : begin {ov,add_src} <= shf_index+ reg_base + {{24{in128[31]}},in128[31:24]}; end  //    sib - 8bit displc
      5'b01010 : begin {ov,add_src} <=            reg_base +       in128[47:16] ; end  // no sib - 32bit displc
      5'b01011 : begin {ov,add_src} <= shf_index+ reg_base +       in128[55:24] ; end  //    sib - 32bit displc
      
      5'b00011 : if ((indrm[7]==1)&&(to_regf32[3:0]==4'b0101))
                 begin {ov,add_src} <= shf_index+                  in128[55:24] ; end  //    sib - 32bit displc only
            else begin {ov,add_src} <= shf_index+ reg_base                      ; end  //    sib - no displc displc
      
      5'b00010 : begin     add_src  <=            reg_base                      ; end  //    no sib - no displc - only base
      default  : begin     add_src  <=            reg_base                      ; end
     endcase 
    else begin add_src <=0; ov <=0; end
 end
else
 begin   if ((mod_dec&indrm[6]) == 1) seg_src <= 3'b011;
    else if (     mod_dec == 0      ) seg_src <= 3'b011;
    else if (to_regf[7:4] == 4'b0101) seg_src <= 3'b010; 
    else if (to_regf[7:4] == 4'b0100) seg_src <= 3'b010;     
    else seg_src <= 3'b011; 
    ov <=0;
    if (mod_dec)
      begin 
        add_src[15:0]  <= reg_base[15:0] + reg_index[15:0] + disp16; 
	    add_src[31:16] <= 16'b0 ; 
      end
    else add_src <=0;
 end

endmodule
