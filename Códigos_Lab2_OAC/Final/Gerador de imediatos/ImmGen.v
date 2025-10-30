`ifndef PARAM
	`include "Parametros.v"
`endif

module ImmGen (

	// Entrada: Instrução de 32 bits completa
	input [31:0] iInstrucao,
	
	// Saída: Valor Imediato de 32 bits, formatado e com extensão de sinal aplicada
	output reg [31:0] oImm 
);

// Bloco de lógica combinacional (always @(*)) que executa a geração de imediato.
// A seleção é feita com base no Opcode (bits [6:0] da instrução).
always @ (*)
    case (iInstrucao[6:0])
			// Formato I-Type (Load, OP-IMM, JALR) 
        `OPC_LOAD, // lw, lh, lb, etc
        `OPC_OPIMM, // addi, slti, xori, etc.
        `OPC_JALR: // Jump and Link Register
		  
				// O imediato I-Type usa os bits [31:20].
				// {{20{iInstrucao[31]}}} aplica a extensão de sinal (replica o MSB [31] 20 vezes).
            oImm = {{20{iInstrucao[31]}}, iInstrucao[31:20]};
			
			// --- Formato S-Type (Store) ---
        `OPC_STORE:
		  
			// O imediato S-Type é dividido em [31:25] e [11:7] e remontado.
            oImm = {{20{iInstrucao[31]}}, iInstrucao[31:25], iInstrucao[11:7]};
				
			// Formato B-Type (Branch)
        `OPC_BRANCH:
		  
				// O imediato B-Type é um desvio com sinal, que também tem 1 bit zero implícito.
				// Reorganiza os bits com extensão de sinal: 
				// {Extensão, bit 11 (MSB), bits [10:5], bits [4:1], bit 0 implícito}
            oImm = {{20{iInstrucao[31]}}, iInstrucao[7], iInstrucao[30:25], iInstrucao[11:8], 1'b0};
				
			// Formato J-Type (JAL)
        `OPC_JAL:
				// O imediato J-Type é o maior desvio, também com 1 bit zero implícito.
				// Reorganiza os bits com extensão de sinal: 
				// {Extensão, bits [19:12], bit 11, bits [10:1], bit 0 implícito}
            oImm = {{12{iInstrucao[31]}}, iInstrucao[19:12], iInstrucao[20], iInstrucao[30:21], 1'b0};
				
			// Formato U-Type (LUI) 
        `OPC_LUI:
				// LUI (Load Upper Immediate) move os bits [31:12] para a saída e preenche o resto com zeros.
            oImm = {iInstrucao[31:12], 12'b0};
				
			// Valor padrão (caso o Opcode não seja reconhecido)
        default:
            oImm = `ZERO; // Define o resultado como 0
    endcase

endmodule