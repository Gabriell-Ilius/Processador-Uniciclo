`ifndef PARAM
	`include "Parametros.v"
`endif

module Controle (
    input logic [6:0] opcode,
    output logic Mem2Reg,
    output logic LeMem,
    output logic Branch,
    output logic [1:0] ALUOp, // Modificado para 2 bits conforme diagrama e ControleULA
    output logic EscreveMem,
    output logic OrigULA,
    output logic EscreveReg,
    output logic Jump // Sinal para JAL e JALR
);

    assign Jump = (opcode == OPC_JAL || opcode == OPC_JALR);

    always_comb begin
        // Valores default (para instrução inválida ou NOP implícito)
        Mem2Reg     = 1'b0;
        LeMem       = 1'b0;
        Branch      = 1'b0;
        ALUOp       = 2'b00; // Default pode ser ADD para não dar X
        EscreveMem  = 1'b0;
        OrigULA     = 1'b0; // Default: Origem B é registrador
        EscreveReg  = 1'b0;

        case (opcode)
            OPC_LOAD: begin // lw
                LeMem       = 1'b1;
                Mem2Reg     = 1'b1; // Dado da memória vai para registrador
                EscreveReg  = 1'b1;
                ALUOp       = 2'b00; // ULA calcula endereço (add)
                OrigULA     = 1'b1; // Imediato como operando B
            end
            OPC_STORE: begin // sw
                EscreveMem  = 1'b1;
                OrigULA     = 1'b1; // Imediato como operando B
                ALUOp       = 2'b00; // ULA calcula endereço (add)
                // EscreveReg = 0 (default)
                // LeMem = 0 (default)
                // Mem2Reg = X (não importa)
                // Branch = 0 (default)
            end
            OPC_RTYPE: begin // add, sub, and, or, slt
                EscreveReg  = 1'b1;
                ALUOp       = 2'b10; // ULA definida por funct3/funct7
                // OrigULA = 0 (default, registrador)
                // LeMem = 0 (default)
                // EscreveMem = 0 (default)
                // Mem2Reg = 0 (default, resultado da ULA vai para reg)
                // Branch = 0 (default)
            end
            OPC_BRANCH: begin // beq
                Branch      = 1'b1; // Habilita lógica de desvio
                ALUOp       = 2'b01; // ULA compara (sub)
                // EscreveReg = 0 (default)
                // LeMem = 0 (default)
                // EscreveMem = 0 (default)
                // Mem2Reg = X (não importa)
                // OrigULA = 0 (default, registrador)
            end
             OPC_JAL: begin // jal
                 EscreveReg = 1'b1; // Salva PC+4 em rd
                 // Mem2Reg = 0 (resultado ULA -> reg, neste caso PC+4)
                 // ALUOp = ?? (ULA pode calcular PC+4 ou ser irrelevante dependendo do mux de escrita)
                 // OrigULA = ??
                 // LeMem = 0
                 // EscreveMem = 0
                 // Branch = 0
             end
             OPC_JALR: begin // jalr
                 EscreveReg = 1'b1; // Salva PC+4 em rd
                 OrigULA    = 1'b1; // Soma rs1 com imediato
                 ALUOp      = 2'b00; // ULA calcula endereço do pulo (add)
                // Mem2Reg = 0 (resultado ULA -> reg, neste caso PC+4)
                 // LeMem = 0
                 // EscreveMem = 0
                 // Branch = 0
             end
             OPC_OPIMM: begin // addi
                 EscreveReg = 1'b1;
                 OrigULA    = 1'b1; // Imediato como operando B
                 ALUOp      = 2'b00; // ULA faz ADD
                // LeMem = 0
                // EscreveMem = 0
                // Mem2Reg = 0
                // Branch = 0
             end
             7'b0110111: begin // lui
                 EscreveReg = 1'b1;
                 OrigULA    = 1'b1; // Passa o imediato (shiftado ou não, depende da ULA/datapath)
                 ALUOp      = 2'b11; // Sinaliza LUI para ControleULA/ULA (pode ser OPADD com A=0)
                // LeMem = 0
                // EscreveMem = 0
                // Mem2Reg = 0
                // Branch = 0
             end

            default: ; // Mantém defaults
        endcase
    end

endmodule