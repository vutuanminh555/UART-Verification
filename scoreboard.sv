`include "transaction.sv"

class scoreboard; // need to calculate golden_output 
   
  //mailbox for monitor
  mailbox mon2scb;
  // mailbox for driver
  mailbox gen2driv;
  
  //used to count the number of transactions
  int no_transactions = 1;

  int dut_rx_data_err_detected = 0;
  int dut_parity_err_detected = 0;

  transaction mon_trans;
  transaction driv_trans; 

  logic [7:0] mon_trans_rx_data_temp;
  logic [7:0] driv_trans_tx_serial_temp;
  
  //constructor
  function new(mailbox gen2driv,mailbox mon2scb); 
    //getting the mailbox handles from  environment 
    this.mon2scb = mon2scb; // need to add mailbox from driver 
    this.gen2driv = gen2driv;
  endfunction

  covergroup  IP;
  coverpoint driv_trans.tx_serial{
    option.auto_bin_max = 0; // disable auto binning 
    bins zero = {0};
    bins allfs = {8'hff};
    bins special1 = {8'h55};
    bins special2 = {8'haa};
  }
  coverpoint driv_trans.data_bit_num{
    bins data_bit_num_5 = {2'b00};
    bins data_bit_num_6 = {2'b01};
    bins data_bit_num_7 = {2'b10};
    bins data_bit_num_8 = {2'b11};
  }
  coverpoint driv_trans.stop_bit_num{
    bins stop_bit_num_1 = {1'b0};
    bins stop_bit_num_2 = {1'b1};
  }
  coverpoint driv_trans.parity_en{
    bins parity_en = {1'b1};
    bins parity_dis = {1'b0};
  }
  coverpoint driv_trans.parity_type{
    bins parity_odd = {1'b0}; 
    bins parity_even = {1'b1}; 
  }
endgroup

covergroup OP;  
  coverpoint mon_trans.rx_data {
    option.auto_bin_max = 0; // disable auto binning 
    bins zero = {0};
    bins allfs = {8'hff};
    bins special1 = {8'h55};
    bins special2 = {8'haa};
  }
  coverpoint mon_trans.parity_error{
    bins error = {1'b1};
    bins no_error = {1'b0};
  }
endgroup

  IP = new();
  OP = new();
  
  task main; 
    // transaction mon_trans;
    // transaction driv_trans; 

    // logic [7:0] mon_trans_rx_data_temp;
    // logic [7:0] driv_trans_tx_serial_temp;

    int num_data_bit;
    forever begin
      $display("[ SCOREBOARD ] Number of Transactions: %d\n", no_transactions);
      mon2scb.get(mon_trans);
      gen2driv.get(driv_trans);
      
      mon_trans_rx_data_temp = 0; // default to 0
      driv_trans_tx_serial_temp = 0;
      num_data_bit = 0;

      if(driv_trans.data_bit_num == 2'b00)begin
        num_data_bit = 5;
      end
      else if(driv_trans.data_bit_num == 2'b01) begin
        num_data_bit = 6;
      end
      else if(driv_trans.data_bit_num == 2'b10) begin
        num_data_bit = 7;
      end
      else if(driv_trans.data_bit_num == 2'b11) begin
        num_data_bit = 8;
      end

      for(int i = 0; i < num_data_bit; i++)begin // for bug when comparing 2 logic reg
        driv_trans_tx_serial_temp[i] = driv_trans.tx_serial[i];
        mon_trans_rx_data_temp[i] = mon_trans.rx_data[i];
      end

        // raw output data, for manual checking 
        $display("[ Scoreboard ] Raw Data from Uart Output\n");
        $display("[ Scoreboard ] rx_data: %b   parity_error: %b\n", mon_trans.rx_data, mon_trans.parity_error); 

        // check rx_data output
        $display("[ Scoreboard ] Checking rx_data output\n");
        $display("[ Scoreboard ] rx_data from DRIVER: %b, rx_data from MONITOR: %b\n", driv_trans_tx_serial_temp, mon_trans_rx_data_temp);
        if(mon_trans_rx_data_temp == driv_trans_tx_serial_temp) // can chia truong hop voi so luong data frame khac nhau 
          $display("[ Scoreboard ] rx_data is as Expected\n");
        else begin
          dut_rx_data_err_detected = 1;
          $display("[ Scoreboard ] [ERROR] rx_data Wrong Result. Expected: %b Actual: %b\n", driv_trans_tx_serial_temp, mon_trans_rx_data_temp);
        end

        // check parity_error
        if(driv_trans.parity_en == 1'b1)begin // if parity_bit is enabled
        
        // check parity error created by driver 
        if(driv_trans.parity_err_chk == 1'b1) begin
          $display("[ Scoreboard ] Detecting parity_error test case from DRIVER\n");
          $display("[ Scoreboard ] Checking parity_error test case\n");
          if(mon_trans.parity_error == 1'b1)
          $display("[ Scoreboard ] parity_error is as Expected\n");
          else begin
            dut_parity_err_detected = 1;
          $display("[ Scoreboard ] [ERROR] parity_error Wrong Result. Expected: %b Actual: %b\n", 1'b1, mon_trans.parity_err);
          end

        end
        else begin
          $display("[ Scoreboard ] No parity_error test case from DRIVER\n");
          if(mon_trans.parity_error == 1'b0) // default to no parity error from driver
          $display("[ Scoreboard ] parity_error is as Expected\n");
          else begin
            dut_parity_err_detected = 1;
          $display("[ Scoreboard ] [ERROR] parity_error Wrong Result. Expected: %b Actual: %b\n", 1'b0, mon_trans.parity_err); 
          end
        end

        end

        // if(dut_rx_data_err_detected)begin
        //     $display("[ Scoreboard ] [DUT ERROR] rx_data has problem\n");
        // end
        // if(dut_parity_err_detected)begin
        //     $display("[ Scoreboard ] [DUT ERROR] parity_error has problem\n");
        // end

        no_transactions++;
        IP.sample();
        OP.sample();
    end
  endtask


    //end

//endtask

endclass
