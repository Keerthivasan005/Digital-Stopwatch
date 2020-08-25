// Code your testbench here
// or browse Examples

/* De-Comment this module to test reset-load state transitions
module t_state_trans_check;
  reg clk, ip_btn, reset_b;
  wire reset, load;
  reset_load MUT(ip_btn, clk, reset_b, reset, load);
  
  always #1 clk = ~ clk;
    
  initial
    begin
    clk = 0; reset_b = 0; ip_btn = 0;
    $dumpfile("dump.vcd");
    $dumpvars(0,t_state_trans_check);
    $monitor($time, " clk = %2d, input = %b, reset_button = %b, reset_out = %b, load_out = %b, state = %2b", clk, ip_btn, reset_b, reset, load, MUT.state);
    end
  
    
  initial fork
    #3 reset_b = 1;
    #6 reset_b = 0;
    
    #9  ip_btn = 1;			// load
    #11 ip_btn = 0;
    #15 ip_btn = 1;			// reset
    #18 ip_btn = 0;
    #26 ip_btn = 1;			// load
    #30 ip_btn = 0;
    #35 ip_btn = 1;			// reset
    #40 $finish;  
  join
endmodule
*/

/* De-comment this block to check start-stop
module t_state_trans_check;
  wire start, stop;
  reg ip_btn, clk, reset_b;
  start_stop MUT(ip_btn, clk, reset_b, start, stop);
  
  always #1 clk = ~clk;
  
  initial fork
    clk = 0; reset_b = 0; ip_btn = 0;
    $dumpfile("dump.vcd");
    $dumpvars(0,t_state_trans_check);
    $monitor($time, " clk = %2d, input = %b, reset_button = %b, stop = %b, start = %b, state = %b", clk, ip_btn, reset_b, stop, start, MUT.state);
    
    #3 reset_b = 1;
    #6 reset_b = 0;
    
    #8  ip_btn = 1;		// start
    #11 ip_btn = 0;
    #15 ip_btn = 1;		// stop
    #19 ip_btn = 0; 
    #25 ip_btn = 1;		// start
    #30 ip_btn = 0;
    #31 $finish;
  join
  
endmodule
*/    

/* De-comment this module to check counter
module t_counter;
  wire [3:0] Q;
  wire C_out;
  reg clk, reset, load,count_enable, up_down;
  reg [3:0] load_val, mod_n;
  mod_n_counter MUT(clk, load_val, reset, load, count_enable, up_down, mod_n, Q, C_out);
  
  always #2 clk = ~clk;
  
  always @(reset, load, load_val, count_enable, up_down)
    $display("reset = %b, load = %b, load_val = %4b, count_enable = %b, up_down = %b", reset, load, load_val, count_enable, up_down);  
  
  initial fork
    clk = 0; load_val = 7; reset = 0; load = 0; count_enable = 0; up_down = 0;mod_n = 10;
    $dumpvars(0,t_counter);
    $dumpfile("dump.vcd");
    $monitor($time, " clk = %2b   Q = %d   C_out = %b", clk, Q, C_out);
    
    #1  reset = 1;
    #4  reset = 0;
    #52 reset = 1;
    #55 reset = 0;
    
    #4  count_enable = 1;
    #40 count_enable = 0;
    #53 count_enable = 1;
    #77 count_enable = 0;
    #82 count_enable = 1;
    
    #22 load = 1; 
    #24 load = 0;
    #63 load = 1; 
    #63 load_val = 4;
    #67 load = 0;
    
    #20 up_down = 1;
    #65 up_down = 0;
    #84 up_down = 1;
    #102 up_down = 0;
    
    #190 $finish;
  join
  
endmodule
*/

/* De-comment this module to check frequency divider
module t_freq_divider;
  wire div_clk;
  reg clk, reset, stop;
  freq_divider MUT(clk, reset, stop, div_clk);
  
  always #1 clk = ~clk;
  
  initial fork
    $dumpvars(0,t_freq_divider);
    $dumpfile("dump.vcd");    
    //$monitor($time, " clk = %b  reset = %b  stop = %b  div_clk = %b  counter = %1d", clk, reset, stop, div_clk, MUT.counter);
    
    clk = 0; reset = 0; stop = 0;
    
    #2 reset = 1;
    #6 reset = 0;
    
    #82 stop = 1;
    #148 stop = 0;
    #600 stop = 1;
    
    #10000 $finish;
  join
  
endmodule
*/

// De-comment for checking stopwatch
module t_stopwatch;
  //wire [15:0] Q;
  wire [3:0] activate_anode;
  wire [6:0] LED_out;
  reg master_reset, button_rl, button_ss, up_down,clk;
  reg [15:0] load_val;
  stopwatch MUT(master_reset, button_rl, button_ss, up_down, clk, load_val, activate_anode, LED_out);
  
  always #1 clk = ~clk;
  
  initial 
    begin
      $dumpfile("stopwatch.vcd");
      $dumpvars(0, t_stopwatch);
      $monitor($time, " button_ss = %b button_rl = %b up_down = %b Q = %h activate_anode = %h", button_ss, button_rl, up_down, MUT.Q, activate_anode);
      clk = 0; master_reset = 0; button_rl = 0; button_ss = 0; up_down = 1; load_val = 0;
    end
      
  
  initial fork
    #1 master_reset = 1;
    #4 master_reset = 0;
    
    #7 button_ss = 1;			// start
    #9 button_ss = 0;
    #1132 button_ss = 1;		// stops the stopwatch
    #1150 button_ss = 0;
    #1300 button_ss = 1;		// starts the stopwatch
    #1308 button_ss = 0;
    
    #2500 load_val = 16'h5875;
    #8000 load_val = 16'h1567;
    
    #2503 button_rl = 1;		// load
    #2510 button_rl = 0;
    #7000 button_rl = 1;		// reset
    #7008 button_rl = 0;
    #8000 button_rl = 1;		// load
    #8100 button_rl = 0; 	
    
    #1550 up_down = 0;
    #5000 up_down = 1;
    
    #11000 $finish;
  join
  
endmodule    


/* De-comment to check seven-segment display
module t_7_segment_display;
  wire [6:0] LED_out;
  wire [3:0] Anode_Activate;
  reg clk, master_reset;
  reg [15:0] Q;
  seven_segment_display MUT(clk, master_reset, Q, Anode_Activate, LED_out);
  
  always #1 clk = ~clk;
  
  initial 
    begin
      $dumpfile("dump.vcd");
      $dumpvars(0,t_7_segment_display);
      $monitor($time, " Q = %b  Active anode = %b  LED_out = %h", Q, Anode_Activate, LED_out);
      clk = 1; Q = 0; master_reset = 1;
    end
  
  initial fork
    #6 master_reset = 0;
    #1000 Q = 16'h5432;
    #6000 Q = 16'h2689;
    #11000 Q = 16'h0741;
    #18000 $finish;
  join
  
endmodule
*/