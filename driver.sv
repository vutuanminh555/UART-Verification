`timescale 1ns/1ps

`include "transaction.sv"

class driver;
  
  //used to count the number of transactions
  int no_transactions;
  
  //creating virtual interface handle
  virtual intf vif;
  
  //creating mailbox handle
  mailbox gen2driv;
  
  bit parity_bit;
  
  localparam UART_DATA_BIT_NUM_5 = 2'b00;
  localparam UART_DATA_BIT_NUM_6 = 2'b01;
  localparam UART_DATA_BIT_NUM_7 = 2'b10;
  localparam UART_DATA_BIT_NUM_8 = 2'b11;
  
  //constructor
  function new(virtual intf vif,mailbox gen2driv);
    //getting the interface
    this.vif = vif;
    //getting the mailbox handles from  environment 
    this.gen2driv = gen2driv;
  endfunction
  
  //Reset task, Reset the Interface signals to default/initial values
  task reset;
    no_transactions = 0;
    vif.tx = 1'b1; // default state of rx port  
    $display("[ DRIVER ] ----- Reset -----");
  endtask
  
  // task: get number of data bits based on input code
  function int get_num_bit(logic [1:0] num_bit_coded); // need for for loop used to transmit data frame 
    case (num_bit_coded)
      UART_DATA_BIT_NUM_5 : return 5;
      UART_DATA_BIT_NUM_6 : return 6;
      UART_DATA_BIT_NUM_7 : return 7;
      UART_DATA_BIT_NUM_8 : return 8;
      default : return 5;
    endcase
  endfunction
  
  //drivers the transaction items to interface signals
  task main;
    forever begin
      transaction tx_item;
      gen2driv.peek(tx_item); //get
      $display("[%10t] [UART TX] ----- Getting new transaction -----", $time);

      tx_item.print_info();

      parity_bit = 0;
      vif.data_bit_num <= tx_item.data_bit_num;
      vif.stop_bit_num <= tx_item.stop_bit_num;
      vif.parity_en    <= tx_item.parity_en;
      vif.parity_type  <= tx_item.parity_type;
      
      wait(vif.cts_n == 0); // suspend till cts_n == 0 

      $display("[%10t] [UART TX] ----- Start UART TX transaction -----", $time);
      
      // Start bit
      vif.tx = 1'b0;

      // Data bit
      for (int i = 0; i < get_num_bit(tx_item.data_bit_num); i++) begin // loop depends on number of data bits 
        //parity_bit = parity_bit ^ tx_item.tx_serial[i]; 
        if(tx_item.tx_serial[i] == 1'b1)
        parity_bit = ~parity_bit;
        #4340ns vif.tx <= tx_item.tx_serial[i]; // take data from tx_serial
        //$display("[%10t] [UART TX] Drive bit %0b", $time, tx_item.tx_serial[i]);
      end


      // Parity bit
      if (tx_item.parity_en == 1'b1) begin  // parity enable (have to be enabled for parity_error test case)
        if (~tx_item.parity_type) begin // odd 
          if(tx_item.parity_err_chk == 1)begin
          $display("[DRIVER] Testing Odd Parity Bit Error\n");
          #4340ns vif.tx <= parity_bit; // test case for odd parity_error
          end
          else begin
          #4340ns vif.tx <= ~parity_bit; 
          $display("[%10t] [UART TX] Drive odd parity_bit %0b", $time, ~parity_bit);
          end
        end
        else begin // even 
          if(tx_item.parity_err_chk == 1)begin
          $display("[DRIVER] Testing Even Parity Bit Error\n");
          #4340ns vif.tx <= ~parity_bit; // test case for even parity_error
          end
          else begin
          #4340ns vif.tx <= parity_bit; 
          $display("[%10t] [UART TX] Drive even parity_bit %0b", $time, parity_bit);
          end
        end
      end

      // Stop bit
      #4340ns vif.tx <= 1'b1; // default to 1 stop bit 
      if (tx_item.stop_bit_num == 1'b1) begin // if use 2 stop bits
        #4340ns vif.tx <= 1'b1;
      end
      $display("[%10t] [UART TX] Done rx transaction. Waiting for rx_done...", $time);

      wait(vif.rx_done == 1); 
      
      $display("[%10t] [UART TX] rx_done = 1", $time);
      $display("[%10t] [UART TX] Data received: %8b", $time, vif.rx_data);
      #100ns vif.reset_n = 0;
      #20ns vif.reset_n = 1;
      no_transactions++; // increase number of transactions, ends when equal to gen_repeat_count
    end
  endtask
  
endclass