`ifndef PARAM
	`include "Parametros.v"
`endif

module ControleULA (
    input logic [1:0] ALUOp,      // Sinal vindo do Controle Principal
    input logic [6:0] funct7,
    input logic [2:0] funct3,
    output logic [4:0] ALUControl // Sinal de controle para a ULA
);

    always_comb begin
        case (ALUOp)
            2'b00: // LW, SW, ADDI
                ALUControl = OPADD; // Sempre soma para cálculo de endereço ou ADDI
            2'b01: // BEQ
                ALUControl = OPSUB; // Subtrai para verificar igualdade (zero flag)
            2'b10: // Instruções Tipo R
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
                    default: ALUControl = OPNULL; // Operação inválida ou não implementada
                endcase
             2'b11: // LUI (neste caso, a ULA pode apenas passar o imediato, ou somar com zero)
                 ALUControl = OPADD; // Pode usar ADD (B=0) ou criar uma operação específica se necessário
            default: ALUControl = OPNULL; // Caso padrão/inválido
        endcase
    end

endmodule