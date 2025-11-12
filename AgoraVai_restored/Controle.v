`ifndef PARAM
	`include "Parametros.v"
`endif

module Controle (
    input wire [6:0] opcode,
    output reg Mem2Reg,
    output reg LeMem,
    output reg Branch,
    output reg [1:0] ALUOp,
    output reg EscreveMem,
    output reg OrigULA,
    output reg EscreveReg,
    output reg Jump
);

    always @(*) begin
        // Valores Padrão
        Mem2Reg    = 1'b0;
        LeMem      = 1'b0; 
        Branch     = 1'b0;
        ALUOp      = 2'b00;
        EscreveMem = 1'b0; 
        OrigULA    = 1'b0;
        EscreveReg = 1'b0;
        Jump       = 1'b0; 

        case (opcode)
            OPC_LOAD: begin
                LeMem      = 1'b1;
                Mem2Reg    = 1'b1; 
                EscreveReg = 1'b1; 
                ALUOp      = 2'b00;
                OrigULA    = 1'b1; 
            end
            OPC_STORE: begin
                EscreveMem = 1'b1;
                OrigULA    = 1'b1; 
                ALUOp      = 2'b00;
            end
            OPC_RTYPE: begin
                EscreveReg = 1'b1;
                ALUOp      = 2'b10;
            end
            OPC_BRANCH: begin
                Branch     = 1'b1;
                ALUOp      = 2'b01;
            end
             OPC_JAL: begin
                 EscreveReg = 1'b1;
                 Jump       = 1'b1;
            end
             OPC_JALR: begin
                 EscreveReg = 1'b1;
                 OrigULA    = 1'b1;
                 ALUOp      = 2'b00;
                 Jump       = 1'b1;
            end
             OPC_OPIMM: begin
                 EscreveReg = 1'b1;
                 OrigULA    = 1'b1;
                 ALUOp      = 2'b00;
            end
             OPC_LUI: begin
                 EscreveReg = 1'b1;
                 OrigULA    = 1'b1;
                 ALUOp      = 2'b11;
            end
            default: ;
        endcase
    end
endmodule