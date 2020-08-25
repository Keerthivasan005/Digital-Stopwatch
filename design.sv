//// Code your design here
module debounce(input ip_btn, clk, output out);
  reg mid_state1, mid_state2;
  
  assign out = mid_state1 && (!mid_state2);
  
  always @(posedge clk)
    begin
      mid_state1 <= ip_btn;
      mid_state2 <= mid_state1;
    end
  
endmodule

module reset_load(input ip_btn, clk, master_reset, output reset, load);
  wire sync_ip;
  reg [1:0] state;
  parameter reset_state = 2'b00, reset_mid = 2'b01, load_mid = 2'b10, load_state = 2'b11;
  
  debounce d0(ip_btn, clk, sync_ip);
  assign reset = !(state[0] || state[1]);
  assign load = state[0] && state[1];
  
  always @(posedge clk, posedge master_reset)
    begin
      if(master_reset)
        state <= 2'b0;
      else
        case(state)
          reset_state: 	if(sync_ip)
            				state <= load_state;
            			else
                          	state <= reset_mid;
          reset_mid: 	if(sync_ip)
            				state <= load_state;
          				else
                          	state <= reset_mid;
          load_mid: 	if(sync_ip)
            				state <= reset_state;
          				else
                          	state <= load_mid;
          load_state: 	if(sync_ip)
            				state <= reset_state;
          				else
                          	state <= load_mid;
          default:		state <= reset_state;
        endcase
    end
  
endmodule

module start_stop(input ip_btn, clk, master_reset, output start, stop);
  wire sync_ip;
  reg state;
  parameter start_state = 1'b1, stop_state = 1'b0;
  
  debounce d1(ip_btn, clk, sync_ip);
  assign stop = !(state);
  assign start = state;
  
  always @(posedge clk, posedge master_reset)
    begin
      if(master_reset)
        state <= stop_state;
      else
        case(state)
          stop_state: 	if(sync_ip)
            				state <= start_state;
          				else
                          	state <= stop_state;
          start_state: 	if(sync_ip)
            				state <= stop_state;
          				else
                          	state <= start_state;
          default: 		state<= stop_state;
        endcase
    end
  
endmodule

