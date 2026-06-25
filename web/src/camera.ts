/** Live camera capture via getUserMedia. The stream feeds a <video> element for
 *  on-device pose processing; nothing is recorded or uploaded. */
export type Facing = "environment" | "user";

export class Camera {
  private stream: MediaStream | null = null;
  /** Preferred camera. "environment" = rear (default, side-profile framing),
   *  "user" = front. */
  facing: Facing = "environment";

  constructor(private video: HTMLVideoElement) {}

  get currentFacing(): Facing {
    return this.facing;
  }

  /** Start the camera using the current `facing`. Uses `ideal` (not exact) so a
   *  laptop without a rear camera still works, then falls back to any camera. */
  async start(): Promise<void> {
    try {
      this.stream = await navigator.mediaDevices.getUserMedia({
        video: { facingMode: { ideal: this.facing }, width: { ideal: 1280 }, height: { ideal: 720 } },
        audio: false,
      });
    } catch {
      // Last resort: any camera at all.
      this.stream = await navigator.mediaDevices.getUserMedia({ video: true, audio: false });
    }
    this.video.srcObject = this.stream;
    await this.video.play();
  }

  /** Switch front <-> rear and restart the stream. Returns the new facing.
   *  On a single-camera device the request just resolves to that same camera. */
  async flip(): Promise<Facing> {
    this.facing = this.facing === "environment" ? "user" : "environment";
    this.stop();
    await this.start();
    return this.facing;
  }

  stop(): void {
    this.stream?.getTracks().forEach((t) => t.stop());
    this.stream = null;
    this.video.srcObject = null;
  }
}

/** Keep the screen awake during a session (Safari iOS 16.4+, Chrome). */
export async function requestWakeLock(): Promise<WakeLockSentinel | null> {
  try {
    return (await navigator.wakeLock?.request("screen")) ?? null;
  } catch {
    return null;
  }
}
