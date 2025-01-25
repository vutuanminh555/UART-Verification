`ifndef TRANSACTION_H
`define TRANSACTION_H

class transaction; // need to write constraints
  
  //declaring the transaction items for driver
  rand logic [7:0] tx_serial;
  rand logic [1:0] data_bit_num;
  rand logic       stop_bit_num;
  rand logic       parity_en;
  rand logic       parity_type;

  // items for monitor
  logic tx;
  logic rts_n;
  logic rx_done;
  logic tx_done;
  logic [7:0] rx_data;
  logic parity_error;

  // used for test case 
  rand logic parity_err_chk; 

  localparam UART_DATA_BIT_NUM_5 = 2'b00;
  localparam UART_DATA_BIT_NUM_6 = 2'b01;
  localparam UART_DATA_BIT_NUM_7 = 2'b10;
  localparam UART_DATA_BIT_NUM_8 = 2'b11;

  localparam UART_STOP_BIT_NUM_1 = 1'b0;
  localparam UART_STOP_BIT_NUM_2 = 1'b1;

  localparam UART_PARITY_EN_ON = 1'b1;
  localparam UART_PARITY_EN_OFF = 1'b0;

  localparam UART_PARITY_TYPE_EVEN = 1'b1;
  localparam UART_PARITY_TYPE_ODD = 1'b0;
  
  // constraint direct_test {
  //   data_bit_num == 2'b11; 
  //   stop_bit_num == 1'b0;
  //   parity_en == 1'b1;
  //   parity_type == 1'b0;
  //   tx_serial == 8'b01010101;
  // }

  constraint data{ // used with tx_serial , used with dist for better coverage 
    tx_serial dist {0:=10, 255:=10, 170:=10, 85:= 10, [0:255]:/ 300};
  }

  constraint core{ // chuyen doi noi tiep thanh song song
    data_bit_num inside {[0:3]};
    stop_bit_num inside {[0:1]};
    parity_en == 1; //inside {[0:1]};
    parity_type inside {[0:1]}; 
  }

  constraint parity_err{ // parity bit bi loi, should use with dist
    parity_err_chk == 0; // inside {[0:1]};
    //parity_en == 0;
  }
  
  function void print_info();
    automatic int num_bit; 
    // Parity bit
    case (data_bit_num) // number of parity and stop bit also change 
      UART_DATA_BIT_NUM_5 : num_bit = 5;
      UART_DATA_BIT_NUM_6 : num_bit = 6;
      UART_DATA_BIT_NUM_7 : num_bit = 7;
      UART_DATA_BIT_NUM_8 : num_bit = 8;
      default :;
    endcase

    $write("TX serial: ");
    for (int i = 0 ; i < num_bit ; i++)
      $write("%0b ", tx_serial[i]);
    $write("\n");

    $display("Data bit num = %2b", data_bit_num);
    $display("Stop bit num = %b", stop_bit_num);
    $display("Parity en    = %b", parity_en);
    $display("Parity type  = %b", parity_type);
  endfunction
endclass

`endif