`ifndef PARAM
	`include "Parametros.v"
`endif

module ControleULA (
    input logic [1:0] ALUOp,      // Vindo do Controle Principal
    input logic [6:0] funct7,
    input logic [2:0] funct3,
    output logic [4:0] ALUControl // Controle final para a ULA
);

    always_comb begin
        case (ALUOp)
            2'b00: // LW, SW, ADDI
                ALUControl = OPADD;
            2'b01: // BEQ
                ALUControl = OPSUB;
            2'b10: // Tipo R
                case (funct3)
                    FUNCT3_ADD: // ADD ou SUB
                        if (funct7 == FUNCT7_ADD)
                            ALUControl = OPADD;
                        else // FUNCT7_SUB
                            ALUControl = OPSUB;
                    FUNCT3_SLT: // SLT
                        ALUControl = OPSLT;
                    FUNCT3_OR:  // OR
                        ALUControl = OPOR;
                    FUNCT3_AND: // AND
                        ALUControl = OPAND;
                    default: ALUControl = OPNULL; // Não suportado
                endcase
            2'b11: // LUI
                ALUControl = OPLUI; // Código OPLUI para a ALU
            default: ALUControl = OPNULL; // Inválido
        endcase
    end

endmodule