`ifndef PARAM
 `define PARAM

/* Operacoes da ULA */
`define ZERO	  32'd0
`define OPAND	  5'd0
`define OPOR	  5'd1
`define OPXOR	  5'd2
`define OPADD	  5'd3
`define OPSUB	  5'd4
`define OPSLT	  5'd5
`define OPSLTU	  5'd6
`define OPSLL	  5'd7
`define OPSRL	  5'd8
`define OPSRA	  5'd9
`define OPLUI	  5'd10
`define OPMUL	  5'd11
`define OPMULH	  5'd12
`define OPMULHU	  5'd13
`define OPMULHSU  5'd14
`define OPDIV	  5'd15
`define OPDIVU	  5'd16
`define OPREM	  5'd17
`define OPREMU	  5'd18
`define OPNULL	  5'd31 // saída ZERO
	
/*OpCodes */
`define OPC_LOAD	 7'b0000011
`define OPC_OPIMM	 7'b0010011
`define OPC_STORE	 7'b0100011
`define OPC_RTYPE	 7'b0110011
`define OPC_BRANCH	 7'b1100011
`define OPC_JALR	 7'b1100111
`define OPC_JAL		 7'b1101111
`define OPC_LUI		 7'b0110111
	
/* Funct 7 */
`define FUNCT7_ADD	 7'b0000000
`define FUNCT7_SUB   7'b0100000
`define FUNCT7_SLT	 7'b0000000
`define FUNCT7_OR	 7'b0000000
`define FUNCT7_AND	 7'b0000000
	
/* Funct 3 */
`define FUNCT3_LW	 3'b010
`define FUNCT3_SW	 3'b010
`define FUNCT3_ADD	 3'b000
`define FUNCT3_SUB	 3'b000
`define FUNCT3_SLT	 3'b010
`define FUNCT3_OR	 3'b110
`define FUNCT3_AND	 3'b111
`define FUNCT3_BEQ	 3'b000
`define FUNCT3_JALR	 3'b000
	
	
/* Endereços */
`define TEXT_ADDRESS  32'h0040_0000
`define DATA_ADDRESS  32'h1001_0000
`define STACK_ADDRESS 32'h1001_03FC
`define GP DATA_ADDRESS

`endif