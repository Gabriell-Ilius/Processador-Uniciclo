`include "Parametros.v"
`timescale 1ns / 1ps

module ImmGen_testbench;

	// 1. Entradas (reg)
	reg [31:0] tb_Instrucao;
	
	// 2. Saídas (wire)
	wire [31:0] tb_oImm;

	// 3. Instanciar o Dispositivo Sob Teste (DUT)
	ImmGen dut (
		.iInstrucao(tb_Instrucao),
		.oImm(tb_oImm)
	);

	// 4. Sequência de Teste
	initial begin
		$display("Iniciando Teste do Gerador de Imediatos...");
		
		// Teste 1: I-Type (addi t0, t0, -20)
		// Instrução: 0xFEC28293
		// Esperado: 0xFFFFFFEC (-20)
		tb_Instrucao = 32'hFEC28293;
		#100; // Espera 100 ns

		// Teste 2: S-Type (sw t0, -20(sp))
		// Instrução: 0xFE512A23
		// Esperado: 0xFFFFFFEC (-20)
		tb_Instrucao = 32'hFE512A23;
		#100;
		
		// Teste 3: B-Type (beq x0, x0, -8)
		// Instrução: 0xFE000C63
		// Esperado: 0xFFFFFFF8 (-8)
		tb_Instrucao = 32'hFE000C63;
		#100;

		// Teste 4: U-Type (lui t0, 0xABCD0)
		// Instrução: 0xABCD02B7
		// Esperado: 0xABCD0000
		tb_Instrucao = 32'hABCD02B7;
		#100;
		
		// Teste 5: J-Type (jal t0, -4)
		// Instrução: 0xFFF002EF
		// Esperado: 0xFFFFFFFC (-4)
		tb_Instrucao = 32'hFFF002EF;
		#100;
		
		$display("Testes concluidos.");
		$finish; // Termina a simulação
	end
	
	// 5. Monitor (opcional, para ver no console)
	// $monitor("Tempo=%0t | Instrucao=h%h --> Imediato=h%h (%d)", 
	// 		 $time, tb_Instrucao, tb_oImm, tb_oImm);

endmodule