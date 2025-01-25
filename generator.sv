`include "transaction.sv"

class generator;
  
  //declaring transaction class 
  rand transaction trans; // randomize all rand variable in trans; no need for trans in random_test
  
  //repeat count, to specify number of items to generate
  int  repeat_count; // number of packets
  
  //mailbox, to generate and send the packet to driver
  mailbox gen2driv;
  
  //event, to indicate the end of transaction generation
  event ended;
  
  //constructor
  function new(mailbox gen2driv);
    //getting the mailbox handle from env, in order to share the transaction packet between the generator and driver, the same mailbox is shared between both.
    this.gen2driv = gen2driv;
  endfunction
  
  //main task, generates(create and randomizes) the repeat_count number of transaction packets and puts into mailbox
  task main();
    repeat(repeat_count) begin // repeat_count gets value from random_test
    trans = new();
    if( !trans.randomize() ) $fatal("Gen:: trans randomization failed");
      $display("[ Generator ] Generating Packet\n");
      gen2driv.put(trans); // randomize then put to mailbox 
    end
    -> ended; //triggering indicatesthe end of generation; used to end task 
  endtask
  
endclass