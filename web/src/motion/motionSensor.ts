/** Motion (IMU) input for the "gerakan" mode: the phone rides in a pocket and we
 *  read body tilt from the accelerometer to tell standing from sujud/sitting.
 *
 *  We track the tilt of the device's long axis away from vertical:
 *   - upright (standing, phone vertical in pocket) → ~0°
 *   - prostrating / sitting (thigh horizontal) → ~90°
 *  A sujud is a "down" episode. Hysteresis (enter > exit) stops flapping near the
 *  threshold. Emits only on down-state *changes* — the `SujudRakaatCounter` does
 *  the timing/debounce and counts rakaat. No camera, nothing recorded. */

type DownListener = (down: boolean, tSeconds: number) => void;

export interface MotionOptions {
  /** Enter "down" when tilt from vertical exceeds this (degrees). */
  enterAngle?: number;
  /** Leave "down" when tilt drops below this (degrees). Must be < enterAngle. */
  exitAngle?: number;
}

export class MotionSensor {
  private readonly enter: number;
  private readonly exit: number;
  private down = false;
  private listener: DownListener | null = null;
  private handler = (e: DeviceMotionEvent) => this.onMotion(e);

  constructor(opts: MotionOptions = {}) {
    this.enter = opts.enterAngle ?? 55;
    this.exit = opts.exitAngle ?? 40;
  }

  /** True if the API exists at all (most mobiles; not most desktops). */
  static get isSupported(): boolean {
    return typeof DeviceMotionEvent !== "undefined";
  }

  /** iOS 13+ requires a permission prompt fired from a user gesture. Returns true
   *  if motion is usable. On Android/desktop there's no prompt — resolves true. */
  static async requestPermission(): Promise<boolean> {
    const anyEvt = DeviceMotionEvent as unknown as {
      requestPermission?: () => Promise<"granted" | "denied">;
    };
    if (typeof anyEvt?.requestPermission === "function") {
      try {
        return (await anyEvt.requestPermission()) === "granted";
      } catch {
        return false;
      }
    }
    return MotionSensor.isSupported;
  }

  start(onDownChange: DownListener): void {
    this.listener = onDownChange;
    this.down = false;
    window.addEventListener("devicemotion", this.handler);
  }

  stop(): void {
    window.removeEventListener("devicemotion", this.handler);
    this.listener = null;
  }

  private onMotion(e: DeviceMotionEvent): void {
    const g = e.accelerationIncludingGravity;
    if (!g || g.x == null || g.y == null || g.z == null) return;
    const m = Math.hypot(g.x, g.y, g.z);
    if (m < 1e-3) return;
    // Angle of gravity away from the device's vertical (y) axis: 0° when the phone
    // is upright, 90° when it's horizontal.
    const tilt = (Math.acos(Math.min(1, Math.abs(g.y) / m)) * 180) / Math.PI;
    const t = e.timeStamp / 1000;
    if (!this.down && tilt > this.enter) {
      this.down = true;
      this.listener?.(true, t);
    } else if (this.down && tilt < this.exit) {
      this.down = false;
      this.listener?.(false, t);
    }
  }
}
