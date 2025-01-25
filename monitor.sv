`include "transaction.sv"

class monitor;
  
  //creating virtual interface handle
  virtual intf vif;
  
  //creating mailbox handle
  mailbox mon2scb;
  
  //constructor
  function new(virtual intf vif, mailbox mon2scb);
    //getting the interface
    this.vif = vif;
    //getting the mailbox handles from  environment 
    this.mon2scb = mon2scb;
  endfunction
  
  //Samples the interface signal and send the sample packet to scoreboard
  task main;  
    forever begin
      transaction trans; 
      trans = new(); // new instance 
      //wait(vif.rx_done == 1);
      @(posedge vif.rx_done); // lay du lieu khi posedge 
      trans.rts_n = vif.rts_n;
      trans.rx_data = vif.rx_data;
      trans.parity_error = vif.parity_error;
      mon2scb.put(trans);
      $display("[ Monitor ] Retrieving Data\n"); 
    end
  endtask
  
endclass