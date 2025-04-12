`timescale 1ns / 1ps
`define TRUE 1'b1
`define FALSE 1'b0

module stimulus;

  wire [1:0] MAIN_SIG, CNTRY_SIG;
  reg CAR_ON_CNTRY_RD;
  reg CLOCK, CLEAR;

  // Instantiate the controller
  sig_control SC(MAIN_SIG, CNTRY_SIG, CAR_ON_CNTRY_RD, CLOCK, CLEAR);

  // Clock generation: 10ns period
  initial 
    begin
      CLOCK = 0;
      forever #5 CLOCK = ~CLOCK;
  	end

  // Monitor output
  initial begin
    $monitor($time, " | HWY = %b, CNTRY = %b, CAR = %b", MAIN_SIG, CNTRY_SIG, CAR_ON_CNTRY_RD);
  end

  // Waveform dump
  initial begin
    $dumpfile("traffic_controller_temp.vcd");
    $dumpvars(0, stimulus);
  end

  // Reset sequence
  initial begin
    CLEAR = `TRUE;
    repeat (2) @(negedge CLOCK);
    CLEAR = `FALSE;
  end

  // Stimulus task
  task simulate_car_input(input integer delay_before, input integer high_time);
    begin
      #(delay_before) CAR_ON_CNTRY_RD = `TRUE;
      #(high_time)    CAR_ON_CNTRY_RD = `FALSE;
    end
  endtask

  // Apply input stimulus
  initial begin
    CAR_ON_CNTRY_RD = `FALSE;
    simulate_car_input(200, 100);
    simulate_car_input(200, 100);
    simulate_car_input(200, 100);
    #200 $finish;
  end

endmodule

