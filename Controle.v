`ifndef PARAM
	`include "Parametros.v"
`endif

module Controle (
    input logic [6:0] opcode,
    // Saídas dos sinais de controle principais
    output logic Mem2Reg,     // Seleciona dado da ULA (0) ou Memória (1) para escrita no registrador
    output logic LeMem,       // Habilita leitura da memória de dados
    output logic Branch,      // Indica instrução de desvio condicional (beq)
    output logic [1:0] ALUOp, // Define a categoria da operação para ControleULA
    output logic EscreveMem,  // Habilita escrita na memória de dados
    output logic OrigULA,     // Seleciona segundo operando da ULA: Reg (0) ou Imediato (1)
    output logic EscreveReg,  // Habilita escrita no banco de registradores
    output logic Jump         // Indica instrução de desvio incondicional (jal, jalr)
);

    // Sinal Jump é ativo se for JAL ou JALR
    assign Jump = (opcode == OPC_JAL || opcode == OPC_JALR);

    // Lógica combinacional para gerar os sinais de controle
    always_comb begin
        // --- Valores Padrão (seguros, para NOP implícito ou opcode desconhecido) ---
        Mem2Reg    = 1'b0; // Padrão: ULA->Reg
        LeMem      = 1'b0; // Padrão: Não lê memória
        Branch     = 1'b0; // Padrão: Não é branch
        ALUOp      = 2'b00; // Padrão: Pode ser ADD (usado por lw/sw/addi)
        EscreveMem = 1'b0; // Padrão: Não escreve memória
        OrigULA    = 1'b0; // Padrão: Origem B é registrador
        EscreveReg = 1'b0; // Padrão: Não escreve registrador

        // --- Decodificação baseada no Opcode ---
        case (opcode)
            OPC_LOAD: begin // lw
                LeMem      = 1'b1; // Lê da memória de dados
                Mem2Reg    = 1'b1; // Dado da memória vai para o registrador
                EscreveReg = 1'b1; // Escreve no registrador de destino (rd)
                ALUOp      = 2'b00; // ULA calcula endereço (rs1 + imm) -> ADD
                OrigULA    = 1'b1; // Segundo operando da ULA é o imediato
            end
            OPC_STORE: begin // sw
                EscreveMem = 1'b1; // Escreve na memória de dados
                OrigULA    = 1'b1; // Segundo operando da ULA é o imediato
                ALUOp      = 2'b00; // ULA calcula endereço (rs1 + imm) -> ADD
                // EscreveReg = 0 por padrão
            end
            OPC_RTYPE: begin // add, sub, and, or, slt
                EscreveReg = 1'b1; // Escreve no registrador de destino (rd)
                ALUOp      = 2'b10; // Sinaliza para ControleULA decodificar R-type (usando funct3/funct7)
                // OrigULA = 0 por padrão (segundo operando é rs2)
            end
            OPC_BRANCH: begin // beq
                Branch     = 1'b1; // Sinaliza instrução de branch
                ALUOp      = 2'b01; // Sinaliza para ControleULA fazer comparação (SUB)
                // EscreveReg = 0 por padrão
                // OrigULA = 0 por padrão (compara rs1 e rs2)
            end
             OPC_JAL: begin // jal
                 EscreveReg = 1'b1; // Escreve PC+4 no registrador de destino (rd)
                 // Jump = 1 (via assign)
                 // ALUOp = XX (não importa para o cálculo do PCNext de JAL, nem para o dado escrito (PC+4))
                 // OrigULA = X (não importa)
                 // Os defaults (Mem2Reg=0, LeMem=0, Branch=0, EscreveMem=0) estão corretos.
             end
             OPC_JALR: begin // jalr
                 EscreveReg = 1'b1; // Escreve PC+4 no registrador de destino (rd)
                 OrigULA    = 1'b1; // Segundo operando da ULA é o imediato (offset)
                 ALUOp      = 2'b00; // ULA calcula endereço alvo (rs1 + imm) -> ADD
                 // Jump = 1 (via assign)
                 // Os defaults (Mem2Reg=0, LeMem=0, Branch=0, EscreveMem=0) estão corretos.
             end
             OPC_OPIMM: begin // addi
                 EscreveReg = 1'b1; // Escreve no registrador de destino (rd)
                 OrigULA    = 1'b1; // Segundo operando da ULA é o imediato
                 ALUOp      = 2'b00; // Sinaliza para ControleULA fazer ADD
                 // Os defaults (Mem2Reg=0, LeMem=0, Branch=0, EscreveMem=0) estão corretos.
             end
             OPC_LUI: begin // lui (Opcode foi adicionado a Parametros.v)
                 EscreveReg = 1'b1; // Escreve no registrador de destino (rd)
                 OrigULA    = 1'b1; // Segundo operando da ULA *deve* ser o imediato
                 ALUOp      = 2'b11; // Sinaliza LUI para ControleULA -> OPLUI na ALU
                 // Os defaults (Mem2Reg=0, LeMem=0, Branch=0, EscreveMem=0) estão corretos.
             end

            default: ; // Mantém os valores padrão para opcodes não reconhecidos
        endcase
    end

endmodule