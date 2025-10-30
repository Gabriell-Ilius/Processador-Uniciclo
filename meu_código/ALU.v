`ifndef PARAM
	`include "Parametros.v"
`endif


module ALU (
	input 		 [4:0]  iControl, // Controle da operação
	input signed [31:0] iA,      // Operando A
	input signed [31:0] iB,      // Operando B
	output logic [31:0] oResult, // Resultado
	output logic Zero          // Flag Zero (Resultado == 0)
	);

// Flag Zero
assign Zero = (oResult==32'b0);

// Lógica da ULA
always @(*)
begin
    case (iControl)
		OPAND: oResult  <= iA & iB;
		OPOR:  oResult  <= iA | iB;
		OPADD: oResult  <= iA + iB;
		OPSUB: oResult  <= iA - iB;
		OPSLT: oResult  <= (iA < iB) ? 32'd1 : 32'd0;
      OPLUI: oResult  <= iB; // Passa B para LUI
		default: oResult <= ZERO;
    endcase
end

endmodule