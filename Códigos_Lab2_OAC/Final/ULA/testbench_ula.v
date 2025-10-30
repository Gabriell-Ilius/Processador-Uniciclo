// -----------------------------------------------------------------
// ARQUIVO: ALU_testbench.v
// -----------------------------------------------------------------

// Inclui as mesmas definições que a ALU usa
`include "Parametros.v"

// Define a escala de tempo: 1ns / 1ps
`timescale 1ns / 1ps

module ALU_testbench;

	// 1. Crie 'regs' para as ENTRADAS da ULA
	reg [4:0]  tb_iControl;
	reg signed [31:0] tb_iA;
	reg signed [31:0] tb_iB;

	// 2. Crie 'wires' para as SAÍDAS da ULA
	wire [31:0] tb_oResult;
	wire        tb_Zero;

	// 3. Instancie a ULA (o "Dispositivo Sob Teste" - DUT)
	// Conecte os regs e wires do testbench às portas da ULA
	ALU dut (
		.iControl(tb_iControl),
		.iA(tb_iA),
		.iB(tb_iB),
		.oResult(tb_oResult),
		.Zero(tb_Zero)
	);

	// 4. Crie o "Stimulus" (o que você estava desenhando no .vwf)
	initial begin
		// Use $display para imprimir no console
		$display("Iniciando Teste da ULA...");

		// Teste 1: ADD (10 + 5 = 15)
		tb_iControl = `OPADD;
		tb_iA       = 10;
		tb_iB       = 5;
		#100; // Espera 100 nanosegundos

		// Teste 2: SUB (10 - 10 = 0)
		tb_iControl = `OPSUB;
		tb_iA       = 10;
		tb_iB       = 10;
		#100; // Espera 100 ns

		// Teste 3: SLT (-5 < 2 = 1)
		tb_iControl = `OPSLT;
		tb_iA       = -5;
		tb_iB       = 2;
		#100; // Espera 100 ns
		
		// Teste 4: SLT (10 < 2 = 0)
		tb_iControl = `OPSLT;
		tb_iA       = 10;
		tb_iB       = 2;
		#100; // Espera 100 ns

		// Teste 5: AND (0x00FF & 0x3333 = 0x0033)
		tb_iControl = `OPAND;
		tb_iA       = 32'h0000_00FF;
		tb_iB       = 32'h0000_3333;
		#100; // Espera 100 ns
		
		// Teste 6: OR (0xF0F0 | 0x0F0F = 0xFFFF)
		tb_iControl = `OPOR;
		tb_iA       = 32'h0000_F0F0;
		tb_iB       = 32'h0000_0F0F;
		#100; // Espera 100 ns

		$display("Testes concluidos.");
		$finish; // Termina a simulação
	end

	// 5. (Opcional) Monitore as mudanças
	// Isso imprime no console toda vez que um valor mudar
	initial begin
		$monitor("Tempo=%0t | iControl=%b iA=%d iB=%d --> oResult=%d Zero=%b", 
				 $time, tb_iControl, tb_iA, tb_iB, tb_oResult, tb_Zero);
	end

endmodule