/*
 * =====================================================================================
 *
 *       Filename:  basic.c
 *
 *    Description:  This file contains a high-level C language program which corresponds 
 *    with the Armv4 assembly program (and ultimately machine code) provided in `basic.asm`
 *    and `basic.dat`. This code is just for illustration purposes, and should not be compiled 
 *    or executed! 
 *
 *        Version:  1.0
 *        Created:  02/02/2022 13:54:54
 *       Revision:  none
 *       Compiler:  clang
 *
 *         Author:  NJKR
 *
 * =====================================================================================
 */
#include <stdlib.h>

int main(void) {

    // MAIN
    int a = 0; 
    int c = 5; 
    int d = 12; 
    int h = 3; 
    int e = h | c; 
    int f = d & e; 

    f = f + e; 
    int i = f - h; 

    if (i == 0){
        // END
        int* target_address = 0x00000064; 
        *target_address = c; 
    }

    i = d - e; 

    if (i > 0){
        // AROUND 
        i = h - c; 
        h = f + 1; 
        h = h - c; 
        int* target_address = 0x00000060; 
        *target_address = h; 
        c = *target_address; 
        // END
        int* target_address = 0x00000064; 
        *target_address = c; 
    }
    else {
        // should be skipped 
        f = a + 0; 
    }
}
