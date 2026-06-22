// rocket_animation.c
// Croc + HyperBus + NeoPixel demo: rocket launch on an 8x8 LED matrix.
//
// Phases:
//   1. Countdown  – LEDs light up row by row from bottom (red glow building up)
//   2. Liftoff    – rocket sprite climbs up the matrix with flame trail
//   3. Orbit      – starfield explosion, rocket disappears into space

#include <stdint.h>
#include "uart.h"
#include "print.h"
#include "neopixel.h"
#include "util.h"

#define TB_FREQUENCY 20000000
#define TB_BAUDRATE     38400

// ---------------- geometry ----------------
#define WIDTH      8
#define HEIGHT     8
#define NUM_PIXELS (WIDTH * HEIGHT)

// ---------------- memory map --------------
#define HYP_RAM_BASE 0x30000000u
static volatile uint32_t * const hyperram = (volatile uint32_t *)HYP_RAM_BASE;

static uint32_t frame[NUM_PIXELS];

// ---------------- colors ------------------
#define BLACK    0x000000u
#define RED      0x300000u
#define ORANGE   0x301000u
#define YELLOW   0x303000u
#define WHITE    0x303030u
#define BLUE     0x000030u
#define CYAN     0x003030u
#define DIM_STAR 0x050505u

// ---------------- helpers -----------------
static inline void px(int row, int col, uint32_t color) {
    if (row < 0 || row >= HEIGHT || col < 0 || col >= WIDTH) return;
    frame[row * WIDTH + col] = color;
}

static inline uint32_t get_px(int row, int col) {
    if (row < 0 || row >= HEIGHT || col < 0 || col >= WIDTH) return BLACK;
    return frame[row * WIDTH + col];
}

static void clear(void) {
    for (int i = 0; i < NUM_PIXELS; i++) frame[i] = BLACK;
}

static void send(void) {
    *reg32(NPX_BASE_ADDR, NPX_FIFO_REG_OFFSET) = NPX_FIFO_REG_MODE_FIFO;
    for (int i = 0; i < NUM_PIXELS; i++)
        *reg32(NPX_BASE_ADDR, NPX_FIFO_DATA_REG_OFFSET) = frame[i];
    *reg32(NPX_BASE_ADDR, NPX_FIFO_REG_OFFSET) = NPX_FIFO_REG_DEACTIVATED;
}

static void delay_ms(uint32_t ms) {
    volatile uint32_t c;
    uint32_t cycles = ms * (TB_FREQUENCY / 1000);
    uint32_t t0;
    asm volatile("csrr %0, mcycle" : "=r"(t0));
    do { asm volatile("csrr %0, mcycle" : "=r"(c)); } while ((c - t0) < cycles);
}

// simple lfsr for star twinkle
static uint32_t lfsr = 0xCAFEBABEu;
static uint32_t rnd(void) {
    lfsr ^= lfsr << 13;
    lfsr ^= lfsr >> 17;
    lfsr ^= lfsr << 5;
    return lfsr;
}

// ---------------- rocket sprite -----------
// 3 cols wide, drawn at (top_row, center_col=3)
// 0=bg, 1=body, 2=window, 3=flame
static const uint8_t rocket_body[5][3] = {
    {0, 1, 0},   // nose
    {1, 1, 1},   // upper body
    {1, 2, 1},   // cabin (window)
    {1, 1, 1},   // lower body
    {1, 0, 1},   // nozzles
};
#define ROCKET_H 5

static void draw_rocket(int top_row, uint32_t flame_col) {
    int cx = 3; // center column
    for (int r = 0; r < ROCKET_H; r++) {
        for (int dc = -1; dc <= 1; dc++) {
            uint8_t code = rocket_body[r][dc + 1];
            if (code == 0) continue;
            uint32_t col = (code == 1) ? WHITE :
                           (code == 2) ? CYAN  : flame_col;
            px(top_row + r, cx + dc, col);
        }
    }
    // flame below nozzles
    int flame_row = top_row + ROCKET_H;
    px(flame_row,     cx,     flame_col);
    px(flame_row,     cx - 1, ORANGE);
    px(flame_row,     cx + 1, ORANGE);
    px(flame_row + 1, cx,     RED);
}

