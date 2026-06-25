// car_animation.c
// Croc + HyperBus + NeoPixel demo: a car driving across an 8x8 matrix.
//
// The whole animation lives in HyperRAM (external DRAM); only ONE frame is ever
// held in on-chip SRAM. This is the thing standalone Croc cannot do -- its SRAM
// cannot hold the full frame sequence. Frame generation is a contiguous HyperRAM
// write stream, so it also exercises the write-coalescing path you built, and we
// time it so you get a number for the report.

#include <stdint.h>
#include "uart.h"
#include "print.h"
#include "timer.h"
#include "util.h"
#include "neopixel.h"

// kept for drop-in parity with your neopixel test environment
#define TB_FREQUENCY 20000000
#define TB_BAUDRATE     38400

// ---------------- geometry ----------------
#define WIDTH       8
#define HEIGHT      8
#define NUM_PIXELS  (WIDTH * HEIGHT)        // 64

// ---------------- car sprite --------------
#define CAR_W       6
#define CAR_H       4
#define CAR_TOP     (HEIGHT - 1 - CAR_H)    // car on rows 3..6, road on row 7
#define TRACK       (WIDTH + CAR_W)         // columns for one full enter->exit lap

// ---------------- animation knobs ---------
// SIM:  most of the run time is the NeoPixel module serializing each frame at
//       WS2812 rate (~1.9 ms/frame), and simulated time is expensive. Keep
//       NUM_FRAMES small and FRAME_MS = 0 for a functional check.
// HW:   raise LAPS / FRAME_MS / PLAY_LOOPS for a long, slow, looping animation.
#define LAPS        1
#define NUM_FRAMES  (LAPS * TRACK)          // distinct frames stored in HyperRAM
#define FRAME_MS    0                       // extra per-frame delay (HW: ~50-80)
#define PLAY_LOOPS  1                       // HW: large, or loop forever

// ---------------- memory map --------------
#define HYP_RAM_BASE 0x30000000u
static volatile uint32_t * const hyperram = (volatile uint32_t *)HYP_RAM_BASE;
#define FENCE() __asm__ volatile("fence rw,rw" ::: "memory")

// The ONLY on-chip copy: one frame. The full NUM_FRAMES sequence lives in HyperRAM.
static uint32_t line[NUM_PIXELS];

// ---------------- colors (0x00RRGGBB, same packing as your neopixel test) -----
#define COL_BG      0x000000u
#define COL_BODY    0x400000u   // red
#define COL_WINDOW  0x002040u   // cyan
#define COL_WHEEL   0x202020u   // grey/white
#define COL_ROAD    0x020202u   // dim road
#define COL_DASH    0x303000u   // yellow lane dashes

// sprite codes: 0 transparent, 1 body, 2 window, 3 wheel
static const uint8_t car[CAR_H][CAR_W] = {
    {0, 0, 2, 2, 0, 0},   // roof + windows
    {0, 1, 2, 2, 1, 1},   // cabin + hood
    {1, 1, 1, 1, 1, 1},   // body
    {0, 3, 0, 0, 3, 0},   // wheels
};

static inline uint32_t car_color(uint8_t code) {
    if (code == 1) return COL_BODY;
    if (code == 2) return COL_WINDOW;
    return COL_WHEEL;
}

// Build frame f into buf[64]: background + scrolling road + car at its position.
static void render_frame(uint32_t *buf, int f) {
    int x = (f % TRACK) - CAR_W;            // car's left column (enters from left)

    for (int row = 0; row < HEIGHT; row++) {
        for (int col = 0; col < WIDTH; col++) {
            uint32_t c = COL_BG;
            if (row == HEIGHT - 1) {        // road row: dashes scroll left
                c = (((col + f) & 3) == 0) ? COL_DASH : COL_ROAD;
            }
            buf[row * WIDTH + col] = c;
        }
    }

    for (int cr = 0; cr < CAR_H; cr++) {
        for (int cc = 0; cc < CAR_W; cc++) {
            uint8_t code = car[cr][cc];
            if (code == 0) continue;
            int col = x + cc;
            if (col < 0 || col >= WIDTH) continue;   // clip off-screen columns
            buf[(CAR_TOP + cr) * WIDTH + col] = car_color(code);
        }
    }
}

// your known-good FIFO send
static void neopixel_send_frame(uint32_t *pixels) {
    *reg32(NPX_BASE_ADDR, NPX_FIFO_REG_OFFSET) = NPX_FIFO_REG_MODE_FIFO;
    for (int i = 0; i < NUM_PIXELS; i++)
        *reg32(NPX_BASE_ADDR, NPX_FIFO_DATA_REG_OFFSET) = pixels[i];

    while (*reg32(NPX_BASE_ADDR, NPX_FIFO_DATA_REG_OFFSET) != 0); //drain before flush                                                    // drain before flush
    *reg32(NPX_BASE_ADDR, NPX_FIFO_REG_OFFSET) = NPX_FIFO_REG_DEACTIVATED;
}

static inline uint32_t read_mcycle(void) {
    uint32_t c;
    asm volatile ("csrr %0, mcycle" : "=r"(c));
    return c;
}

// Generate the whole animation into HyperRAM. Each frame is 64 contiguous words,
// so this is exactly the contiguous-write workload your coalescing accelerates.
static void generate_to_hyperram(void) {
    FENCE();
    for (int f = 0; f < NUM_FRAMES; f++) {
        render_frame(line, f);
        uint32_t base = (uint32_t)f * NUM_PIXELS;
        for (int i = 0; i < NUM_PIXELS; i++)
            hyperram[base + i] = line[i];
    }
    // read back one word per frame so every frame's burst is flushed, not just the last
    volatile uint32_t drain = 0;
    for (int f = 0; f < NUM_FRAMES; f++)
        drain += hyperram[(uint32_t)f * NUM_PIXELS];
    (void)drain;
    FENCE();
}

// Stream each frame from HyperRAM through the one-frame SRAM buffer to the matrix.
static void play_from_hyperram(void) {
    for (int f = 0; f < NUM_FRAMES; f++) {
        uint32_t base = (uint32_t)f * NUM_PIXELS;
        for (int i = 0; i < NUM_PIXELS; i++)
            line[i] = hyperram[base + i];
        neopixel_send_frame(line);
        if (FRAME_MS) sleep_ms(FRAME_MS);
    }
}

int main(void) {
    uart_init();
    neopixel_init();
    // NOTE: assumes the HyperBus controller is already initialized exactly as in
    // your working benchmark. If that needed CFG writes / a hyperram_init(),
    // call it here before touching 0x30000000.

    printf("Car demo: generating frames into HyperRAM...\n");
    uart_write_flush();

    uint32_t t0 = read_mcycle();
    generate_to_hyperram();
    uint32_t t1 = read_mcycle();

    // optional diagnostics -- need %x support in your printf; safe to delete
    printf("frames=0x%x  gen_cyc=0x%x\n",
           (unsigned)NUM_FRAMES, (unsigned)(t1 - t0));
    printf("hyperram_bytes=0x%x  sram_frame_bytes=0x%x\n",
           (unsigned)((uint32_t)NUM_FRAMES * NUM_PIXELS * 4),
           (unsigned)(NUM_PIXELS * 4));
    uart_write_flush();

    for (int loop = 0; loop < PLAY_LOOPS; loop++)
        play_from_hyperram();

    printf("Done\n");
    uart_write_flush();
    return 0;   // signals jtag_wait_for_eoc to terminate
}