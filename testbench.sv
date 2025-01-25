`timescale 1ns/1ps

`include "interface.sv" 
`include "random_test.sv"

module tbench_top;  // only used to connect and initiate signals 
  
  //creatinng instance of interface, in order to connect DUT and testcase
  intf u_intf();
  
  //Testcase instance, interface handle is passed to test as an argument
  test t1(u_intf); // instance for random test, random test connect dut with testbench 
  
  //DUT instance, interface signals are connected to the DUT ports
  uart uart_0(
     .clk         (u_intf.clk)
    ,.reset_n     (u_intf.reset_n)
    ,.rx          (u_intf.tx) 
    ,.cts_n       ('0) // mac dinh la 0
    ,.tx          (u_intf.rx)
    ,.rts_n       (u_intf.cts_n)
    ,.tx_data     ('0)
    ,.data_bit_num(u_intf.data_bit_num)
    ,.stop_bit_num(u_intf.stop_bit_num)
    ,.parity_en   (u_intf.parity_en)
    ,.parity_type (u_intf.parity_type)
    ,.start_tx    ('0)
    ,.rx_data     (u_intf.rx_data)
    ,.tx_done     (u_intf.tx_done)
    ,.rx_done     (u_intf.rx_done)
    ,.parity_error(u_intf.parity_error)
  );
  
  logic clk;
  logic reset_n;

  always #5 clk = ~clk;

  assign u_intf.clk = clk;
  assign u_intf.reset_n = reset_n;
  
  initial begin
    $display("Start testbench");
    clk = 0;
    reset_n = 0;
    #1 reset_n = 1; // complete reset cycle 
  end
  
endmodule