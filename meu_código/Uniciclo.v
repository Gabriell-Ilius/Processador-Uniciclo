`ifndef PARAM
	`include "Parametros.v" // Definições de constantes (opcodes, functs, etc.)
`endif

module Uniciclo (
	input logic clockCPU, clockMem, // Clocks (CPU e Memória)
	input logic reset,            // Reset
	output logic [31:0] PC,       // Program Counter atual
	output logic [31:0] Instr,    // Instrução atual
	input  logic [4:0] regin,    // Entrada para display de registrador
	output logic [31:0] regout   // Saída para display de registrador
);

    // --- Sinais Internos Principais ---
    logic [31:0] PCNext, PCPlus4, PCTargetBranch, PCTargetJump; // Lógica do PC
    logic [31:0] Imm;          // Imediato gerado
    logic [31:0] ReadData1, ReadData2; // Saídas do Banco de Registradores
    logic [31:0] ALUResult, ALUB_Input; // Entradas e Saída da ULA
    logic [31:0] MemDataRead;  // Dado lido da Memória de Dados
    logic [31:0] WriteDataReg; // Dado a ser escrito no Banco de Registradores
    logic ZeroULA;      // Flag Zero da ULA

    // --- Sinais de Controle ---
    logic Mem2Reg, LeMem, Branch, EscreveMem, OrigULA, EscreveReg, Jump;
    logic [1:0] ALUOp;      // Sinal do Controle Principal para ControleULA
    logic [4:0] ALUControl; // Sinal de Controle da ULA
    logic PCSrc;        // Sinal para MUX de seleção do próximo PC

    // --- Inicialização ---
    initial begin
        PC     <= TEXT_ADDRESS; // Define endereço inicial do PC
        Instr  <= 32'b0;
        regout <= 32'b0;
    end

    // --- Estágio IF (Instruction Fetch) ---

    // Cálculo dos possíveis próximos PCs
    assign PCPlus4 = PC + 32'd4;
    assign PCTargetBranch = PC + Imm; // Endereço alvo para BEQ e JAL
    assign PCTargetJump = ALUResult;  // Endereço alvo para JALR (vem da ULA: rs1 + Imm)

    // Seleção do próximo PC: PC+4 ou endereço de desvio
    assign PCSrc = (Branch & ZeroULA) | Jump; // Desvia se (BEQ tomado) OU (JAL ou JALR)
    assign PCNext = PCSrc ? (Jump & (Instr[6:0] == OPC_JALR) ? PCTargetJump : PCTargetBranch) : PCPlus4;
            // Se PCSrc=1: Se for JALR, usa PCTargetJump (resultado da ULA), senão (JAL ou BEQ) usa PCTargetBranch.
            // Se PCSrc=0: Usa PC+4.

    // Atualização do PC
    always @(posedge clockCPU or posedge reset) begin
        if (reset)
            PC <= TEXT_ADDRESS;
        else
            PC <= PCNext;
    end

    // Busca da Instrução na Memória
    ramI MemInstrucoes (
        .address(PC[11:2]), // Endereço em words
        .clock(clockMem),
        .data(),          // Não escreve
        .wren(1'b0),
        .q(Instr)         // Instrução lida
    );

    // --- Estágio ID (Instruction Decode & Register Fetch) ---

    // Banco de Registradores
    Registers BancoRegs (
        .iCLK(clockCPU),
        .iRST(reset),
        .iRegWrite(EscreveReg),         // Habilita escrita? (Vem do Controle)
        .iReadRegister1(Instr[19:15]),  // rs1
        .iReadRegister2(Instr[24:20]),  // rs2
        .iWriteRegister(Instr[11:7]),   // rd
        .iWriteData(WriteDataReg),      // Dado a escrever (Vem do MUX final)
        .oReadData1(ReadData1),         // Valor lido de rs1
        .oReadData2(ReadData2),         // Valor lido de rs2
        .iRegDispSelect(regin),         // Para display
        .oRegDisp(regout)               // Para display
    );

    // Geração de Imediato
    ImmGen GeradorImm (
        .iInstrucao(Instr),
        .oImm(Imm)                      // Imediato estendido
    );

    // Unidade de Controle Principal (gera sinais baseados no opcode)
    Controle UnidadeControle (
        .opcode(Instr[6:0]),
        .Mem2Reg(Mem2Reg),
        .LeMem(LeMem),
        .Branch(Branch),
        .ALUOp(ALUOp),
        .EscreveMem(EscreveMem),
        .OrigULA(OrigULA),
        .EscreveReg(EscreveReg),
        .Jump(Jump)
    );

    // --- Estágio EX (Execute) ---

    // Controle da ULA (gera controle específico baseado em ALUOp, funct3, funct7)
    ControleULA ULAControle (
        .ALUOp(ALUOp),
        .funct7(Instr[31:25]),
        .funct3(Instr[14:12]),
        .ALUControl(ALUControl)
    );

    // MUX para selecionar a segunda entrada da ULA (ReadData2 ou Imediato)
    assign ALUB_Input = OrigULA ? Imm : ReadData2;

    // ULA
    ALU UnidadeLogicaAritmetica (
        .iControl(ALUControl), // Operação a realizar
        .iA(ReadData1),        // Primeiro operando (sempre rs1)
        .iB(ALUB_Input),       // Segundo operando (rs2 ou Imm)
        .oResult(ALUResult),   // Resultado da operação
        .Zero(ZeroULA)         // Flag Zero (para BEQ)
    );

    // --- Estágio MEM (Memory Access) ---

    // Acesso à Memória de Dados
    ramD MemDados (
        .address(ALUResult[11:2]), // Endereço (calculado pela ULA para LW/SW)
        .clock(clockMem),
        .data(ReadData2),         // Dado a ser escrito (rs2 para SW)
        .wren(EscreveMem),        // Habilita escrita? (Vem do Controle)
        .q(MemDataRead)           // Dado lido da memória (para LW)
    );

    // --- Estágio WB (Write Back) ---

    // MUX para selecionar o dado a ser escrito de volta no Banco de Registradores
    assign WriteDataReg = Jump ? PCPlus4 :              // Se JAL/JALR, escreve PC+4
                         (Mem2Reg ? MemDataRead :   // Se LW (Mem2Reg=1), escreve dado da memória
                          ALUResult);             // Senão (R-Type, ADDI, LUI), escreve resultado da ULA

endmodule