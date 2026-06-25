// test_pattern.c
// Minimal Neopixel test: solid colors, checkerboard, X pattern.
// Use this to validate the decode pipeline before trying complex animations.
// MODIFIED: Added serial debug output of actual Neopixel bitstream bytes

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

// Helper function to print the raw bitstream that would be sent to NeoPixels
static void print_neopixel_frame(uint32_t *frame, int num_pixels, const char *label) {
    printf("\n=== NeoPixel Frame: %s ===\n", label);
    printf("GRB format (24 bits per pixel):\n\n");
    
    for (int i = 0; i < num_pixels; i++) {
        uint32_t color = frame[i];
        
        // Extract G, R, B (NeoPixel uses GRB order)
        uint8_t g = (color >> 16) & 0xFF;
        uint8_t r = (color >> 8) & 0xFF;
        uint8_t b = color & 0xFF;
        
        printf("Pixel %2d: ", i);
        printf("GRB=0x%02X%02X%02X", g, r, b);
        printf("  (R=%3d G=%3d B=%3d)\n", r, g, b);
        
        // Print the actual bits that would be sent (each byte as 8 bits)
        if ((i % 4) == 3) {
            // Show bitstream for every 4th pixel
            printf("          Bits: G[");
            for (int bit = 7; bit >= 0; bit--) printf("%x", (g >> bit) & 1);
            printf("] R[");
            for (int bit = 7; bit >= 0; bit--) printf("%x", (r >> bit) & 1);
            printf("] B[");
            for (int bit = 7; bit >= 0; bit--) printf("%x", (b >> bit) & 1);
            printf("]\n");
        }
    }
    //printf("\nTotal pixels: %x, Total bits: %d (24 bits/pixel)\n\n", num_pixels, num_pixels * 24);
}

// Print all values in the FIFO regiser (max 256 pixels)
static void print_frame_values(uint32_t *frame, int num_pixels) {
    printf("Frame values (hex):\n");
    for (int i = 0; i < num_pixels; i++) {
        if ((i % 8) == 0) printf("\n  [%02d-%02d] ", i, i+7);
        printf(" 0x%06X", frame[i]);
    }
    printf("\n\n");
}

static void send(void) {
    *reg32(NPX_BASE_ADDR, NPX_FIFO_REG_OFFSET) = NPX_FIFO_REG_MODE_FIFO;
    for (int i = 0; i < NUM_PIXELS; i++) {
        *reg32(NPX_BASE_ADDR, NPX_FIFO_DATA_REG_OFFSET) = frame[i];
    }
    // wait for the serializer to drain the FIFO before flushing it
    while (*reg32(NPX_BASE_ADDR, NPX_FIFO_DATA_REG_OFFSET) != 0)
        ;
    *reg32(NPX_BASE_ADDR, NPX_FIFO_REG_OFFSET) = NPX_FIFO_REG_DEACTIVATED;
}

static void send_with_debug(void) {
    printf("\n--- Sending frame to NeoPixel FIFO ---\n");
    printf("FIFO base address: 0x%08X\n", NPX_BASE_ADDR);
    printf("FIFO register offset: 0x%02X\n", NPX_FIFO_REG_OFFSET);
    printf("FIFO data offset: 0x%02X\n", NPX_FIFO_DATA_REG_OFFSET);
    printf("Pixels to send: %d\n", NUM_PIXELS);
    
    // Print the raw frame values before sending
    //print_frame_values(frame, NUM_PIXELS);
    
    // Print the formatted frame (GRB + bits)
    print_neopixel_frame(frame, NUM_PIXELS, "Current Frame");
    
    // Send to FIFO
    *reg32(NPX_BASE_ADDR, NPX_FIFO_REG_OFFSET) = NPX_FIFO_REG_MODE_FIFO;
    for (int i = 0; i < NUM_PIXELS; i++) {
        uint32_t color = frame[i];
        *reg32(NPX_BASE_ADDR, NPX_FIFO_DATA_REG_OFFSET) = color;
        
        // Debug: confirm write
        if (i < 4) {
            uint32_t readback = *reg32(NPX_BASE_ADDR, NPX_FIFO_DATA_REG_OFFSET);
            printf("  FIFO write[%d]: Wrote 0x%x\n", i, color);
        }
    }
    *reg32(NPX_BASE_ADDR, NPX_FIFO_REG_OFFSET) = NPX_FIFO_REG_DEACTIVATED;
    
    printf("--- Frame sent successfully ---\n");
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
    
    // Print header
    printf("\n========================================\n");
    printf("NeoPixel Test Pattern - Debug Mode\n");
    printf("========================================\n");
    printf("Matrix: %dx%d = %d pixels\n", WIDTH, HEIGHT, NUM_PIXELS);
    printf("Expected NeoPixel timings: T0H=0.35us, T0L=0.8us, T1H=0.7us, T1L=0.6us\n");
    printf("Bitstream format: GRB (Green, Red, Blue) 8 bits each\n\n");

    // ---- Frame 1: solid RED ----
    for (int i = 0; i < NUM_PIXELS; i++) frame[i] = RED;
    send_with_debug();
    delay_ms(2000);  // Increased delay to read output

    // ---- Frame 2: solid GREEN ----
    for (int i = 0; i < NUM_PIXELS; i++) frame[i] = GREEN;
    send_with_debug();
    delay_ms(2000);

    // ---- Frame 3: solid BLUE ----
    for (int i = 0; i < NUM_PIXELS; i++) frame[i] = BLUE;
    send_with_debug();
    delay_ms(2000);

    // ---- Frame 4: checkerboard RED/BLACK ----
    for (int row = 0; row < HEIGHT; row++)
        for (int col = 0; col < WIDTH; col++)
            frame[row * WIDTH + col] = ((row + col) & 1) ? RED : BLACK;
    send_with_debug();
    delay_ms(2000);

    // ---- Frame 5: top row only, GREEN ----
    for (int i = 0; i < NUM_PIXELS; i++) frame[i] = BLACK;
    for (int col = 0; col < WIDTH; col++) frame[col] = GREEN;  // row 0
    send_with_debug();
    delay_ms(2000);

    // ---- Frame 6: left column only, BLUE ----
    for (int i = 0; i < NUM_PIXELS; i++) frame[i] = BLACK;
    for (int row = 0; row < HEIGHT; row++) frame[row * WIDTH] = BLUE; // col 0
    send_with_debug();
    delay_ms(2000);

    // ---- Frame 7: X pattern, WHITE-ish ----
    for (int i = 0; i < NUM_PIXELS; i++) frame[i] = BLACK;
    for (int i = 0; i < WIDTH; i++) {
        frame[i * WIDTH + i] = 0x303030u;               // main diagonal
        frame[i * WIDTH + (WIDTH - 1 - i)] = 0x303030u;  // anti diagonal
    }
    send_with_debug();
    delay_ms(2000);

    // ---- Frame 8: all off ----
    for (int i = 0; i < NUM_PIXELS; i++) frame[i] = BLACK;
    send_with_debug();
    delay_ms(1000);

    printf("\n========================================\n");
    printf("Test pattern complete! Check LED strip.\n");
    printf("========================================\n");
    uart_write_flush();
    return 0;
}