`ifndef PARAM
	`include "Parametros.v"
`endif

module TopDE (
	// Entradas
	input wire CLOCK, Reset,
	input wire [4:0] Regin,
	
	// Saídas
	output wire ClockDIV,
	output wire [31:0] PC,
	output wire [31:0] Instr,
	output wire [31:0] Regout
);
	
	// --- NOVO DIVISOR DE CLOCK (divide por 4) ---
	reg [1:0] clock_counter;
	
	always @(posedge CLOCK or posedge Reset)
	begin
		if (Reset)
			clock_counter <= 2'b00;
		else
			clock_counter <= clock_counter + 1;
	end
	

	assign ClockDIV = (clock_counter == 2'b01); 
	

	Uniciclo UNI1 (
		.clockCPU(ClockDIV), 
		.clockMem(CLOCK), 
		.reset(Reset), 
		.PC(PC), 
		.Instr(Instr), 
		.regin(Regin), 
		.regout(Regout)
	);
		
endmodule