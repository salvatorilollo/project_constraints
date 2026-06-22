// test_pattern.c
// Minimal Neopixel test: solid colors, checkerboard, X pattern.
// Use this to validate the decode pipeline before trying complex animations.

#include <stdint.h>
#include "uart.h"
#include "print.h"
#include "neopixel.h"
#include "util.h"

#define WIDTH      8
#define HEIGHT     8
#define NUM_PIXELS (WIDTH * HEIGHT)

static uint32_t frame[NUM_PIXELS];

#define RED   0x300000u
#define GREEN 0x003000u
#define BLUE  0x000030u
#define BLACK 0x000000u

static void send(void) {
    *reg32(NPX_BASE_ADDR, NPX_FIFO_REG_OFFSET) = NPX_FIFO_REG_MODE_FIFO;
    for (int i = 0; i < NUM_PIXELS; i++)
        *reg32(NPX_BASE_ADDR, NPX_FIFO_DATA_REG_OFFSET) = frame[i];
    *reg32(NPX_BASE_ADDR, NPX_FIFO_REG_OFFSET) = NPX_FIFO_REG_DEACTIVATED;
}

static void delay_ms(uint32_t ms) {
    volatile uint32_t c;
    uint32_t cycles = ms * 100000;
    uint32_t t0;
    asm volatile("csrr %0, mcycle" : "=r"(t0));
    do { asm volatile("csrr %0, mcycle" : "=r"(c)); } while ((c - t0) < cycles);
}

int main(void) {
    uart_init();
    neopixel_init();

    // ---- Frame 1: solid RED ----
    for (int i = 0; i < NUM_PIXELS; i++) frame[i] = RED;
    send();
    delay_ms(1);

    // ---- Frame 2: solid GREEN ----
    for (int i = 0; i < NUM_PIXELS; i++) frame[i] = GREEN;
    send();
    delay_ms(1);

    // ---- Frame 3: solid BLUE ----
    for (int i = 0; i < NUM_PIXELS; i++) frame[i] = BLUE;
    send();
    delay_ms(1);

    // ---- Frame 4: checkerboard RED/BLACK ----
    for (int row = 0; row < HEIGHT; row++)
        for (int col = 0; col < WIDTH; col++)
            frame[row * WIDTH + col] = ((row + col) & 1) ? RED : BLACK;
    send();
    delay_ms(1);

    // ---- Frame 5: top row only, GREEN ----
    for (int i = 0; i < NUM_PIXELS; i++) frame[i] = BLACK;
    for (int col = 0; col < WIDTH; col++) frame[col] = GREEN;  // row 0
    send();
    delay_ms(1);

    // ---- Frame 6: left column only, BLUE ----
    for (int i = 0; i < NUM_PIXELS; i++) frame[i] = BLACK;
    for (int row = 0; row < HEIGHT; row++) frame[row * WIDTH] = BLUE; // col 0
    send();
    delay_ms(1);

    // ---- Frame 7: X pattern, WHITE-ish ----
    for (int i = 0; i < NUM_PIXELS; i++) frame[i] = BLACK;
    for (int i = 0; i < WIDTH; i++) {
        frame[i * WIDTH + i] = 0x303030u;               // main diagonal
        frame[i * WIDTH + (WIDTH - 1 - i)] = 0x303030u;  // anti diagonal
    }
    send();
    delay_ms(1);

    // ---- Frame 8: all off ----
    for (int i = 0; i < NUM_PIXELS; i++) frame[i] = BLACK;
    send();
    delay_ms(1);

    printf("Test pattern done\n");
    uart_write_flush();
    return 0;
}