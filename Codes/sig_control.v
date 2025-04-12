`define TRUE 1'b1 
`define FALSE 1'b0 
`define RED 2'd0 
`define YELLOW 2'd1 
`define GREEN 2'd2 
`define S0 3'd0 
`define S1 3'd1 
`define S2 3'd2 
`define S3 3'd3 
`define S4 3'd4 
`define DELAY 3     // max of Y2RDELAY and R2GDELAY

module sig_control(hwy, cntry, X, clock, clear); 
  output reg [1:0] hwy, cntry; 
  input X; 
  input clock, clear; 
  
  reg [2:0] state; 
  reg [2:0] next_state; 
  reg [1:0] delay_count;
  reg delay_en;

  // state register
  always @(posedge clock or posedge clear) begin
    if (clear)
      state <= `S0;
    else
      state <= next_state;
  end

  // output logic
  always @(*) begin
    case (state)
      `S0: begin hwy = `GREEN;  cntry = `RED;    end
      `S1: begin hwy = `YELLOW; cntry = `RED;    end
      `S2: begin hwy = `RED;    cntry = `RED;    end
      `S3: begin hwy = `RED;    cntry = `GREEN;  end
      `S4: begin hwy = `RED;    cntry = `YELLOW; end
      default: begin hwy = `RED; cntry = `RED; end
    endcase
  end

  // delay counter control
  always @(posedge clock or posedge clear) begin
    if (clear)
      delay_count <= 0;
    else if (delay_en)
      delay_count <= delay_count + 1;
    else
      delay_count <= 0;
  end

  // next state logic
  always @(*) begin
    delay_en = 0;
    case (state)
      `S0: begin
        if (X)
          next_state = `S1;
        else
          next_state = `S0;
      end

      `S1: begin
        delay_en = 1;
        if (delay_count >= `DELAY) // Y2RDELAY
          next_state = `S2;
        else
          next_state = `S1;
      end

      `S2: begin
        delay_en = 1;
        if (delay_count >= 2) // R2GDELAY
          next_state = `S3;
        else
          next_state = `S2;
      end

      `S3: begin
        if (X)
          next_state = `S3;
        else
          next_state = `S4;
      end

      `S4: begin
        delay_en = 1;
        if (delay_count >= `DELAY) // Y2RDELAY
          next_state = `S0;
        else
          next_state = `S4;
      end

      default: next_state = `S0;
    endcase
  end
endmodule

