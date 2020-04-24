module forwardingUnit  (Rd1, Rd2, Rm, Rn, forwardCtrlOne, forwardCtrlTwo, regWrite1, regWrite2);
    input logic regWrite1, regWrite2;
    input logic [4:0] Rd1, Rd2, Rm, Rn; /*isRtype,*/
    output logic [1:0] forwardCtrlOne, forwardCtrlTwo;

    always_comb begin 
        if (Rn == Rd1 && Rn != 5'b11111 && regWrite1)
            forwardCtrlOne = 2'b01;
        else if (Rn == Rd2 && Rn != 5'b11111 && regWrite2)
            forwardCtrlOne = 2'b10;
        else 
            forwardCtrlOne = 2'b00;
    end

    always_comb begin 
        if (Rm == Rd1 && Rm != 5'b11111 && regWrite1)
            forwardCtrlTwo = 2'b01;
        else if (Rm == Rd2 && Rm != 5'b11111 && regWrite2)
            forwardCtrlTwo = 2'b10;
        else 
            forwardCtrlTwo = 2'b00;
    end

endmodule

module forwardingUnit_testbench ();
     logic regWrite1, regWrite2;
     logic [4:0] Rd1, Rd2, Rm, Rn; /*isRtype,*/
     logic [1:0] forwardCtrlOne, forwardCtrlTwo;

    forwardingUnit dut (.Rd1, .Rd2, .Rm, .Rn, .forwardCtrlOne, .forwardCtrlTwo, .regWrite1, .regWrite2);
     initial begin
         Rd1 = 20; Rd2 = 5; Rm = 10; Rn = 10; regWrite1 = 1; regWrite2 = 1; #10;
         Rd1 = 20; Rd2 = 5; Rm = 20; Rn = 10; regWrite1 = 1; regWrite2 = 1; #10;
         Rd1 = 20; Rd2 = 5; Rm = 10; Rn = 20; regWrite1 = 1; regWrite2 = 1; #10;

         Rd1 = 5; Rd2 = 20; Rm = 10; Rn = 10; regWrite1 = 1; regWrite2 = 1; #10;
         Rd1 = 5; Rd2 = 20; Rm = 20; Rn = 10; regWrite1 = 1; regWrite2 = 1; #10;
         Rd1 = 5; Rd2 = 20; Rm = 10; Rn = 20; regWrite1 = 1; regWrite2 = 1; #10;

         Rd1 = 20; Rd2 = 5; Rm = 20; Rn = 10; regWrite1 = 0; regWrite2 = 1; #10; // matches Rd1 zeroed
         Rd1 = 20; Rd2 = 5; Rm = 10; Rn = 20; regWrite1 = 1; regWrite2 = 0; #10; // matches Rd1 

         Rd1 = 5; Rd2 = 20; Rm = 20; Rn = 10; regWrite1 = 1; regWrite2 = 0; #10; //matches Rd2, zeroed
         Rd1 = 5; Rd2 = 20; Rm = 10; Rn = 20; regWrite1 = 0; regWrite2 = 1; #10; //matches Rd1 zeroed

     end
endmodule