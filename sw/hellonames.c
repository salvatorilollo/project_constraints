// Copyright (c) 2024 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0/
//
// Authors:
// - Philippe Sauter <phsauter@iis.ee.ethz.ch>

#include "uart.h"
#include "print.h"
#include "util.h"

int main() {
    uart_init(); // setup the uart peripheral

    // simple printf support (only prints text and hex numbers)
    volatile uint32_t *rom = (volatile uint32_t *) USER_ROM_BASE_ADDR;
    printf("User ROM content: ");
    for (int i = 0; i < 17; i++) {
        char c = (char) rom[i];  
        printf("%c", c);
    }
    printf("\n");
    // wait until uart has finished sending
    uart_write_flush();

    return 0;
}
