`ifndef PARAM // Diretiva de pré-compilação: Inclui as constantes e definições do arquivo de parâmetros.
	`include "Parametros.v"
`endif
 
module ALU (

	// Entrada de Controle
	input [4:0] iControl, // Sinal de controle que seleciona a operação a ser executada
	
	// Entradas de Operandos
	input signed [31:0] iA, // Operando A (entrada de 32 bits, com sinal)
	input signed [31:0] iB, // Operando B (entrada de 32 bits, com sinal)
	
	// Saídas
	output reg [31:0] oResult, // oResult é 'reg' pois é atribuído dentro de um bloco 'always' combinacional
	output            Zero 	  // Zero é um 'wire' (padrão) pois é atribuído por uma declaração 'assign'
);

	// Flag Zero: Lógica combinacional que se torna alta (1) se o resultado for 0.
	assign Zero = (oResult == 32'b0);

	// Bloco de lógica combinacional (sempre ativo) para realizar as operações.
	always @(*)
	begin
		// Usamos a atribuição bloqueante ('=') para lógica combinacional (simulando portas lógicas instantâneas)
		case (iControl)
			`OPAND: // Operação AND: oResult = A & B
				oResult = iA & iB;
			`OPOR: // Operação OR: oResult = A | B
				oResult = iA | iB;
			`OPADD: // Operação de Adição: oResult = A + B
				oResult = iA + iB;
			`OPSUB: // Operação de Subtração: oResult = A - B
				oResult = iA - iB;
			`OPSLT: // Set on Less Than (Com Sinal): Se A < B, oResult = 1, senão oResult = 0.
				oResult = iA < iB;

			// Valor de saída padrão (caso iControl seja um valor não mapeado ou não utilizado)
			default:
				oResult = `ZERO; // Usa a macro 'ZERO' definida nos Parâmetros (32'b0)
		endcase
	end

endmodule