`ifndef PARAM // Verifica se os parâmetros já foram incluídos.
	`include "Parametros.v"
`endif

module Registers (
	// Entradas de Controle e Clock
	input wire 			iCLK, 
	input wire			iRST, 
	input wire			iRegWrite,
	
	// Entradas de Endereço de Leitura
	input wire  [4:0] 	iReadRegister1, 
	input wire  [4:0] 	iReadRegister2,

	// Entradas de Escrita	
	input wire  [4:0] 	iWriteRegister,
	input wire  [31:0] 	iWriteData,
	
	// Saídas de Dados de Leitura
	output wire [31:0] 	oReadData1, 
	output wire [31:0] 	oReadData2,
	
	// Porta de Display/Depuração (usada para ler um registrador específico para visibilidade/depuração)
	input wire  [4:0] 	iRegDispSelect,
	output 		[31:0] 	oRegDisp
);

	// Estrutura de memória do arquivo de registradores: 32 registradores, 32 bits de largura 
	reg [31:0] registers[31:0];

	// Definição do parâmetro (SP, Stack Pointer, que é geralmente x2)
	parameter SPR = 5'd2;  // SP
	reg [5:0] i; // Variável de loop para blocos initial/reset

	// Inicializa os registradores ao iniciar a simulação (não é sintetizado em hardware)
	initial begin
	// Define todos os registradores como 0 inicialmente
		for (i = 0; i <= 31; i = i + 1'b1)
			registers[i] = 32'd0;
		// Inicializa o Stack Pointer (x2) com o endereço predefinido
		registers[SPR] = `STACK_ADDRESS;
	end
	
	// PORTAS DE LEITURA COMBINACIONAL 
	// As operações de leitura são assíncronas e combinacionais (instantâneas).
	// RISC-V: Leituras de x0 sempre retornam 0, independentemente do que está armazenado.
	assign oReadData1 = registers[iReadRegister1];
	assign oReadData2 = registers[iReadRegister2];
	
	// Porta de Leitura de Display/Depuração (Assume-se que a leitura de x0 aqui é permitida se for usada para depuração)
	assign oRegDisp   = registers[iRegDispSelect];
	
	// PORTA DE ESCRITA SEQUENCIAL 
	// As operações de escrita são síncronas com a borda de subida do clock (posedge iCLK).
	always @(posedge iCLK or posedge iRST)
	begin
		if (iRST) // Reset Assíncrono (Reseta os registradores com iRST alto)
		begin
		// Reseta todos os registradores para 0
			for (i = 0; i <= 31; i = i + 1'b1)
				registers[i] <= 32'b0;
				
			// Re-inicializa o Stack Pointer (x2)
			registers[SPR] <= `STACK_ADDRESS;
		end
		else
		begin
		
			// Lógica de Controle de Escrita:
			// 1. Deve ter o sinal de Habilitação de Escrita (iRegWrite) alto.
			// 2. NÃO deve tentar escrever no registrador x0 (endereço 5'd0).
			
			if(iRegWrite && (iWriteRegister != 5'b0))
				registers[iWriteRegister] <= iWriteData;
		end
	end

endmodule