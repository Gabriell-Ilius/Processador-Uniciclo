`include "Parametros.v"
`timescale 1ns / 1ps

module Registradores_testbench;

	// 1. Entradas (reg)
	reg tb_CLK;
	reg tb_RST;
	reg tb_RegWrite;
	reg [4:0] tb_ReadAddr1;
	reg [4:0] tb_ReadAddr2;
	reg [4:0] tb_WriteAddr;
	reg [31:0] tb_WriteData;
	reg [4:0] tb_DispSelect;

	// 2. Saídas (wire)
	wire [31:0] tb_ReadData1;
	wire [31:0] tb_ReadData2;
	wire [31:0] tb_DispData;

	// 3. Instanciar o Dispositivo Sob Teste (DUT)
	Registers dut (
		.iCLK(tb_CLK),
		.iRST(tb_RST),
		.iRegWrite(tb_RegWrite),
		.iReadRegister1(tb_ReadAddr1),
		.iReadRegister2(tb_ReadAddr2),
		.iWriteRegister(tb_WriteAddr),
		.iWriteData(tb_WriteData),
		.oReadData1(tb_ReadData1),
		.oReadData2(tb_ReadData2),
		.iRegDispSelect(tb_DispSelect),
		.oRegDisp(tb_DispData)
	);

	// 4. Geração de Clock (a cada 5ns)
	initial begin
		tb_CLK = 0;
		forever #5 tb_CLK = ~tb_CLK;
	end

	// 5. Sequência de Teste
	initial begin
		$display("Iniciando Teste do Banco de Registradores...");
		// -- Inicializa todas as entradas --
		tb_RST 		 = 0;
		tb_RegWrite  = 0;
		tb_ReadAddr1 = 0;
		tb_ReadAddr2 = 0;
		tb_WriteAddr = 0;
		tb_WriteData = 0;
		tb_DispSelect= 0;

		// -- Teste 1: Reset --
		$display("Teste 1: Aplicando Reset...");
		tb_RST = 1;
		#22; // Espera 22ns (passa por algumas bordas de clock)
		tb_RST = 0;
		#10;
		
		// -- Teste 2: Escrever 999 no reg x5 --
		$display("Teste 2: Escrevendo 999 em x5...");
		tb_RegWrite  = 1;
		tb_WriteAddr = 5'd5;
		tb_WriteData = 32'd999;
		@(posedge tb_CLK); // Espera a próxima borda de subida do clock
		tb_RegWrite = 0; // Desliga o write
		#10;

		// -- Teste 3: Ler o reg x5 (deve ser 999) --
		$display("Teste 3: Lendo x5 (esperando 999)...");
		tb_ReadAddr1 = 5'd5;
		#10; 

		// -- Teste 4: Tentar escrever 123 no reg x0 (deve falhar) --
		$display("Teste 4: Tentando escrever 123 em x0 (deve falhar)...");
		tb_RegWrite  = 1;
		tb_WriteAddr = 5'd0;
		tb_WriteData = 32'd123;
		@(posedge tb_CLK); 
		tb_RegWrite = 0;
		#10;

		// -- Teste 5: Ler o reg x0 (deve ser 0) --
		$display("Teste 5: Lendo x0 (esperando 0)...");
		tb_ReadAddr2 = 5'd0;
		#10;
		
		// -- Teste 6: Ler o reg x2 (Stack Pointer) pela porta Display --
		$display("Teste 6: Lendo x2 (SP) pela porta Display...");
		tb_DispSelect = 5'd2; // x2 = SP
		#10;

		$display("Testes concluidos.");
		$finish;
	end

endmodule