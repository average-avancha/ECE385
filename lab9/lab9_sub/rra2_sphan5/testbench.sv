module testbench ();

	 timeunit 10ns;
	 timeprecision 1ns;

	 logic        CLOCK_50;
	 logic [1:0]  KEY;
	 logic [7:0]  LEDG;
	 logic [17:0] LEDR;
	 logic [6:0]  HEX0;
	 logic [6:0]  HEX1;
	 logic [6:0]  HEX2;
	 logic [6:0]  HEX3;
	 logic [6:0]  HEX4;
	 logic [6:0]  HEX5;
	 logic [6:0]  HEX6;
	 logic [6:0]  HEX7;
	 logic [12:0] DRAM_ADDR;
	 logic [1:0]  DRAM_BA;
	 logic        DRAM_CAS_N;
	 logic        DRAM_CKE;
	 logic        DRAM_CS_N;
	 logic [31:0] DRAM_DQ;
	 logic [3:0]  DRAM_DQM;
	 logic        DRAM_RAS_N;
	 logic        DRAM_WE_N;
	 logic        DRAM_CLK;
	 
    logic CLK, RESET, AES_START, AES_DONE;
	 logic [127:0] msg_dec, AES_MSG_ENC, AES_MSG_DEC, AES_KEY, ARK_OUT, ISR_OUT, IMC_OUT, ISB_OUT;

    lab9_top tp(.*);

    always begin: CLOCK_GEN
        #1 CLK = ~CLK;
    end

    initial begin: CLOCK_INIT
		CLK = 0;
	 end

    always begin: Monitoring
        #2 AES_START = tp.lab9_qsystem.aes.decryption_core.AES_START;
           AES_DONE = tp.lab9_qsystem.aes.decryption_core.AES_DONE;
           msg_dec = tp.lab9_qsystem.aes.decryption_core.msg_dec;
           ARK_OUT = tp.lab9_qsystem.aes.decryption_core.ARK_OUT;
           ISR_OUT = tp.lab9_qsystem.aes.decryption_core.ISR_OUT;
           IMC_OUT = tp.lab9_qsystem.aes.decryption_core.IMC_OUT;
           ISB_OUT = tp.lab9_qsystem.aes.decryption_core.ISB_OUT;
	end
    
	 initial begin: testing
            RESET = 0;
        #2  AES_START = 1;
	end
endmodule 