module mod_n_counter(input clk, input [3:0] load_val, input reset, load, count_enable, up_down, input [3:0] mod_n, output reg [3:0] Q, output reg C_out);
  
  always @(posedge clk, posedge reset, posedge load)
    if(reset)
      begin
        Q <= 4'b0;
        C_out <= 1'b0;
      end
    else
      if(load)
        begin
          Q <= load_val;
          C_out <= 1'b0;
        end
  	  else
        if(count_enable)
          if(up_down)
            if(Q == 4'b0)
            	begin
                	Q <= mod_n - 1;
                    C_out <= 1'b1;
                end
          	else
                begin
                    Q <= Q - 1;
                    C_out <= 1'b0;
                end
          else
            if(Q == mod_n - 1)
            	begin
                   	Q <= 4'b0;
            		C_out <= 1;
                end
          	else
                begin
                    Q <= Q + 1;
                    C_out <= 1'b0;
                end
  		else
          begin
           	Q <= Q;
  			C_out <= C_out;
          end
  
endmodule
            
module freq_divider(input clk, reset, stop, output reg div_clk);
  reg [31:0] counter;
  integer n_freq = 5_00_000;			// change the frequency depending upon the boards frequency
  
  always @(posedge clk, posedge reset)
    if(reset)
      begin
      	div_clk <= 1'b0;
        counter <= 32'b0;
      end
  	else
      if(stop)
        begin
        	div_clk <= div_clk;
          	counter <= counter;
        end
  	  else
        if(counter == n_freq)
          begin
          	div_clk <= ~div_clk;
            counter <= 32'b0;
          end
        else
          begin
          	counter <= counter + 1;
          	div_clk <= div_clk;
          end
          
endmodule
      
module stopwatch(input master_reset, button_rl, button_ss, up_down, clk, input [15:0] load_val, output [3:0] activate_anode, output [6:0] LED_out);
  wire reset, load, start, stop;
  wire div_clk;
  wire carry_clk0, carry_clk1, carry_clk2, carry_clk3;
  parameter [3:0] binary_10 = 4'b1010;
  parameter [3:0] binary_6 = 4'b0110;
  wire count_enable;
  wire [15:0] Q;
  
  reset_load r0(button_rl, clk, master_reset, reset, load);
  start_stop s0(button_ss, clk, master_reset, start, stop);
  
  assign count_enable = start;
  
  freq_divider f0(clk, reset, stop, div_clk);
  
  mod_n_counter counter0(div_clk, load_val[3:0], reset, load, count_enable, up_down, binary_10, Q[3:0], carry_clk0);
  mod_n_counter counter1(carry_clk0, load_val[7:4], reset, load, count_enable,up_down, binary_10, Q[7:4], carry_clk1);
  mod_n_counter counter2(carry_clk1, load_val[11:8], reset, load, count_enable,up_down, binary_10, Q[11:8], carry_clk2);
  mod_n_counter counter3(carry_clk2, load_val[15:12], reset, load, count_enable,up_down, binary_6, Q[15:12], carry_clk3);
  
  seven_segment_display ssd0(clk, master_reset, Q, activate_anode, LED_out);
  
endmodule
  
module seven_segment_display(input clk, master_reset, input [15:0] Q, output reg [3:0] Anode_Activate, output reg [6:0] LED_out);
  parameter [5:0] n = 19;			// can change the refresh rate here
  reg [n:0] refresh_counter; 
    reg [3:0] LED_BCD;
    wire [1:0] LED_activating_counter; 
  always @(posedge clk, posedge master_reset)
    begin 
      if(master_reset)
            refresh_counter <= 0;
        else
            refresh_counter <= refresh_counter + 1;
    end 
  assign LED_activating_counter = refresh_counter[n:n-1];
    
  always @(*)
    begin
        case(LED_activating_counter)
        2'b00: begin
            Anode_Activate = 4'b0111;  // 7
            // activate LED1 and Deactivate LED2, LED3, LED4
            LED_BCD = Q[3:0];
            // the first hex-digit of the 16-bit number
             end
        2'b01: begin
            Anode_Activate = 4'b1011; //11 b
            // activate LED2 and Deactivate LED1, LED3, LED4
          LED_BCD = Q[7:4];
            // the second hex-digit of the 16-bit number
                end
        2'b10: begin
            Anode_Activate = 4'b1101; //13 d
            // activate LED3 and Deactivate LED2, LED1, LED4
          LED_BCD = Q[11:8];
             // the third hex-digit of the 16-bit number
              end
        2'b11: begin
            Anode_Activate = 4'b1110; // e
            // activate LED4 and Deactivate LED2, LED3, LED1
          LED_BCD = Q[15:12];
             // the fourth hex-digit of the 16-bit number 
               end   
        default:begin
             Anode_Activate = 4'b0111; 
            // activate LED1 and Deactivate LED2, LED3, LED4
            LED_BCD = Q[3:0];
            // the first hex-digit of the 16-bit number
            end
        endcase
    end
    always @(*)
    begin
     case(LED_BCD)
     4'b0000: LED_out = 7'b0000001; // "0"  //h01
     4'b0001: LED_out = 7'b1001111; // "1" 	//h4F
     4'b0010: LED_out = 7'b0010010; // "2" 	//h12
     4'b0011: LED_out = 7'b0000110; // "3" 	//h06
     4'b0100: LED_out = 7'b1001100; // "4" 	//h4C
     4'b0101: LED_out = 7'b0100100; // "5" 	//h24
     4'b0110: LED_out = 7'b0100000; // "6" 	//h20
     4'b0111: LED_out = 7'b0001111; // "7" 	//h0F
     4'b1000: LED_out = 7'b0000000; // "8"  //h00
     4'b1001: LED_out = 7'b0000100; // "9" 	//h04
     default: LED_out = 7'b0000001; // "0"	//h01
     endcase
    end
endmodule 