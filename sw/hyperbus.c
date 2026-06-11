// Copyright 2024 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
//
// HyperBus smoke test for Croc + HyperRAM (S27KS0641 simulation model)

#include <stdint.h>
#include <stddef.h>

#include "uart.h"
#include "print.h"

// ----- Memory map (must match user_pkg.sv) -----
#define HYP_RAM_BASE   0x30000000UL
#define HYP_CFG_BASE   0x40000000UL

// ----- HyperBus controller register offsets -----
#define HYP_REG_T_LATENCY_ACCESS        0x00
#define HYP_REG_EN_LATENCY_ADDITIONAL   0x04
#define HYP_REG_T_BURST_MAX             0x08
#define HYP_REG_T_READ_WRITE_RECOVERY   0x0C
#define HYP_REG_T_RX_CLK_DELAY          0x10
#define HYP_REG_T_TX_CLK_DELAY          0x14
#define HYP_REG_ADDRESS_MASK_MSB        0x18
#define HYP_REG_ADDRESS_SPACE           0x1C
#define HYP_REG_PHYS_IN_USE             0x20
#define HYP_REG_WHICH_PHY               0x24
#define HYP_REG_T_CSH_CYCLES            0x28
#define HYP_REG_CHIP0_START             0x2C
#define HYP_REG_CHIP0_END               0x30

#define BUFSZ 16

#define REG32(addr)  (*((volatile uint32_t *)(addr)))
#define HYP_CFG(off) REG32(HYP_CFG_BASE + (off))

static inline uint64_t rdcycle(void) {
  uint32_t lo, hi, hi2;
  do {
    __asm__ volatile ("rdcycleh %0" : "=r"(hi));
    __asm__ volatile ("rdcycle  %0" : "=r"(lo));
    __asm__ volatile ("rdcycleh %0" : "=r"(hi2));
  } while (hi != hi2);
  return ((uint64_t)hi << 32) | lo;
}

static inline void fence_rw_rw(void) {
  __asm__ volatile("fence rw,rw" ::: "memory");
}

static uint8_t buf_write[BUFSZ];
static uint8_t buf_read[BUFSZ];

int main(void) {
  uart_init();
  printf("\n=== HyperBus test ===\n");

  // Memory barrier
  __asm__ volatile("fence rw,rw" ::: "memory");

  // ----- Step 2: single-byte test -----
  printf("Step 2: single-byte test\n");
  volatile uint8_t *hyperram = (volatile uint8_t *)HYP_RAM_BASE;

  fence_rw_rw();
  hyperram[0] = 0x5A;
  fence_rw_rw();

  uint8_t single_read = hyperram[0];
  printf("  HyperRAM[0] = 0x%x (expected 0x5A)\n", single_read);

  if (single_read != 0x5A) {
    printf("FAIL: single-byte test\n");
    return 1;
  }

  // ----- Step 3: 32-bit aligned test -----
  printf("Step 3: 32-bit aligned test\n");
  volatile uint32_t *hyperram_w = (volatile uint32_t *)HYP_RAM_BASE;

  fence_rw_rw();
  hyperram_w[0] = 0xDEADBEEF;
  hyperram_w[1] = 0xCAFEBABE;
  fence_rw_rw();

  uint32_t w0 = hyperram_w[0];
  uint32_t w1 = hyperram_w[1];
  printf("  word[0] = 0x%x (expected 0xDEADBEEF)\n", w0);
  printf("  word[1] = 0x%x (expected 0xCAFEBABE)\n", w1);

  if (w0 != 0xDEADBEEF || w1 != 0xCAFEBABE) {
    printf("FAIL: 32-bit test\n");
    return 1;
  }

  // ----- Step 4: buffer test -----
  printf("Step 4: buffer test (16 bytes)\n");
  for (size_t i = 0; i < BUFSZ; i++) {
    buf_write[i] = (uint8_t)(0xA0 + i);
  }

  fence_rw_rw();
  uint64_t t0 = rdcycle();
  for (size_t i = 0; i < BUFSZ; i++) {
    hyperram[i] = buf_write[i];
  }
  fence_rw_rw();
  uint64_t t1 = rdcycle();
  printf("  Write cycles: 0x%x\n", (uint32_t)(t1 - t0));

  fence_rw_rw();
  t0 = rdcycle();
  for (size_t i = 0; i < BUFSZ; i++) {
    buf_read[i] = hyperram[i];
  }
  fence_rw_rw();
  t1 = rdcycle();
  printf("  Read cycles:  0x%x\n", (uint32_t)(t1 - t0));

  int mismatches = 0;
  size_t first_mismatch = 0;
  for (size_t i = 0; i < BUFSZ; i++) {
    if (buf_write[i] != buf_read[i]) {
      if (mismatches == 0) first_mismatch = i;
      mismatches++;
    }
  }

  if (mismatches != 0) {
    printf("FAIL: 0x%x mismatches; first at 0x%x: wrote 0x%x, read 0x%x\n",
           (uint32_t)mismatches,
           (uint32_t)first_mismatch,
           buf_write[first_mismatch],
           buf_read[first_mismatch]);
    return 1;
  }

  printf("=== PASS ===\n");
  return 0;
}