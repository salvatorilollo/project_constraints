#include <stdint.h>
#include "uart.h"
#include "print.h"

#define HYP_RAM_BASE 0x30000000UL          // from user_pkg.sv (your reference confirmed it)
#define NWORDS 2048u                         // 32-bit words per pass; shrink if tCSM asserts
#define PAT(i) (0xA5A50000u | (uint32_t)(i))// i < 65536 -> no bit overlap, checksum is exact

// rdcycle traps on CVE2; mcycle (M-mode) is readable in baremetal.
static inline uint32_t rd_cyc(void) {
  uint32_t c; __asm__ volatile("csrr %0, mcycle" : "=r"(c)); return c;
}
#define FENCE() __asm__ volatile("fence rw,rw" ::: "memory")

int main(void) {
  uart_init();
  volatile uint32_t *hr = (volatile uint32_t *)HYP_RAM_BASE;
  printf("\nHyperBus bench N=0x%x\n", (unsigned)NWORDS);

  FENCE();
  uint32_t t0 = rd_cyc();
  for (unsigned i = 0; i < NWORDS; i++) hr[i] = PAT(i);
  uint32_t drain = hr[NWORDS - 1];          // read-back forces the write buffer to flush
  FENCE();
  uint32_t wcyc = rd_cyc() - t0;
  (void)drain;

  FENCE();
  t0 = rd_cyc();
  uint32_t sum = 0;
  for (unsigned i = 0; i < NWORDS; i++) sum += hr[i];
  FENCE();
  uint32_t rcyc = rd_cyc() - t0;

  // correctness without a buffer: compare the read checksum to the closed-form expected sum
  printf("write cyc=0x%x\n", (unsigned)wcyc);
  printf("read  cyc=0x%x\n", (unsigned)rcyc);
  printf("sum=0x%x\n", (unsigned)sum);
  printf("exp=0xA5007F80\n");

  return 0;
}