// ============================================================
//  PHASE 1: countdown – glow builds from bottom, row by row
// ============================================================
static void phase_countdown(void) {
    for (int row = HEIGHT - 1; row >= 0; row--) {
        clear();
        // light all rows below current with full red glow
        for (int r = HEIGHT - 1; r > row; r--)
            for (int c = 0; c < WIDTH; c++) px(r, c, RED);
        // current row: dim orange pulse
        for (int c = 0; c < WIDTH; c++) px(row, c, ORANGE);
        send();
        delay_ms(1);
    }
    // full bright flash at ignition
    for (int i = 0; i < NUM_PIXELS; i++) frame[i] = YELLOW;
    send();
    delay_ms(1);
}

// ============================================================
//  PHASE 2: liftoff – rocket climbs from bottom to top
// ============================================================
static void phase_liftoff(void) {
    // rocket starts with nose at row 2 (bottom of matrix), climbs to row -4 (gone)
    uint32_t flame_colors[4];
    flame_colors[0] = YELLOW;
    flame_colors[1] = ORANGE;
    flame_colors[2] = RED;
    flame_colors[3] = ORANGE;
    int start_top = HEIGHT - ROCKET_H - 2; // start near bottom

    for (int top = start_top; top >= -ROCKET_H - 2; top--) {
        clear();

        // scrolling exhaust trail
        for (int trail = top + ROCKET_H; trail < HEIGHT; trail++) {
            if (trail < 0 || trail >= HEIGHT) continue;
            int intensity = trail - (top + ROCKET_H);
            uint32_t tc = (intensity == 0) ? YELLOW :
                          (intensity == 1) ? ORANGE :
                          (intensity == 2) ? RED    : BLACK;
            if (tc != BLACK) {
                px(trail, 3, tc);
                if (intensity < 2) { px(trail, 2, ORANGE); px(trail, 4, ORANGE); }
            }
        }

        draw_rocket(top, flame_colors[(rnd() & 3)]);
        send();
        delay_ms(1);
    }
}

// ============================================================
//  PHASE 3: orbit – starfield explosion
// ============================================================
static void phase_orbit(void) {
    // seed some stars
    uint32_t stars[NUM_PIXELS];
    for (int i = 0; i < NUM_PIXELS; i++) {
        uint32_t r = rnd();
        stars[i] = (r & 7) ? BLACK : ((r & 0x30) ? DIM_STAR : WHITE);
    }

    // expand explosion from center outward, then settle to starfield
    for (int step = 0; step < 12; step++) {
        clear();
        // base starfield
        for (int i = 0; i < NUM_PIXELS; i++) frame[i] = stars[i];

        // explosion ring
        int cx = 3, cy = 3;
        int r = step / 2;
        for (int dr = -r; dr <= r; dr++) {
            for (int dc = -r; dc <= r; dc++) {
                if ((dr * dr + dc * dc) >= r * r &&
                    (dr * dr + dc * dc) <  (r + 2) * (r + 2)) {
                    uint32_t ec = (step < 4)  ? YELLOW :
                                  (step < 7)  ? ORANGE :
                                  (step < 10) ? RED    : BLACK;
                    if (ec != BLACK) px(cy + dr, cx + dc, ec);
                }
            }
        }
        send();
        delay_ms(1);
    }

    // final: pure starfield twinkle loop
    for (int t = 0; t < 10; t++) {
        for (int i = 0; i < NUM_PIXELS; i++) frame[i] = stars[i];
        // random twinkle
        int idx = (int)(rnd() % NUM_PIXELS);
        frame[idx] = (frame[idx] != BLACK) ? WHITE : BLACK;
        send();
        delay_ms(1);
    }
}

// ============================================================
int main(void) {
    uart_init();
    neopixel_init();

    // store frames in HyperRAM while animating — exercises the HyperBus path
    // (each send reads from frame[] which was just written via normal SRAM,
    //  but you can swap to hyperram[] to stress-test external memory access)

    phase_countdown();
    phase_liftoff();
    phase_orbit();

    // all off
    clear();
    send();

    uart_write_flush();
    return 0;
}