#!/usr/bin/env python3
"""
neopixel_vcd.py  –  Decode WS2812 signal from a VCD and render each frame
                     as a coloured 8x8 block in the terminal.

Usage:
    python3 neopixel_vcd.py hyperbus_croc.vcd
    python3 neopixel_vcd.py hyperbus_croc.vcd --fps 10
    python3 neopixel_vcd.py hyperbus_croc.vcd --dump   # just print raw pixels

WS2812 timing (at 100 MHz sim clock → 1 tick = 1 ns):
    T0H  ~400 ns  (0.3–0.5 µs)   high for 0-bit
    T1H  ~800 ns  (0.6–0.9 µs)   high for 1-bit
    RESET > 50 µs low → end of frame
"""

import sys
import time
import argparse
import os

# ── ANSI helpers ──────────────────────────────────────────────────────────────
def ansi_bg(r, g, b):
    return f"\x1b[48;2;{r};{g};{b}m"

RESET_ANSI = "\x1b[0m"
CLEAR       = "\x1b[2J\x1b[H"

# ── WS2812 thresholds (in ns) ─────────────────────────────────────────────────
# Design uses: T1H=16 cycles=160ns, T0H=8 cycles=80ns @ 100MHz
T1H_MIN   =     120  # high pulse > this -> bit-1
T0H_MAX   =     120  # high pulse <= this -> bit-0
RESET_MIN = 200_000  # low > this -> reset / end-of-frame (LATCH=1100cyc=11000ns; use big margin
                      # in case the controller has long FIFO-empty stalls mid-burst)

NUM_LEDS  = 64     # 8×8 matrix
COLS      = 8

# ── VCD streaming parser ──────────────────────────────────────────────────────
def parse_vcd(path, neo_id="/"):
    """
    Yield (timestamp_ns, value) pairs for the signal whose VCD id == neo_id.
    Streams the file without loading it all into RAM.
    """
    in_defs  = True
    cur_time = 0

    with open(path, "r", errors="replace") as f:
        for raw in f:
            line = raw.strip()
            if not line:
                continue

            # Once we hit $dumpvars / $end of header we're in value-change land
            if in_defs:
                if line.startswith("$dumpvars") or line.startswith("$end"):
                    in_defs = False
                continue

            if line.startswith("#"):
                cur_time = int(line[1:])
                continue

            # 1-bit value change:  "0/" or "1/"
            if len(line) >= 2 and line[0] in "01xXzZ":
                sig_id = line[1:]
                if sig_id == neo_id:
                    val = 1 if line[0] == "1" else 0
                    yield cur_time, val


# ── WS2812 bit/frame decoder ──────────────────────────────────────────────────
def decode_frames(events):
    """
    events : iterable of (time_ns, value)
    Yields lists of (r,g,b) tuples, one list per complete frame (64 LEDs).
    """
    bits      = []
    leds      = []
    last_rise = None
    last_fall = None
    last_time = None
    last_val  = None

    for t, v in events:
        if last_val is None:
            last_val  = v
            last_time = t
            if v == 1:
                last_rise = t
            continue

        dt = t - last_time

        if last_val == 0 and v == 1:
            # rising edge
            if last_fall is not None:
                low_time = t - last_fall
                if low_time > RESET_MIN:
                    # RESET: finish current frame
                    if leds or bits:
                        if len(leds) < NUM_LEDS:
                            print(f"  [debug] reset at t={t}ns after {low_time}ns low; "
                                  f"only {len(leds)}/{NUM_LEDS} LEDs, {len(bits)} stray bits",
                                  file=sys.stderr)
                        if leds:
                            yield leds
                        leds = []
                        bits = []
            last_rise = t

        elif last_val == 1 and v == 0:
            # falling edge – measure high pulse
            last_fall = t
            if last_rise is not None:
                high_time = t - last_rise
                bit = 1 if high_time > T1H_MIN else 0
                bits.append(bit)

                if len(bits) == 24:
                    # Controller sends RGB (not standard WS2812 GRB)
                    rgb = 0
                    for bit in bits:
                        rgb = (rgb << 1) | bit
                    r = (rgb >> 16) & 0xFF
                    g = (rgb >>  8) & 0xFF
                    b_ch = rgb & 0xFF
                    leds.append((r, g, b_ch))
                    bits = []

                    if len(leds) == NUM_LEDS:
                        yield leds
                        leds = []

        last_val  = v
        last_time = t


# ── Terminal renderer ─────────────────────────────────────────────────────────
def render_frame(leds, frame_no):
    lines = [f"Frame {frame_no:4d}   (each block = 1 LED)"]
    lines.append("┌" + "──" * COLS + "┐")
    for row in range(NUM_LEDS // COLS):
        row_str = "│"
        for col in range(COLS):
            r, g, b = leds[row * COLS + col]
            row_str += ansi_bg(r, g, b) + "  " + RESET_ANSI
        row_str += "│"
        lines.append(row_str)
    lines.append("└" + "──" * COLS + "┘")
    return "\n".join(lines)


def dump_frame(leds, frame_no):
    print(f"=== Frame {frame_no} ===")
    for i, (r, g, b) in enumerate(leds):
        print(f"  LED {i:2d}  R={r:3d} G={g:3d} B={b:3d}  #{r:02x}{g:02x}{b:02x}")


# ── Main ──────────────────────────────────────────────────────────────────────
def main():
    ap = argparse.ArgumentParser(description="Decode WS2812 from VCD and show 8x8 matrix")
    ap.add_argument("vcd",           help="path to .vcd file")
    ap.add_argument("--id",          default="/", help="VCD signal id for neopixel_data_o (default: /)")
    ap.add_argument("--fps",  type=float, default=5,  help="playback speed in frames/sec (default: 5)")
    ap.add_argument("--dump", action="store_true",    help="dump raw RGB values instead of rendering")
    ap.add_argument("--skip", type=int,   default=0,  help="skip first N frames")
    args = ap.parse_args()

    if not os.path.isfile(args.vcd):
        print(f"Error: file not found: {args.vcd}", file=sys.stderr)
        sys.exit(1)

    delay = 1.0 / args.fps

    print(f"Parsing {args.vcd}  (signal id '{args.id}') …")
    print("Press Ctrl-C to stop.\n")

    events = parse_vcd(args.vcd, neo_id=args.id)
    frames = decode_frames(events)

    frame_no = 0
    try:
        for leds in frames:
            frame_no += 1
            if frame_no <= args.skip:
                continue

            if args.dump:
                dump_frame(leds, frame_no)
            else:
                print(CLEAR, end="")
                print(render_frame(leds, frame_no))
                time.sleep(delay)

    except KeyboardInterrupt:
        pass

    print(f"\nTotal frames decoded: {frame_no}")


if __name__ == "__main__":
    main()