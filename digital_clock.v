//`define DEBUG

module timer_team(
    output reg [5:0] o_hms_cnt,
    output reg o_max_hit,
    input [5:0] i_max_cnt,
    input i_clk,
    input i_rstn,
    input tim_num,
    input num,
    input [5:0] pre_num,
    input [5:0] pre_num1
);

    localparam START = 1'b0;
    localparam STOP = 1'b1;
    localparam PLUS = 1'b0;
    localparam MINUS = 1'b1;

    always @(posedge i_clk or negedge i_rstn) begin
        if (!i_rstn) begin
            o_hms_cnt <= 6'd0;
            o_max_hit <= 1'b0;
        end else begin
            if (tim_num == START) begin
                if ((pre_num == 6'd0) && (pre_num1 == 6'd0))  begin
                    if (o_hms_cnt <= 6'd0) begin
                        o_hms_cnt <= 0;
                        o_max_hit <= 1'b0;
                    end else begin
                        o_hms_cnt <= o_hms_cnt - 1;
                        o_max_hit <= 1'b0;
                    end
                end else begin
                    if (o_hms_cnt <= 6'd0) begin
                        o_hms_cnt <= i_max_cnt;
                        o_max_hit <= 1'b1;
                    end else begin
                        o_hms_cnt <= o_hms_cnt - 1;
                        o_max_hit <= 1'b0;
                    end
                end
            end else begin
                if (num == PLUS) begin
                    if (o_hms_cnt >= i_max_cnt) begin
                        o_hms_cnt <= 6'd0;
                        o_max_hit <= 1'b1;
                    end else begin
                        o_hms_cnt <= o_hms_cnt + 1;
                        o_max_hit <= 1'b0;
                    end 
                end else begin
                    if (o_hms_cnt <= 6'd0) begin
                        o_hms_cnt <= i_max_cnt;
                        o_max_hit <= 1'b1;
                    end else begin
                        o_hms_cnt <= o_hms_cnt - 1;
                        o_max_hit <= 1'b0;
                    end
                end
            end
        end
    end
endmodule




module blink ( 



    input            tim_num,
    input   [1:0]    i_position,
    input   [1:0]    i_mode,
    input   [41:0]    i_six_seg,      
    input           i_clk,
    input           i_rstn,
    output  reg [41:0]   o_six_seg   
);
                              
wire clk_1  ;
nco      u2_nco(
      .o_clk       ( clk_1   ),
      .i_num       ( 32'd10000000   ),
      .i_clk      ( i_clk      ),
      .i_rstn      ( i_rstn   ));      
      
reg   [5:0]   o_seg_enb       ;
reg       count1      ;   
reg       count2      ;
reg       count3      ;
      
always @(posedge clk_1 or negedge i_rstn) begin
  if(i_rstn == 1'b0) begin
    count1 = 1'b0;
    count2 = 1'b0;
    count3 = 1'b0;
  end else begin
    count1 <= count1 + 1'b1;
    count2 <= count2 + 1'b1;
    count3 <= count3 + 1'b1;
  end
end

always @(*) begin
  if((i_mode == 2'b01) || (i_mode == 2'b10)|| ((i_mode == 2'b11)&&(tim_num==1)))begin
    case ( i_position  )
     2'b00 : begin
        if( count1 == 1'b0 ) begin
          o_six_seg [13:0] = 14'd0                    ;
          o_six_seg [41:14] = i_six_seg [41:14] ;
         end else begin
           o_six_seg = i_six_seg                 ;
         end
      end
      2'b01 : begin
         if( count2 == 1'b0) begin
          o_six_seg [13:0]  = i_six_seg [13:0]  ;
            o_six_seg [27:14] = 14'd0                   ;
            o_six_seg [41:28] = i_six_seg [41:28] ;   
         end else begin
           o_six_seg = i_six_seg                 ;
         end
      end
      2'b10 : begin
         if(count3 == 1'b0) begin
          o_six_seg [27:0]  = i_six_seg [27:0]  ;
            o_six_seg [41:28] = 14'd0                   ;
         end else begin
           o_six_seg = i_six_seg                 ;
         end
      end 
    endcase
   end else begin
    o_six_seg = i_six_seg                        ;
   end 
end
endmodule


module nco(


    output reg           o_clk,
    input         [31:0] i_num,
    input                i_clk,
    input                i_rstn
);

    reg    [31:0]        cnt;


    always @(posedge i_clk or negedge i_rstn)begin
       if(!i_rstn) begin 
         cnt     <={32{1'b1}};
         o_clk   <=0;
       end else begin
         if (cnt >=i_num/2-1) begin
            cnt     <=0;
            o_clk   <=~o_clk;
          end else begin
            cnt     <=cnt+1;
            o_clk   <=o_clk;
          end
       end
    end
endmodule

module buzz(
    output          o_buzz,
    input           i_buzz_en,
    input           i_clk,
    input           i_rstn
);
    localparam      C = 191113;
    localparam      D = 170262;
    localparam      E = 151686;
    localparam      F = 143173;
    localparam      G = 63776;
    localparam      A = 56818;
    localparam      B = 50619;
    
    wire            clk_beat;
    nco     u_nco_beat(
        .o_clk      (clk_beat    ),
        .i_num      (12500000    ),
        .i_clk      (i_clk       ),
        .i_rstn     (i_rstn      ));
   
    reg    [5:0]   cnt_buzz;
    
 
    always @ (posedge clk_beat or negedge i_rstn) begin
         if(!i_rstn) begin
            cnt_buzz <= 6'd0;
         end else begin
            if (i_buzz_en) begin
               if(cnt_buzz == 6'd63) begin
                  cnt_buzz <= 6'd0;
               end else begin
                  cnt_buzz <= cnt_buzz + 1'd1;
               end 
               end else begin
                  cnt_buzz <= 6'd0;
                  end
         end
      end
    
    
    
    reg     [31:0]  buzz_freq;
    always@(*)begin
        case(cnt_buzz)
         
            6'd00: buzz_freq = C ;
            6'd01: buzz_freq = C ;
            6'd02: buzz_freq = D ;
            6'd03: buzz_freq = D ;
            6'd04: buzz_freq = E ;
            6'd05: buzz_freq = E ;
            6'd06: buzz_freq = E ;
            6'd07: buzz_freq = E ;
            6'd08: buzz_freq = C ;
            6'd09: buzz_freq = C ;
            6'd10: buzz_freq = E ;
            6'd11: buzz_freq = E ;
            6'd12: buzz_freq = G ;
            6'd13: buzz_freq = A ;
            6'd14: buzz_freq = G ;
            6'd15: buzz_freq = G ;
            6'd16: buzz_freq = C ;
            6'd17: buzz_freq = C ;
            6'd18: buzz_freq = D ;
            6'd19: buzz_freq = D ;
            6'd20: buzz_freq = E ;
            6'd21: buzz_freq = E ;
            6'd22: buzz_freq = E ;
            6'd23: buzz_freq = E ;
            6'd24: buzz_freq = C ;
            6'd25: buzz_freq = C ;
            6'd26: buzz_freq = E ;
            6'd27: buzz_freq = E ;
            6'd28: buzz_freq = G ;
            6'd29: buzz_freq = A ;
            6'd30: buzz_freq = G ;
            6'd31: buzz_freq = G ;  
            6'd32: buzz_freq = A ;
            6'd33: buzz_freq = A ;
            6'd34: buzz_freq = A ;
            6'd35: buzz_freq = A ;
            6'd36: buzz_freq = G ;
            6'd37: buzz_freq = G ;
            6'd38: buzz_freq = E ;
            6'd39: buzz_freq = E ;
            6'd40: buzz_freq = A ;
            6'd41: buzz_freq = A ;
            6'd42: buzz_freq = A ;
            6'd43: buzz_freq = A ;
            6'd44: buzz_freq = G ;
            6'd45: buzz_freq = G ;
            6'd46: buzz_freq = E ;
            6'd47: buzz_freq = E ;
            6'd48: buzz_freq = D ;
            6'd49: buzz_freq = D ;
            6'd50: buzz_freq = D ;
            6'd51: buzz_freq = D ;
            6'd52: buzz_freq = C ;
            6'd53: buzz_freq = C ;
            6'd54: buzz_freq = D ;
            6'd55: buzz_freq = D ;
            6'd56: buzz_freq = E ;
            6'd57: buzz_freq = E ;
            6'd58: buzz_freq = G ;
            6'd59: buzz_freq = G ;
            6'd60: buzz_freq = G ;
            6'd61: buzz_freq = G ;
            6'd62: buzz_freq = G ;
            6'd63: buzz_freq = G ;
        
        endcase
    end
    wire        buzz;
    nco u_nco_buzz(
        .o_clk      (buzz        ),
        .i_num      (buzz_freq   ),
        .i_clk      (i_clk       ),
        .i_rstn     (i_rstn      ));
    assign o_buzz = buzz & i_buzz_en;
        
endmodule

module  cnt_param#(
   parameter    RANGE =60
)(
    output reg  [$clog2(RANGE)-1:0]    o_cnt,
    input                              i_direct,
    input                              i_clk,
    input                              i_rstn
);

    always @(posedge  i_clk or negedge i_rstn) begin
     if(!i_rstn)begin
        if(!i_direct) begin
          o_cnt  <= {$clog2(RANGE){1'b1}};
         end else begin
          o_cnt  <=RANGE;
         end
     end else begin
       if(!i_direct) begin
         if(o_cnt == RANGE-1) begin
           o_cnt <=0;
          end else begin
           o_cnt <= o_cnt +1;
          end
       end else begin
         if(o_cnt==0)begin
           o_cnt  <= RANGE-1;
         end else begin
           o_cnt <=  o_cnt-1;
         end
       end
     end
   end
endmodule

module led_ctrl#(
     parameter   NCO_LED_SPEED   = 50
)(

    output  reg  [6:0]       o_seg,
    output  reg              o_seg_dp,
    output  reg  [5:0]       o_seg_enb,
    input        [6*7-1:0]   i_six_seg,
    input        [5:0]       i_six_seg_dp,
    input                    i_clk,
    input                    i_rstn,
    input                    mode,
    input                    position
);


    wire              clk_disp_speed;

   nco u_nco(
         .o_clk         (clk_disp_speed  ),
         .i_num         (NCO_LED_SPEED   ),
         .i_clk         (i_clk           ),
         .i_rstn        (i_rstn          ));

    wire   [2:0]    cnt_seg_enb;
    cnt_param#(
      .RANGE    (6           ))
    u_cnt_param(
         .o_cnt         (cnt_seg_enb    ),
         .i_direct      (1'b0           ),
         .i_clk         (clk_disp_speed ),
         .i_rstn        (i_rstn         ));

    always @(*) begin
          case(cnt_seg_enb)
           3'd0:      {o_seg_enb,  o_seg,  o_seg_dp}={6'b111110, i_six_seg[0*7+6:0*7], i_six_seg_dp[0]};
           3'd1:      {o_seg_enb,  o_seg,  o_seg_dp}={6'b111101, i_six_seg[1*7+6:1*7], i_six_seg_dp[1]};
           3'd2:      {o_seg_enb,  o_seg,  o_seg_dp}={6'b111011, i_six_seg[2*7+6:2*7], i_six_seg_dp[2]};
           3'd3:      {o_seg_enb,  o_seg,  o_seg_dp}={6'b110111, i_six_seg[3*7+6:3*7], i_six_seg_dp[3]};
           3'd4:      {o_seg_enb,  o_seg,  o_seg_dp}={6'b101111, i_six_seg[4*7+6:4*7], i_six_seg_dp[4]};
           3'd5:      {o_seg_enb,  o_seg,  o_seg_dp}={6'b011111, i_six_seg[5*7+6:5*7], i_six_seg_dp[5]};
           default    {o_seg_enb,  o_seg,  o_seg_dp}={6'b000000, 7'b1111111, 1'b1};
         endcase
    end
endmodule


module  num_split#(
    parameter  RANGE =60
)(

       output   [3:0]                 o_digit_l,
       output   [3:0]                 o_digit_r,
       input    [$clog2(RANGE)-1:0]   i_num
);
    assign  o_digit_l  = i_num/10;
    assign  o_digit_r  = i_num%10;
endmodule


module dec_to_seg(
  input [3:0] i_num,
  output reg [6:0] o_seg
);

always @(*)
begin
  case(i_num)
    4'b0000: o_seg = 7'b1111110; // 0
    4'b0001: o_seg = 7'b0110000; // 1
    4'b0010: o_seg = 7'b1101101; // 2
    4'b0011: o_seg = 7'b1111001; // 3
    4'b0100: o_seg = 7'b0110011; // 4
    4'b0101: o_seg = 7'b1011011; // 5
    4'b0110: o_seg = 7'b1011111; // 6
    4'b0111: o_seg = 7'b1110000; // 7
    4'b1000: o_seg = 7'b1111111; // 8
    4'b1001: o_seg = 7'b1110011; // 9
    4'b1010: o_seg = 7'b1110111; // a
    4'b1011: o_seg = 7'b1111111; // b
    4'b1100: o_seg = 7'b1111000; // c
    4'b1101: o_seg = 7'b1111110; // d
    4'b1110: o_seg = 7'b1001111; // e
    4'b1111: o_seg = 7'b1000111; // f
    default: o_seg = 7'b0000000; 
  endcase
end

endmodule

module switch_debounce(
    output    [7:0]   o_sw,
    input     [7:0]   i_sw,
    input             i_clk,
    input             i_rstn
);

   `ifdef  DEBUG
        localparam  NCO_DEBOUNCE=4;
   `else
        localparam  NCO_DEBOUNCE=1000000;
   `endif
    wire        clk_debounce;
    nco u_nco_clk_slow(
     .o_clk      (clk_debounce   ),
     .i_num      (NCO_DEBOUNCE   ),
     .i_clk      (i_clk          ),
     .i_rstn     (i_rstn         ));

    reg       [7:0]   dly_sw0;
    reg       [7:0]   dly_sw1;
    always @(posedge clk_debounce)  begin
        dly_sw0  <= i_sw;
        dly_sw1  <= dly_sw0;
    end

    assign    o_sw    = dly_sw0 | ~dly_sw1;
endmodule



module  hms_cnt_team(

    output  reg  [5:0]  o_hms_cnt,
    output  reg         o_max_hit,
    input        [5:0]  i_max_cnt,
    input               i_clk,
    input               i_rstn,
    input               num
);


    always @(posedge i_clk or negedge i_rstn) begin
      if(!i_rstn) begin
          o_hms_cnt  <= 6'd0;
          o_max_hit  <= 1'b0;
      end else begin
         if(num==0) begin
           if(o_hms_cnt >= i_max_cnt) begin
               o_hms_cnt  <= 6'd0;
               o_max_hit  <= 1'b1;
           end else begin
               o_hms_cnt  <= o_hms_cnt+1;
               o_max_hit  <= 1'b0;
           end
         end else begin
           if(o_hms_cnt <= 6'd0) begin
               o_hms_cnt  <= i_max_cnt;
               o_max_hit  <= 1'b1;
           end else begin
               o_hms_cnt  <= o_hms_cnt-1;
               o_max_hit  <= 1'b0;
           end
         end
       end
   end
endmodule

module  minsec_team(

    output  reg      o_alarm,
    output  reg   [5:0]   o_sec,
    output  reg   [5:0]   o_min,
    output  reg   [5:0]   o_hour,
    output   reg   [5:0]   o_sec_alarm,
     output  reg   [5:0]   o_min_alarm,
     output  reg   [5:0]   o_hour_alarm,
    output           o_sec_max_hit,
    output           o_min_max_hit,
    output           o_hour_max_hit,
    output           o_sec_tim_hit,
    output           o_min_tim_hit,
    output           o_hour_tim_hit,
    input    [1:0]   i_mode,
    input            i_cal,
    input            tim_num,
    input            i_alarm_en,
    input            i_sec_cnt_clk,
    input            i_min_cnt_clk,
    input            i_hour_cnt_clk,
    input            i_hour_alm_clk,
    input            i_sec_alm_clk,
    input            i_min_alm_clk,
    input            i_hour_tim_clk,
    input            i_sec_tim_clk,
    input            i_min_tim_clk,
    input            i_clk,
    input            i_rstn

);

    localparam    MODE_CLOCK  =2'b00;
    localparam    MODE_SETUP  =2'b01;
    localparam    MODE_ALARM  =2'b10;
    localparam    MODE_TIMER  =2'b11;
    localparam    PLUS        =1'b0;
    localparam    MINUS       =1'b1;
    localparam    START       =1'b0;
    localparam    STOP        =1'b1;

    wire   [5:0]    sec_cnt;
    wire   [5:0]    min_cnt;
    wire   [5:0]    hour_cnt;
    wire   [5:0]    hour_alm;
    wire   [5:0]    sec_alm;
    wire   [5:0]    min_alm;
    wire   [5:0]    hour_tim;
    wire   [5:0]    sec_tim;
    wire   [5:0]    min_tim;
    reg             cal;
    reg             alm_tim;


     always@(*)begin
       if(i_mode == MODE_ALARM && i_cal == MINUS ) begin
           cal  <= PLUS;
       end else begin
          if(i_mode == MODE_CLOCK) begin
             cal  <= PLUS;
          end else begin
           if(i_cal == PLUS) begin
                cal  <= PLUS;
           end else begin
                cal <= MINUS;
           end
       end
    end
   end

always @(*) begin
  if (!i_rstn) begin
    alm_tim <= 1'b0;
   end else begin
    if(tim_num==START&&hour_tim==6'd0&&min_tim==6'd0&&sec_tim==6'd0) begin
      alm_tim<=1;
    end else begin
      alm_tim<=0;
    end
   end
end
    
   hms_cnt_team  u_hms_cnt_sec(
     .o_hms_cnt (sec_cnt        ),
     .num       (cal            ),
     .o_max_hit (o_sec_max_hit  ),    
     .i_max_cnt (6'd59          ),
     .i_clk     (i_sec_cnt_clk  ),
     .i_rstn    (i_rstn         ));

   hms_cnt_team  u_hms_cnt_min(
     .o_hms_cnt (min_cnt        ),
     .num       (cal            ),
     .o_max_hit (o_min_max_hit  ),    
     .i_max_cnt (6'd59          ),
     .i_clk     (i_min_cnt_clk  ),
     .i_rstn    (i_rstn         ));

   hms_cnt_team  u_hms_cnt_hour(
     .o_hms_cnt (hour_cnt        ),
     .num       (cal             ),
     .o_max_hit (o_hour_max_hit  ),    
     .i_max_cnt (6'd23          ),
     .i_clk     (i_hour_cnt_clk  ),
     .i_rstn    (i_rstn         ));

   hms_cnt_team  u_hms_alm_sec(
     .o_hms_cnt (sec_alm        ),
     .num       (i_cal          ),
     .o_max_hit (               ),    
     .i_max_cnt (6'd59          ),
     .i_clk     (i_sec_alm_clk  ),
     .i_rstn    (i_rstn         ));

   hms_cnt_team  u_hms_alm_min(
     .o_hms_cnt (min_alm        ),
     .num       (i_cal          ),
     .o_max_hit (               ),    
     .i_max_cnt (6'd59          ),
     .i_clk     (i_min_alm_clk  ),
     .i_rstn    (i_rstn         ));

   hms_cnt_team  u_hms_alm_hour(
     .o_hms_cnt (hour_alm        ),
     .num       (i_cal          ),
     .o_max_hit (               ),    
     .i_max_cnt (6'd23          ),
     .i_clk     (i_hour_alm_clk  ),
     .i_rstn    (i_rstn         ));

   timer_team  u_hms_tim_sec(
     .o_hms_cnt (sec_tim        ),
     .num       (i_cal          ),
     .pre_num   (min_tim        ),
     .pre_num1  (hour_tim       ),
     .tim_num   (tim_num        ),
     .o_max_hit (o_sec_tim_hit  ),    
     .i_max_cnt (6'd59          ),
     .i_clk     (i_sec_tim_clk  ),
     .i_rstn    (i_rstn         ));

   timer_team  u_hms_tim_min(
     .o_hms_cnt (min_tim        ),
     .pre_num   (6'd0           ),
     .pre_num1  (hour_tim       ),
     .num       (i_cal          ),
     .tim_num   (tim_num        ),
     .o_max_hit (o_min_tim_hit  ),    
     .i_max_cnt (6'd59          ),
     .i_clk     (i_min_tim_clk  ),
     .i_rstn    (i_rstn         ));

   timer_team  u_hms_tim_hour(
     .o_hms_cnt (hour_tim       ),
     .pre_num   (6'd0           ),
     .pre_num1  (6'd0           ),
     .num       (i_cal          ),
     .tim_num   (tim_num        ),
     .o_max_hit (o_hour_tim_hit ),    
     .i_max_cnt (6'd23          ),
     .i_clk     (i_hour_tim_clk ),
     .i_rstn    (i_rstn         ));    


     always@(*) begin
       case(i_mode)
        MODE_CLOCK : begin
           o_sec = sec_cnt;
           o_min = min_cnt;
           o_hour =hour_cnt;
        end
        MODE_SETUP : begin
           o_sec = sec_cnt;
           o_min = min_cnt;
           o_hour =hour_cnt;
        end
        MODE_ALARM : begin
           o_sec = sec_alm;
           o_min = min_alm;
           o_hour =hour_alm;
        end
        MODE_TIMER : begin
           o_sec = sec_tim;
           o_min = min_tim;
           o_hour =hour_tim;
        end
       endcase
    end
    always @(posedge   i_clk  or negedge i_rstn) begin
      if(!i_rstn) begin
      o_alarm <=0;
      end else begin
       if(((sec_cnt == sec_alm)&&(min_cnt == min_alm)&&(hour_cnt == hour_alm))||alm_tim==1) begin
         o_alarm <= 1&& i_alarm_en;
       end else begin
         o_alarm <= o_alarm &&i_alarm_en;
       end
      end
    end

    always @(*) begin
        o_sec_alarm  = sec_alm;
        o_min_alarm  = min_alm;
        o_hour_alarm = hour_alm;
    end


endmodule

module  controller_team(

    output  reg  [1:0]   o_mode,
    output  reg  [1:0]   o_position,
    output  reg          o_cal,
    output  reg          tim_num,
    output  reg          o_alarm_en,
    output  reg          o_sec_cnt_clk,
    output  reg          o_min_cnt_clk,
    output  reg          o_sec_alm_clk,
    output  reg          o_hour_cnt_clk,
    output  reg          o_hour_alm_clk,
    output  reg          o_min_alm_clk,
    output  reg          o_hour_tim_clk,
    output  reg          o_min_tim_clk,
    output  reg          o_sec_tim_clk,
    input                i_sec_max_hit,
    input                i_min_max_hit,
    input                i_hour_max_hit,
    input                i_sec_tim_hit,
    input                i_min_tim_hit,
    input                i_hour_tim_hit, 
    input       [7:0]    i_sw,
    input       [31:0]   o_data,
    input                i_clk,
    input                i_rstn, 
    input                stop_sign,
    input       [2:0]    state
);


    localparam  MODE_CLOCK   = 2'b00;
    localparam  MODE_SETUP   = 2'b01;
    localparam  MODE_ALARM   = 2'b10;
    localparam  MODE_TIMER   = 2'b11;
  
    localparam  POS_SEC      = 2'b00;
    localparam  POS_MIN      = 2'b01;
    localparam  POS_HOUR     = 2'b10;
  
    localparam  PLUS         =1'b0;
    localparam  MINUS        =1'b1;
    localparam  START        =1'b0;
    localparam  STOP         =1'b1;
  
    localparam  ir_sw0       = 32'hFD708F;
    localparam  ir_sw1       = 32'hFD08F7;
    localparam  ir_sw2       = 32'hFD8877;
    localparam  ir_sw3       = 32'hFD48B7;
    localparam  ir_sw4       = 32'hFD28D7;
    localparam  ir_sw5       = 32'hFDA857;
    localparam  OK           = 32'hFD906F;

    wire total_sw0; // 모드 선택
    wire total_sw1; // 시,분,초 선택
    wire total_sw2; // 증가,감소 선택
    wire total_sw3; // 1씩 증가 or 1씩 감소
    wire total_sw4; // 알람 ON,OFF
    wire total_sw5; // 타이머 START,RESET

    reg ir_on0;
    reg ir_on1;
    reg ir_on2;
    reg ir_on3;
    reg ir_on4;
    reg ir_on5;

    assign total_sw0 = i_sw[0] && ir_on0;
    assign total_sw1 = i_sw[1] && ir_on1;
    assign total_sw2 = i_sw[2] && ir_on2;
    assign total_sw3 = i_sw[3] && ir_on3;
    assign total_sw4 = i_sw[4] && ir_on4;
    assign total_sw5 = i_sw[5] && ir_on5;

    always @(posedge i_clk or negedge i_rstn) begin
      if(!i_rstn) begin
        ir_on0 <= 1'b1;
        ir_on1 <= 1'b1;
        ir_on2 <= 1'b1;
        ir_on3 <= 1'b1;
        ir_on4 <= 1'b1;
        ir_on5 <= 1'b1;
      end else begin
        if(state == 3'b100) begin
          case(o_data)
            ir_sw0 :begin
              ir_on0 <= 1'b0;
              ir_on1 <= 1'b1;
              ir_on2 <= 1'b1;
              ir_on3 <= 1'b1;
              ir_on4 <= 1'b1;
              ir_on5 <= 1'b1;
            end
            ir_sw1 :begin
              ir_on0 <= 1'b1;
              ir_on1 <= 1'b0;
              ir_on2 <= 1'b1;
              ir_on3 <= 1'b1;
              ir_on4 <= 1'b1;
              ir_on5 <= 1'b1;
            end
            ir_sw2 :begin
              ir_on0 <= 1'b1;
              ir_on1 <= 1'b1;
              ir_on2 <= 1'b0;
              ir_on3 <= 1'b1;
              ir_on4 <= 1'b1;
              ir_on5 <= 1'b1;
            end
            ir_sw3 :begin
              ir_on0 <= 1'b1;
              ir_on1 <= 1'b1;
              ir_on2 <= 1'b1;
              ir_on3 <= 1'b0;
              ir_on4 <= 1'b1;
              ir_on5 <= 1'b1;
            end
            ir_sw4 :begin
              ir_on0 <= 1'b1;
              ir_on1 <= 1'b1;
              ir_on2 <= 1'b1;
              ir_on3 <= 1'b1;
              ir_on4 <= 1'b0;
              ir_on5 <= 1'b1;
            end
            ir_sw5 :begin
              ir_on0 <= 1'b1;
              ir_on1 <= 1'b1;
              ir_on2 <= 1'b1;
              ir_on3 <= 1'b1;
              ir_on4 <= 1'b1;
              ir_on5 <= 1'b0;
            end
            OK : begin
              ir_on0 <= 1'b1;
              ir_on1 <= 1'b1;
              ir_on2 <= 1'b1;
              ir_on3 <= 1'b1;
              ir_on4 <= 1'b1;
              ir_on5 <= 1'b1;            
            end
            default :begin
              ir_on0 <= 1'b1;
              ir_on1 <= 1'b1;
              ir_on2 <= 1'b1;
              ir_on3 <= 1'b1;
              ir_on4 <= 1'b1;
              ir_on5 <= 1'b1;
            end
          endcase
        end else begin
            ir_on0 <= 1'b1;
            ir_on1 <= 1'b1;
            ir_on2 <= 1'b1;
            ir_on3 <= 1'b1;
            ir_on4 <= 1'b1;
            ir_on5 <= 1'b1;
        end
      end
    end


    always @(posedge ~total_sw0 or negedge i_rstn) begin
      if(!i_rstn) begin
       o_mode <= MODE_CLOCK;
      end else begin
         if(o_mode!= MODE_TIMER) begin
              o_mode <= o_mode +1;
         end else begin
              o_mode <= MODE_CLOCK;
         end
      end
     end

    always @(posedge ~total_sw1 or negedge i_rstn) begin
      if(!i_rstn) begin
         o_position <= POS_SEC;
      end else begin
         if(o_position !=POS_HOUR )begin
             o_position <=o_position +1;
         end else begin
             o_position <=POS_SEC;
         end
      end
    end

    always @(posedge ~total_sw2 or negedge i_rstn) begin
      if(!i_rstn) begin
         o_cal <= PLUS;
      end else begin
         if(o_cal ==MINUS )begin
             o_cal <= PLUS;
         end else begin
             o_cal <= o_cal +1;
         end
      end
    end

    always @(posedge ~total_sw4 or negedge i_rstn) begin
     if(!i_rstn) begin
       o_alarm_en <=0;
     end else begin
       o_alarm_en <= ~o_alarm_en;
     end
    end

always @(posedge ~total_sw5 or negedge i_rstn ) begin
  if (!i_rstn) begin
    tim_num <= 1'b1;
  end else begin
    tim_num <= ~tim_num;
  end
  end
  


   `ifdef  DEBUG
     localparam  NCO_NUM_1HZ =4;
   `else
     localparam  NCO_NUM_1HZ =50000000;
   `endif

    wire        clk_1hz;
    nco  u_nco_clk_1hz(
     .o_clk      (clk_1hz        ),
     .i_num      (NCO_NUM_1HZ    ),
     .i_clk      (i_clk          ),
     .i_rstn     (i_rstn         ));

always @(*) begin
  case(o_mode)
    MODE_CLOCK : begin
      o_sec_cnt_clk = clk_1hz;
      o_min_cnt_clk = i_sec_max_hit;
      o_hour_cnt_clk = i_min_max_hit;
      o_sec_alm_clk = 1'b0;
      o_min_alm_clk = 1'b0;
      o_hour_alm_clk = 1'b0;
      o_sec_tim_clk = 1'b0;
      o_min_tim_clk = 1'b0;
      o_hour_tim_clk = 1'b0;
    end
    MODE_SETUP : begin
      case(o_position)
        POS_SEC : begin
          o_sec_cnt_clk = ~total_sw3;
          o_min_cnt_clk = 1'b0;
          o_hour_cnt_clk = 1'b0;
          o_sec_alm_clk = 1'b0;
          o_min_alm_clk = 1'b0;
          o_hour_alm_clk = 1'b0;
          o_sec_tim_clk = 1'b0;
          o_min_tim_clk = 1'b0;
          o_hour_tim_clk = 1'b0;
        end
        POS_MIN : begin
          o_sec_cnt_clk = 1'b0;
          o_min_cnt_clk = ~total_sw3;
          o_hour_cnt_clk = 1'b0;
          o_sec_alm_clk = 1'b0;
          o_min_alm_clk = 1'b0;
          o_hour_alm_clk = 1'b0;
          o_sec_tim_clk = 1'b0;
          o_min_tim_clk = 1'b0;
          o_hour_tim_clk = 1'b0;
        end
        POS_HOUR : begin
          o_sec_cnt_clk = 1'b0;
          o_min_cnt_clk = 1'b0;
          o_hour_cnt_clk = ~total_sw3;
          o_sec_alm_clk = 1'b0;
          o_min_alm_clk = 1'b0;
          o_hour_alm_clk = 1'b0;
          o_sec_tim_clk = 1'b0;
          o_min_tim_clk = 1'b0;
          o_hour_tim_clk = 1'b0;
        end
      endcase
    end
    MODE_ALARM : begin
      case(o_position)
        POS_SEC : begin
          o_sec_cnt_clk = clk_1hz;
          o_min_cnt_clk = i_sec_max_hit;
          o_hour_cnt_clk = i_min_max_hit;
          o_sec_alm_clk = ~total_sw3;
          o_min_alm_clk = 1'b0;
          o_hour_alm_clk = 1'b0;
          o_sec_tim_clk = 1'b0;
          o_min_tim_clk = 1'b0;
          o_hour_tim_clk = 1'b0;
        end
        POS_MIN : begin
          o_sec_cnt_clk = clk_1hz;
          o_min_cnt_clk = i_sec_max_hit;
          o_hour_cnt_clk = i_min_max_hit;
          o_sec_alm_clk = 1'b0;
          o_min_alm_clk = ~total_sw3;
          o_hour_alm_clk = 1'b0;
          o_sec_tim_clk = 1'b0;
          o_min_tim_clk = 1'b0;
          o_hour_tim_clk = 1'b0;
        end
        POS_HOUR : begin
          o_sec_cnt_clk = clk_1hz;
          o_min_cnt_clk = i_sec_max_hit;
          o_hour_cnt_clk = i_min_max_hit;
          o_sec_alm_clk = 1'b0;
          o_min_alm_clk = 1'b0;
          o_hour_alm_clk = ~total_sw3;
          o_sec_tim_clk = 1'b0;
          o_min_tim_clk = 1'b0;
          o_hour_tim_clk = 1'b0;
        end
      endcase
    end
    MODE_TIMER : begin
      if (tim_num == STOP) begin
        case(o_position)
          POS_SEC : begin
            o_sec_cnt_clk = clk_1hz;
            o_min_cnt_clk = i_sec_max_hit;
            o_hour_cnt_clk = i_min_max_hit;
            o_sec_alm_clk = 1'b0;
            o_min_alm_clk = 1'b0;
            o_hour_alm_clk = 1'b0;
            o_sec_tim_clk = ~total_sw3;
            o_min_tim_clk = 1'b0;
            o_hour_tim_clk = 1'b0;
          end
          POS_MIN : begin
            o_sec_cnt_clk = clk_1hz;
            o_min_cnt_clk = i_sec_max_hit;
            o_hour_cnt_clk = i_min_max_hit;
            o_sec_alm_clk = 1'b0;
            o_min_alm_clk = 1'b0;
            o_hour_alm_clk = 1'b0;
            o_sec_tim_clk = 1'b0;
            o_min_tim_clk = ~total_sw3;
            o_hour_tim_clk = 1'b0;
          end
          POS_HOUR : begin
            o_sec_cnt_clk = clk_1hz;
            o_min_cnt_clk = i_sec_max_hit;
            o_hour_cnt_clk = i_min_max_hit;
            o_sec_alm_clk = 1'b0;
            o_min_alm_clk = 1'b0;
            o_hour_alm_clk = 1'b0;
            o_sec_tim_clk = 1'b0;
            o_min_tim_clk = 1'b0;
            o_hour_tim_clk = ~total_sw3;
          end
        endcase
      end else begin
        o_sec_cnt_clk = clk_1hz;
        o_min_cnt_clk = i_sec_max_hit;
        o_hour_cnt_clk = i_min_max_hit;
        o_sec_alm_clk = 1'b0;
        o_min_alm_clk = 1'b0;
        o_hour_alm_clk = 1'b0;
        o_sec_tim_clk = clk_1hz;
        o_min_tim_clk = i_sec_tim_hit;
        o_hour_tim_clk = i_min_tim_hit;
      end
    end
  endcase
end

endmodule

module ir_rx(
   output reg [31:0] o_data,
   output reg [2:0]  state,
   input i_ir_rxb,
   input i_clk,
   input i_rstn);

   localparam IDLE     = 3'b000 ;
   localparam LEADCODE = 3'b001 ; // 9ms high 4.5ms low
   localparam DATACODE = 3'b010 ; // Custom & Data Code
   localparam COMPLETE  = 3'b011; 
   localparam SEMIFINAL = 3'b100 ; // 32-bit data


   // Generate 1MHZ Clock
   wire clk_1M;
   nco u_nco(
     .o_clk (clk_1M ),
     .i_num (50 ),
     .i_clk (i_clk ),
     .i_rstn (i_rstn ));

   // Sequential Rx Bits
   wire ir_rx;
   assign ir_rx = ~i_ir_rxb;
   
   reg [1:0] seq_rx ;
   always @(posedge clk_1M or negedge i_rstn) begin
      if(!i_rstn) begin
         seq_rx <= 2'b00;
      end else begin
         seq_rx <= {seq_rx[0], ir_rx};
      end
   end

   // Count Signal Polarity (High & Low)
   reg [15:0] cnt_h ;
   reg [15:0] cnt_l ;

   always @(posedge clk_1M or negedge i_rstn) begin
     if(!i_rstn) begin
        cnt_h <= 16'd0;
        cnt_l <= 16'd0;
     end else begin
        case(seq_rx)
           2'b00 : cnt_l <= cnt_l + 1;
           2'b01 : begin
             cnt_l <= 16'd0;
             cnt_h <= 16'd0;
           end
           2'b11 : cnt_h <= cnt_h + 1;
        endcase
     end
   end

   // State Machine
   //reg [1:0] state ;
   reg [5:0] cnt32 ;
   
   always @(posedge clk_1M or negedge i_rstn) begin
      if(!i_rstn) begin
         state <= IDLE;
         cnt32 <= {6{1'b1}};
      end else begin
         case (state)
           IDLE: begin
             state <= LEADCODE;
             cnt32 <= {6{1'b1}};
           end
           LEADCODE: begin
             if (cnt_h >= 8500 && cnt_l >= 4000) begin
                state <= DATACODE;
             end else begin
                state <= LEADCODE;
             end
           end
           DATACODE: begin
             if (seq_rx == 2'b01) begin
                cnt32 <= cnt32 + 1;
             end else begin
                cnt32 <= cnt32;
             end
             if (cnt32 == 32) begin
                state <= COMPLETE;
             end else begin
                state <= DATACODE;
             end
           end
           COMPLETE : state <= SEMIFINAL;
           SEMIFINAL: state <= IDLE;
         endcase
      end
   end

   // 32bit Custom & Data Code
   reg [31:0] data ;
   always @(posedge clk_1M or negedge i_rstn) begin
      if(!i_rstn) begin
         data <= 0;
      end else begin
        case (state)
          DATACODE: begin
            if (cnt_l >= 1000) begin
               data[31-cnt32] <= 1;
            end else begin
              data[31-cnt32] <= 0;
            end
          end
          COMPLETE: o_data <= data;
        endcase
      end
   end
endmodule




module text_lcd(
    output reg                  o_lcd_e,
    output reg                  o_lcd_rs,
    output reg                  o_lcd_rw,
    inout       [7:0]           io_lcd_data,
    input       [2*16*8-1:0]    i_line_data,
    input                       i_line_data_valid,
    input                       i_clk,
    input                       i_rstn
);
// 10bits: RS & R/W & Data(8-bits)
    localparam CMD_CLEAR_DISPLAY         = 10'b00_0000_0001;
    localparam CMD_RETURN_HOME           = 10'b00_0000_0010;
    localparam CMD_ENTRY_MODE_SET        = 10'b00_0000_0110;
    localparam CMD_DISP_ONOFF_CTRL       = 10'b00_0000_1100; 
    localparam CMD_CURSOR_DISP_SHIFT     = 10'b00_0001_1000;
    localparam CMD_FUNCTION_SET          = 10'b00_0011_1100;
    localparam CMD_READ_BUSY_FLAG        = 10'b01_zzzz_zzzz;
    localparam CMD_SET_DDRAM_ADDR1       = 10'b00_1000_0000;
    localparam CMD_SET_DDRAM_ADDR2       = 10'b00_1100_0000;
    localparam CMD_WRITE_RAM_DATA        = 2'b10;
   
    `ifdef DEBUG
        reg     [127:0]         state;
        localparam IDLE         = "IDLE";
        localparam WAIT_INPUT   = "WAIT_INPUT";
        localparam BUSY_CHECK   = "BUSY_CHECK";
        localparam EXCUTE_CMD   = "EXCUTE_CMD";
    `else
        reg     [1:0]           state;
        localparam IDLE         = 0;
        localparam WAIT_INPUT   = 1;
        localparam BUSY_CHECK   = 2;
        localparam EXCUTE_CMD   = 3;
    `endif
    
    reg     [2*16*8-1:0]        line_data;
    always @(posedge i_clk or negedge i_rstn) begin
        if(!i_rstn) begin
            line_data <= 0;
        end else begin
            if(i_line_data_valid) begin
                line_data <= i_line_data;
            end else begin
                line_data <= line_data;
            end
        end
    end

    wire        clk_1mhz;
    nco u_nco(
        .o_clk      (clk_1mhz     ),
        .i_num      (50           ),
        .i_clk      (i_clk        ),
        .i_rstn     (i_rstn       ));
    reg             out_en;
    reg     [7:0]   lcd_data;
    assign          io_lcd_data = out_en? lcd_data : 8'hzz;
    
    reg     [1:0]   cnt_timing;
    reg     [7:0]   cnt_cmd;
    reg             busy_flag;

    always @(posedge clk_1mhz or negedge i_rstn) begin
        if(!i_rstn) begin
            cnt_timing <= 0;
        end else begin
            cnt_timing <= cnt_timing + 1;
        end
    end

    always @(posedge clk_1mhz or negedge i_rstn) begin
        if(!i_rstn) begin
            state <= IDLE;
            cnt_cmd <= 0;
            busy_flag <= 1;
        end else begin
            if(cnt_timing == 3) begin
                case(state)
                    IDLE: begin
                        if(i_line_data_valid) begin
                            state <= WAIT_INPUT;
                        end else begin
                            state <= IDLE;
                        end
                    end
                    WAIT_INPUT: state <= BUSY_CHECK;
                    BUSY_CHECK: begin
                        if(busy_flag == 0) begin
                            state <= EXCUTE_CMD;
                        end else begin
                            state <= BUSY_CHECK;
                         end
                    end
                    EXCUTE_CMD: begin
                        if({o_lcd_rs, o_lcd_rw, lcd_data} == CMD_RETURN_HOME) begin
                            state <= IDLE;
                            cnt_cmd <= 0;
                        end else begin
                            state <= BUSY_CHECK;
                            cnt_cmd <= cnt_cmd + 1;
                        end
                    end
                endcase
            end else begin
                if(state == BUSY_CHECK) begin
                    busy_flag <= io_lcd_data[7];
                end
            end
        end
    end

    always @(*) begin
        if(state == BUSY_CHECK) begin
            out_en = 0;
        end else begin
            out_en = 1;
        end
    end
    
    always @(*) begin
        if(cnt_timing == 1 || cnt_timing == 2) begin
            o_lcd_e = 1;
        end else begin
            o_lcd_e = 0;
        end
    end

    always @(*) begin
        case(state)
            BUSY_CHECK: begin
                {o_lcd_rs, o_lcd_rw, lcd_data} = CMD_READ_BUSY_FLAG;
            end
            EXCUTE_CMD: begin
                case(cnt_cmd)
                    00: {o_lcd_rs, o_lcd_rw, lcd_data} = CMD_CLEAR_DISPLAY;
                    01: {o_lcd_rs, o_lcd_rw, lcd_data} = CMD_FUNCTION_SET;
                    02: {o_lcd_rs, o_lcd_rw, lcd_data} = CMD_DISP_ONOFF_CTRL;
                    03: {o_lcd_rs, o_lcd_rw, lcd_data} = CMD_ENTRY_MODE_SET;
                    04: {o_lcd_rs, o_lcd_rw, lcd_data} = CMD_SET_DDRAM_ADDR1;
                    05: {o_lcd_rs, o_lcd_rw, lcd_data} = {CMD_WRITE_RAM_DATA, line_data[(2*16*8-1-00*8)-:8]};
                    06: {o_lcd_rs, o_lcd_rw, lcd_data} = {CMD_WRITE_RAM_DATA, line_data[(2*16*8-1-01*8)-:8]};
                    07: {o_lcd_rs, o_lcd_rw, lcd_data} = {CMD_WRITE_RAM_DATA, line_data[(2*16*8-1-02*8)-:8]};
                    08: {o_lcd_rs, o_lcd_rw, lcd_data} = {CMD_WRITE_RAM_DATA, line_data[(2*16*8-1-03*8)-:8]};
                    09: {o_lcd_rs, o_lcd_rw, lcd_data} = {CMD_WRITE_RAM_DATA, line_data[(2*16*8-1-04*8)-:8]};
                    10: {o_lcd_rs, o_lcd_rw, lcd_data} = {CMD_WRITE_RAM_DATA, line_data[(2*16*8-1-05*8)-:8]};
                    11: {o_lcd_rs, o_lcd_rw, lcd_data} = {CMD_WRITE_RAM_DATA, line_data[(2*16*8-1-06*8)-:8]};
                    12: {o_lcd_rs, o_lcd_rw, lcd_data} = {CMD_WRITE_RAM_DATA, line_data[(2*16*8-1-07*8)-:8]};
                    13: {o_lcd_rs, o_lcd_rw, lcd_data} = {CMD_WRITE_RAM_DATA, line_data[(2*16*8-1-08*8)-:8]};
                    14: {o_lcd_rs, o_lcd_rw, lcd_data} = {CMD_WRITE_RAM_DATA, line_data[(2*16*8-1-09*8)-:8]};
                    15: {o_lcd_rs, o_lcd_rw, lcd_data} = {CMD_WRITE_RAM_DATA, line_data[(2*16*8-1-10*8)-:8]};
                    16: {o_lcd_rs, o_lcd_rw, lcd_data} = {CMD_WRITE_RAM_DATA, line_data[(2*16*8-1-11*8)-:8]};
                    17: {o_lcd_rs, o_lcd_rw, lcd_data} = {CMD_WRITE_RAM_DATA, line_data[(2*16*8-1-12*8)-:8]};
                    18: {o_lcd_rs, o_lcd_rw, lcd_data} = {CMD_WRITE_RAM_DATA, line_data[(2*16*8-1-13*8)-:8]};
                    19: {o_lcd_rs, o_lcd_rw, lcd_data} = {CMD_WRITE_RAM_DATA, line_data[(2*16*8-1-14*8)-:8]};
                    20: {o_lcd_rs, o_lcd_rw, lcd_data} = {CMD_WRITE_RAM_DATA, line_data[(2*16*8-1-15*8)-:8]};
                    21: {o_lcd_rs, o_lcd_rw, lcd_data} = CMD_SET_DDRAM_ADDR2;
                    22: {o_lcd_rs, o_lcd_rw, lcd_data} = {CMD_WRITE_RAM_DATA, line_data[(2*16*8-1-16*8)-:8]};
                    23: {o_lcd_rs, o_lcd_rw, lcd_data} = {CMD_WRITE_RAM_DATA, line_data[(2*16*8-1-17*8)-:8]};
                    24: {o_lcd_rs, o_lcd_rw, lcd_data} = {CMD_WRITE_RAM_DATA, line_data[(2*16*8-1-18*8)-:8]};
                    25: {o_lcd_rs, o_lcd_rw, lcd_data} = {CMD_WRITE_RAM_DATA, line_data[(2*16*8-1-19*8)-:8]};
                    26: {o_lcd_rs, o_lcd_rw, lcd_data} = {CMD_WRITE_RAM_DATA, line_data[(2*16*8-1-20*8)-:8]};
                    27: {o_lcd_rs, o_lcd_rw, lcd_data} = {CMD_WRITE_RAM_DATA, line_data[(2*16*8-1-21*8)-:8]};
                    28: {o_lcd_rs, o_lcd_rw, lcd_data} = {CMD_WRITE_RAM_DATA, line_data[(2*16*8-1-22*8)-:8]};
                    29: {o_lcd_rs, o_lcd_rw, lcd_data} = {CMD_WRITE_RAM_DATA, line_data[(2*16*8-1-23*8)-:8]};
                    30: {o_lcd_rs, o_lcd_rw, lcd_data} = {CMD_WRITE_RAM_DATA, line_data[(2*16*8-1-24*8)-:8]};
                    31: {o_lcd_rs, o_lcd_rw, lcd_data} = {CMD_WRITE_RAM_DATA, line_data[(2*16*8-1-25*8)-:8]};
                    32: {o_lcd_rs, o_lcd_rw, lcd_data} = {CMD_WRITE_RAM_DATA, line_data[(2*16*8-1-26*8)-:8]};
                    33: {o_lcd_rs, o_lcd_rw, lcd_data} = {CMD_WRITE_RAM_DATA, line_data[(2*16*8-1-27*8)-:8]};
                    34: {o_lcd_rs, o_lcd_rw, lcd_data} = {CMD_WRITE_RAM_DATA, line_data[(2*16*8-1-28*8)-:8]};
                    35: {o_lcd_rs, o_lcd_rw, lcd_data} = {CMD_WRITE_RAM_DATA, line_data[(2*16*8-1-29*8)-:8]};
                    36: {o_lcd_rs, o_lcd_rw, lcd_data} = {CMD_WRITE_RAM_DATA, line_data[(2*16*8-1-30*8)-:8]};
                    37: {o_lcd_rs, o_lcd_rw, lcd_data} = {CMD_WRITE_RAM_DATA, line_data[(2*16*8-1-31*8)-:8]};
                    38: {o_lcd_rs, o_lcd_rw, lcd_data} = CMD_RETURN_HOME;
                endcase
            end
        endcase
    end
endmodule

module dec_to_lcd(
   output reg [7:0] o_lcd,
   input      [3:0] i_num
);

    always @(*) begin
        case(i_num)
            4'd0:    o_lcd = 8'd48;
            4'd1:    o_lcd = 8'd49;
            4'd2:    o_lcd = 8'd50;
            4'd3:    o_lcd = 8'd51;
            4'd4:    o_lcd = 8'd52;
            4'd5:    o_lcd = 8'd53;
            4'd6:    o_lcd = 8'd54;
            4'd7:    o_lcd = 8'd55;
            4'd8:    o_lcd = 8'd56;
            4'd9:    o_lcd = 8'd57;
            default: o_lcd = 8'd48;
        endcase
    end

endmodule


module text_lcd_controller (
   output reg  [2*16*8-1:0]    line_data,
   output reg                  line_data_valid,
   input       [1:0]           i_mode,
   input       [5:0]           i_sec_alarm,
   input       [5:0]           i_min_alarm,
   input       [5:0]           i_hour_alarm,
   input                       alarm_en,
   input                       i_clk,
   input                       i_rstn
);

    localparam   MODE_CLOCK = 2'b00;
    localparam   MODE_SETUP = 2'b01;
    localparam   MODE_ALARM = 2'b10;
    localparam   MODE_TIMER = 2'b11;

    localparam CHAR_COLON   = 8'd58;
    localparam CHAR_SPACE   = 8'd20;
    localparam CHAR_A       = 8'd65;
    localparam CHAR_B       = 8'd66;
    localparam CHAR_C       = 8'd67;
    localparam CHAR_D       = 8'd68;
    localparam CHAR_E       = 8'd69;
    localparam CHAR_F       = 8'd70;
    localparam CHAR_G       = 8'd71;
    localparam CHAR_H       = 8'd72;
    localparam CHAR_I       = 8'd73;
    localparam CHAR_J       = 8'd74;
    localparam CHAR_K       = 8'd75;
    localparam CHAR_L       = 8'd76;
    localparam CHAR_M       = 8'd77;
    localparam CHAR_N       = 8'd78;
    localparam CHAR_O       = 8'd79;
    localparam CHAR_P       = 8'd80;
    localparam CHAR_Q       = 8'd81;
    localparam CHAR_R       = 8'd82;
    localparam CHAR_S       = 8'd83;
    localparam CHAR_T       = 8'd84;
    localparam CHAR_U       = 8'd85;
    localparam CHAR_V       = 8'd86;
    localparam CHAR_W       = 8'd87;
    localparam CHAR_X       = 8'd88;
    localparam CHAR_Y       = 8'd89;
    localparam CHAR_Z       = 8'd90;

    localparam CHAR_0       = 8'd48;
    localparam CHAR_1       = 8'd49;
    localparam CHAR_2       = 8'd50;
    localparam CHAR_3       = 8'd51;
    localparam CHAR_4       = 8'd52;
    localparam CHAR_5       = 8'd53;
    localparam CHAR_6       = 8'd54;
    localparam CHAR_7       = 8'd55;
    localparam CHAR_8       = 8'd56;
    localparam CHAR_9       = 8'd57;

    
    wire   [3:0]   o_digit_lcd_s_l;
    wire   [3:0]   o_digit_lcd_s_r;
    num_split#(
        .RANGE   (60))
    u_num_split_lcd_sec(
        .o_digit_l (o_digit_lcd_s_l),
        .o_digit_r (o_digit_lcd_s_r),
        .i_num     (i_sec_alarm    ));

    wire   [3:0]   o_digit_lcd_m_l;
    wire   [3:0]   o_digit_lcd_m_r;
    num_split#(
        .RANGE   (60)) 
    u_num_split_lcd_min(
        .o_digit_l (o_digit_lcd_m_l),
        .o_digit_r (o_digit_lcd_m_r),
        .i_num     (i_min_alarm    ));

    wire   [3:0]   o_digit_lcd_h_l;
    wire   [3:0]   o_digit_lcd_h_r;
    num_split#(
        .RANGE   (24))
    u_num_split_lcd_hour(
        .o_digit_l (o_digit_lcd_h_l),
        .o_digit_r (o_digit_lcd_h_r),
        .i_num     (i_hour_alarm   ));


    wire   [7:0]      lcd_h_l;
    dec_to_lcd      u_dec_to_lcd_h_l(
        .o_lcd         (lcd_h_l       ),
        .i_num         (o_digit_lcd_h_l));   

    wire   [7:0]      lcd_h_r;
    dec_to_lcd      u_dec_to_lcd_h_r(
        .o_lcd         (lcd_h_r      ),
        .i_num         (o_digit_lcd_h_r));      

    wire   [7:0]      lcd_m_l;
    dec_to_lcd      u_dec_to_lcd_m_l(
        .o_lcd         (lcd_m_l       ),
        .i_num         (o_digit_lcd_m_l));      

    wire   [7:0]      lcd_m_r;
    dec_to_lcd      u_dec_to_lcd_m_r(
        .o_lcd         (lcd_m_r      ),
        .i_num         (o_digit_lcd_m_r));   
    
    wire   [7:0]      lcd_s_l;
    dec_to_lcd      u_dec_to_lcd_s_l(
        .o_lcd         (lcd_s_l       ),
        .i_num         (o_digit_lcd_s_l));      


    wire   [7:0]      lcd_s_r;
    dec_to_lcd      u_dec_to_lcd_s_r( 
        .o_lcd         (lcd_s_r       ),
        .i_num         (o_digit_lcd_s_r));


    reg [2*16*8-1:0] line_data0;

    always @(*) begin
        case(i_mode)
            MODE_CLOCK : begin
                case(alarm_en)
                    0 :line_data0 = {CHAR_SPACE, CHAR_SPACE, CHAR_SPACE, CHAR_C, CHAR_L, CHAR_O, CHAR_C, CHAR_K, CHAR_SPACE, CHAR_M, CHAR_O, CHAR_D, CHAR_E, CHAR_SPACE, CHAR_SPACE, CHAR_SPACE, CHAR_SPACE, CHAR_SPACE, CHAR_A, CHAR_L, CHAR_A, CHAR_R, CHAR_M, CHAR_SPACE, CHAR_I, CHAR_S, CHAR_SPACE, CHAR_O, CHAR_F, CHAR_F, CHAR_SPACE, CHAR_SPACE};
                    
                    1 :line_data0 = {CHAR_SPACE, CHAR_SPACE, CHAR_SPACE, CHAR_C, CHAR_L, CHAR_O, CHAR_C, CHAR_K, CHAR_SPACE, CHAR_M, CHAR_O, CHAR_D, CHAR_E, CHAR_SPACE, CHAR_SPACE, CHAR_SPACE, CHAR_A, CHAR_L, CHAR_A, CHAR_R, CHAR_M, CHAR_SPACE, CHAR_COLON, CHAR_SPACE, lcd_h_l, lcd_h_r, CHAR_COLON, lcd_m_l, lcd_m_r, CHAR_COLON, lcd_s_l, lcd_s_r};                       
                endcase
            end
             MODE_SETUP : begin
                 case(alarm_en)
                    0 :line_data0 = {CHAR_SPACE, CHAR_SPACE, CHAR_SPACE, CHAR_S, CHAR_E, CHAR_T, CHAR_U, CHAR_P, CHAR_SPACE, CHAR_M, CHAR_O, CHAR_D, CHAR_E, CHAR_SPACE, CHAR_SPACE, CHAR_SPACE, CHAR_SPACE, CHAR_SPACE, CHAR_A, CHAR_L, CHAR_A, CHAR_R, CHAR_M, CHAR_SPACE, CHAR_I, CHAR_S, CHAR_SPACE, CHAR_O, CHAR_F, CHAR_F, CHAR_SPACE, CHAR_SPACE};
                        
                    1 :line_data0 = {CHAR_SPACE, CHAR_SPACE, CHAR_SPACE, CHAR_S, CHAR_E, CHAR_T, CHAR_U, CHAR_P, CHAR_SPACE, CHAR_M, CHAR_O, CHAR_D, CHAR_E, CHAR_SPACE, CHAR_SPACE, CHAR_SPACE, CHAR_A, CHAR_L, CHAR_A, CHAR_R, CHAR_M, CHAR_SPACE, CHAR_COLON, CHAR_SPACE, lcd_h_l, lcd_h_r, CHAR_COLON, lcd_m_l, lcd_m_r, CHAR_COLON, lcd_s_l, lcd_s_r};                       
                endcase
            end
        
            MODE_ALARM : begin
                 case(alarm_en)
                    0 :line_data0 = {CHAR_SPACE, CHAR_SPACE, CHAR_SPACE, CHAR_A, CHAR_L, CHAR_A, CHAR_R, CHAR_M, CHAR_SPACE, CHAR_M, CHAR_O, CHAR_D, CHAR_E, CHAR_SPACE, CHAR_SPACE, CHAR_SPACE, CHAR_SPACE, CHAR_SPACE, CHAR_A, CHAR_L, CHAR_A, CHAR_R, CHAR_M, CHAR_SPACE, CHAR_I, CHAR_S, CHAR_SPACE, CHAR_O, CHAR_F, CHAR_F, CHAR_SPACE, CHAR_SPACE};
                    
                    1 :line_data0 = {CHAR_SPACE, CHAR_SPACE, CHAR_SPACE, CHAR_A, CHAR_L, CHAR_A, CHAR_R, CHAR_M, CHAR_SPACE, CHAR_M, CHAR_O, CHAR_D, CHAR_E, CHAR_SPACE, CHAR_SPACE, CHAR_SPACE, CHAR_A, CHAR_L, CHAR_A, CHAR_R, CHAR_M, CHAR_SPACE, CHAR_COLON, CHAR_SPACE, lcd_h_l, lcd_h_r, CHAR_COLON, lcd_m_l, lcd_m_r, CHAR_COLON, lcd_s_l, lcd_s_r};
                                                

                endcase
            end

            MODE_TIMER : begin
                 case(alarm_en)
                    0 :line_data0 = {CHAR_SPACE, CHAR_SPACE, CHAR_SPACE, CHAR_T, CHAR_I, CHAR_M, CHAR_E, CHAR_R, CHAR_SPACE, CHAR_M, CHAR_O, CHAR_D, CHAR_E, CHAR_SPACE, CHAR_SPACE, CHAR_SPACE, CHAR_SPACE, CHAR_SPACE, CHAR_A, CHAR_L, CHAR_A, CHAR_R, CHAR_M, CHAR_SPACE, CHAR_I, CHAR_S, CHAR_SPACE, CHAR_O, CHAR_F, CHAR_F, CHAR_SPACE, CHAR_SPACE};
              
                    1 :line_data0 = {CHAR_SPACE, CHAR_SPACE, CHAR_SPACE, CHAR_T, CHAR_I, CHAR_M, CHAR_E, CHAR_R, CHAR_SPACE, CHAR_M, CHAR_O, CHAR_D, CHAR_E, CHAR_SPACE, CHAR_SPACE, CHAR_SPACE, CHAR_SPACE, CHAR_SPACE, CHAR_A, CHAR_L, CHAR_A, CHAR_R, CHAR_M, CHAR_SPACE, CHAR_I, CHAR_S, CHAR_SPACE, CHAR_O, CHAR_F, CHAR_F, CHAR_SPACE, CHAR_SPACE};
                endcase
            end
        endcase
    end


    `ifdef DEBUG
        localparam NCO_LINE_DATA = 50;
    `else
        localparam NCO_LINE_DATA = 50000000;
    `endif


    wire                    clk_1hz;
    reg     [4:0]           cnt;
    nco u_nco(
        .o_clk      (clk_1hz        ),
        .i_num      (NCO_LINE_DATA  ),
        .i_clk      (i_clk          ),
        .i_rstn     (i_rstn         ));

    always @(posedge clk_1hz or negedge i_rstn) begin
        if(!i_rstn) begin
            line_data <= 0;
            line_data_valid <= 0;
            cnt <= 0;
        end else begin
            if(cnt == 0) begin
                line_data <= line_data0;
                line_data_valid <= 1;
                cnt <= cnt + 1;
            end else if(cnt == 1) begin
                line_data <= 0;
                line_data_valid <= 0;
                cnt <= 0;
            end else begin
                line_data <= 0;
                line_data_valid <= 0;
                cnt <= cnt + 1;
            end
        end
    end

endmodule



module top_project(
    input           i_clk,
    input           i_rstn,
    input   [7:0]   i_sw,
    input           i_ir_rxb,
    
    output  [6:0]   o_seg,
    output          o_seg_dp,
    output  [5:0]   o_seg_enb,
    output          o_buzz,
   output                  o_lcd_e,
   output                  o_lcd_rs,
   output                  o_lcd_rw,
   inout          [7:0]    io_lcd_data
);

    wire [6*7-1:0]      six_seg;
    wire [6*7-1:0]      o_six_seg;
    wire [5:0]          six_seg_dp;
    wire                o_sec_max_hit;
    wire                o_min_max_hit;
    wire                o_hour_max_hit;
    wire                o_sec_tim_hit;
    wire                o_min_tim_hit;
    wire                o_hour_tim_hit;
    wire [1:0]          o_position;
    wire                o_cal;
    wire                tim_num;
    wire                o_alarm;
    wire                o_alarm_en;
    wire                o_sec_cnt_clk;
    wire                o_min_cnt_clk;
    wire                o_hour_cnt_clk;
    wire                o_sec_alm_clk;
    wire                o_min_alm_clk;
    wire                o_hour_alm_clk;
    wire                o_sec_tim_clk;
    wire                o_min_tim_clk;
    wire                o_hour_tim_clk;
    wire [5:0]          o_sec;
    wire [5:0]          o_min;
    wire [5:0]          o_hour;
    wire   [5:0]   sec_alarm    ;
    wire   [5:0]   min_alarm    ;
    wire   [5:0]   hour_alarm   ;

   `ifdef DEBUG
    localparam NCO_DEBOUNCE = 4;
   `else
    localparam NCO_DEBOUNCE = 1000000;
   `endif

   localparam MODE_CLOCK = 1'b0;
   localparam MODE_SETUP = 1'b1;
   localparam POS_SEC = 1'b0;
   localparam POS_MIN = 1'b1;
   
   localparam RANGE = 60;
   `ifdef DEBUG
       localparam NCO_NUM_1HZ = 4;
   `else
       localparam NCO_NUM_1HZ = 50000000;
   `endif

    `ifdef DEBUG
     localparam NCO_LED_SPEED = 2;
    `else
     localparam NCO_LED_SPEED = 100000;
    `endif

    wire [31:0]        o_data;
    wire  [2:0]         state;

    ir_rx u_ir_rx(
      .o_data         (o_data),
      .state          (state  ),
      .i_ir_rxb       (i_ir_rxb),
      .i_clk          (i_clk),
      .i_rstn         (i_rstn));

    wire [7:0] o_sw;
    switch_debounce u_switch_debounce (
        .o_sw (o_sw),
        .i_sw (i_sw),
        .i_clk (i_clk),
        .i_rstn (i_rstn)
    );
    wire [1:0] o_mode;
    controller_team u_controller_team (

        .o_mode            (o_mode),
        .o_cal             (o_cal  ),
        .tim_num           (tim_num   ),
        .o_position        (o_position),
        .o_sec_cnt_clk     (o_sec_cnt_clk),
        .o_min_cnt_clk     (o_min_cnt_clk),
        .o_hour_cnt_clk    (o_hour_cnt_clk),
        .o_sec_alm_clk     (o_sec_alm_clk),
        .o_min_alm_clk     (o_min_alm_clk),
        .o_hour_alm_clk    (o_hour_alm_clk),
        .o_sec_tim_clk     (o_sec_tim_clk),
        .o_min_tim_clk     (o_min_tim_clk),
        .o_hour_tim_clk    (o_hour_tim_clk),
        .i_sec_max_hit     (o_sec_max_hit),
        .i_min_max_hit     (o_min_max_hit),
        .i_hour_max_hit    (o_hour_max_hit),
        .i_sec_tim_hit     (o_sec_tim_hit),
        .i_min_tim_hit     (o_min_tim_hit),
        .i_hour_tim_hit    (o_hour_tim_hit),
        .i_sw              (o_sw),
        .o_data            (o_data),
        .i_clk             (i_clk),
        .o_alarm_en        (o_alarm_en),
        .i_rstn            (i_rstn),
        .state              (state)
    );

    buzz u_buzz_team(
        .o_buzz     (o_buzz),
        .i_buzz_en  (o_alarm),
        .i_clk      (i_clk),
        .i_rstn     (i_rstn)
    );

    minsec_team u_minsec (

        .o_sec           (o_sec),
        .o_min           (o_min),
        .o_hour          (o_hour),
            .o_sec_alarm         (   sec_alarm         ),
    .o_min_alarm         (   min_alarm         ),
    .o_hour_alarm        (   hour_alarm        ),
        .o_sec_max_hit   (o_sec_max_hit),
        .o_min_max_hit   (o_min_max_hit),
        .o_hour_max_hit  (o_hour_max_hit),
        .o_sec_tim_hit     (o_sec_tim_hit),
        .o_min_tim_hit     (o_min_tim_hit),
        .o_hour_tim_hit    (o_hour_tim_hit),
        .o_alarm         (o_alarm),
        .i_mode          (o_mode),
        .i_cal           (o_cal),
        .tim_num         (tim_num),
        .i_alarm_en      (o_alarm_en),
        .i_sec_cnt_clk   (o_sec_cnt_clk),
        .i_min_cnt_clk   (o_min_cnt_clk),
        .i_hour_cnt_clk  (o_hour_cnt_clk),
        .i_sec_alm_clk   (o_sec_alm_clk),
        .i_min_alm_clk   (o_min_alm_clk),
        .i_hour_alm_clk  (o_hour_alm_clk),
        .i_sec_tim_clk   (o_sec_tim_clk),
        .i_min_tim_clk   (o_min_tim_clk),
        .i_hour_tim_clk  (o_hour_tim_clk),
        .i_clk           (i_clk),
        .i_rstn          (i_rstn)
    );


    wire [3:0] digit_l0;
    wire [3:0] digit_r0;
    num_split #(
        .RANGE(RANGE)
    ) u_num_split_min (
        .o_digit_l (digit_l0),
        .o_digit_r (digit_r0),
        .i_num (o_sec)
    );

    wire [6:0] seg_l0;
    dec_to_seg u_dec_to_seg_l0(
        .o_seg (seg_l0),
        .i_num (digit_l0)
    );

    wire [6:0] seg_r0;
    dec_to_seg u_dec_to_seg_r0(
        .o_seg (seg_r0),
        .i_num (digit_r0)
    );

    wire [3:0] digit_l1;
    wire [3:0] digit_r1;
    num_split #(
        .RANGE(RANGE)
    ) u_num_split_sec (
        .o_digit_l (digit_l1),
        .o_digit_r (digit_r1),
        .i_num (o_min)
    );

    wire [6:0] seg_l1;
    dec_to_seg u_dec_to_seg_l1(
        .o_seg (seg_l1),
        .i_num (digit_l1)
    );
    wire [6:0] seg_r1;
    dec_to_seg u_dec_to_seg_r1(
        .o_seg (seg_r1),
        .i_num (digit_r1)
    );

    wire [3:0] digit_l2;
    wire [3:0] digit_r2;
    num_split #(
        .RANGE(RANGE)
    ) u_num_split_hour (
        .o_digit_l (digit_l2),
        .o_digit_r (digit_r2),
        .i_num (o_hour)
    );

    wire [6:0] seg_l2;
    dec_to_seg u_dec_to_seg_l2(
        .o_seg (seg_l2),
        .i_num (digit_l2)
    );

    wire [6:0] seg_r2;
    dec_to_seg u_dec_to_seg_r2(
        .o_seg (seg_r2),
        .i_num (digit_r2)
    );

    wire [1:0] mode;

    assign mode = (o_mode == 2'b00) ? 2'b00 :
                  (o_mode == 2'b01) ? 2'b10 :
                  (o_mode == 2'b10) ? 2'b01 :
                   2'b11;

    assign six_seg = {seg_l2, seg_r2, seg_l1, seg_r1, seg_l0, seg_r0};

    blink   u_blink(

       .i_position        (o_position),
           .i_mode            (o_mode),
           .tim_num            (tim_num),
        .i_six_seg         (six_seg),      
          .i_clk             (i_clk),
          .i_rstn            (i_rstn),
          .o_six_seg         (o_six_seg));
    
    led_ctrl #(
        .NCO_LED_SPEED (NCO_LED_SPEED)
    ) u_led_ctrl (
        .o_seg (o_seg),
        .o_seg_dp (o_seg_dp),
        .o_seg_enb (o_seg_enb),
        .i_six_seg (o_six_seg),
        .i_six_seg_dp ({3{mode}}),
        .i_clk (i_clk),
        .i_rstn (i_rstn)
    );

    wire    [2*16*8-1:0]    line_data;
    wire                    line_data_valid;
    
    text_lcd_controller u_text_lcd_controller(
        .line_data          (line_data          ),
        .line_data_valid    (line_data_valid    ),
        .i_mode             (o_mode               ),
        .i_sec_alarm        (sec_alarm          ),
        .i_min_alarm        (min_alarm          ),
        .i_hour_alarm       (hour_alarm         ),
        .alarm_en           (o_alarm_en           ),
        .i_clk              (i_clk              ),
        .i_rstn             (i_rstn             ));


        text_lcd u_text_lcd(
        .o_lcd_e            (o_lcd_e         ),
        .o_lcd_rs           (o_lcd_rs        ),
        .o_lcd_rw           (o_lcd_rw        ),
        .io_lcd_data        (io_lcd_data     ),
        .i_line_data        (line_data       ),
        .i_line_data_valid  (line_data_valid ),
        .i_clk              (i_clk           ),
        .i_rstn             (i_rstn          ));



endmodule
