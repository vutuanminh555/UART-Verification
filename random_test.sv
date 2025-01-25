`include "environment.sv"
program test(intf i_intf);
  
  //declaring environment instance
  environment env; // trans variable already in generator 
  
  initial begin
    //creating environment
    env = new(i_intf); // connect interface with environment 
    
    //setting the repeat count of generator as 4, means to generate 4 packets
    env.gen.repeat_count = 1000; // number of packets to create 
    
    //calling run of env, it interns calls generator and driver main tasks.
    env.run();
    

  end
endprogram