/*
 * =====================================================================================
 *
 *       Filename:  basic.asm 
 *
 *    Description:  This file contains an Armv4 assembly program exercises an Arm 
 *    processor which implements the following instructions: ADD (addition), SUB 
 *    (subtraction), AND (bitwise logical and), ORR (bitwise logical or), LDR (
 *    load word), STR (store word), B (branch). 
 * 
 *    If successful, the program instructs the processor to write the (decimal) 
 *    value 7 to the data memory at address 100. 
 *
 *    The associated program is provided as hexadecimal encoded machine code in 
 *    `basic.dat`.
 *
 *        Version:  1.0
 *        Created:  02/01/2022 17:02:58
 *       Revision:  none
 *       Compiler:  iverilog 
 *
 *         Author:  NJKR
 *      Reference:  david_harris@hmc.edu and sarah_harris@hmc.edu 20 December 2013
 *
 * =====================================================================================
 */
    MAIN:	 
         SUB R0, R15, R15 	    ; R0 = 0				
  		 ADD R2, R0, #5         ; R2 = 5             
  		 ADD R3, R0, #12        ; R3 = 12            
  		 SUB R7, R3, #9    	    ; R7 = 3             
  		 ORR R4, R7, R2    	    ; R4 = 3 OR 5 = 7              	1110 000 1100 0 0111 0100 0000 0000 0010 E1874002 0x10
  		 AND R5, R3, R4    	    ; R5 = 12 AND 7 = 4            	1110 000 0000 0 0011 0101 0000 0000 0100 E0035004 0x14
  		 ADD R5, R5, R4    	    ; R5 = 4 + 7 = 11              	1110 000 0100 0 0101 0101 0000 0000 0100 E0855004 0x18
  		 SUBS R8, R5, R7    	; R8 <= 11 - 3 = 8, set Flags   1110 000 0010 1 0101 1000 0000 0000 0111 E0558007 0x1c
  		 BEQ END        		; shouldn't be taken            0000 1010 0000  0000 0000 0000 0000 1100 0A00000C 0x20
  		 SUBS R8, R3, R4    	; R8 = 12 - 7  = 5             	1110 000 0010 1 0011 1000 0000 0000 0100 E0538004 0x24
  		 BGE AROUND       	    ; should be taken               1010 1010 0000  0000 0000 0000 0000 0000 AA000000 0x28
  		 ADD R5, R0, #0     	; should be skipped             1110 001 0100 0 0000 0101 0000 0000 0000 E2805000 0x2c
   AROUND:   
         SUBS R8, R7, R2   	    ; R8 = 3 - 5 = -2, set Flags   	1110 000 0010 1 0111 1000 0000 0000 0010 E0578002 0x30
         ADDLT R7, R5, #1  	    ; R7 = 11 + 1 = 12				1011 001 0100 0 0101 0111 0000 0000 0001 B2857001 0x34
         SUB R7, R7, R2    	    ; R7 = 12 - 5 = 7				1110 000 0010 0 0111 0111 0000 0000 0010 E0477002 0x38
         STR R7, [R3, #84]  	; mem[12+84] = 7		     	
         LDR R2, [R0, #96]  	; R2 = mem[96] = 7				1110 010 1100 1 0000 0010 0000 0110 0000 E5902060 0x40
         ADD R15, R15, R0	    ; PC <- PC + 8 (skips next)     1110 000 0100 0 1111 1111 0000 0000 0000 E08FF000 0x44
         ADD R2, R0, #14    	; shouldn't happen              1110 001 0100 0 0000 0010 0000 0000 0001 E280200E 0x48
         B END             	    ; always taken					1110 1010 0000 0000 0000 0000 0000 0001  EA000001 0x4c
         ADD R2, R0, #13   	    ; shouldn't happen				1110 001 0100 0 0000 0010 0000 0000 0001 E280200D 0x50
         ADD R2, R0, #10		; shouldn't happen				1110 001 0100 0 0000 0010 0000 0000 0001 E280200A 0x54
   END:     
         STR R2, [R0, #100] 	; mem[100] = 7                  1110 010 1100 0 0000 0010 0000 0101 0100 E5802064 0x58
