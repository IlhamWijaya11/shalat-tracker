import type { NormalizedLandmark } from "@mediapipe/tasks-vision";

// Connections between landmark indices to render a simple skeleton.
const CONNECTIONS: Array<[number, number]> = [
  [11, 12], // shoulders
  [11, 23], [12, 24], // torso sides
  [23, 24], // hips
  [11, 13], [13, 15], // left arm
  [12, 14], [14, 16], // right arm
  [23, 25], [25, 27], // left leg
  [24, 26], [26, 28], // right leg
  [0, 11], [0, 12], // neck-ish
];

/** Draw the skeleton on the overlay canvas. Landmarks are MediaPipe normalized
 *  (origin top-left, y down), which matches canvas coordinates directly. */
export function drawSkeleton(
  ctx: CanvasRenderingContext2D,
  landmarks: NormalizedLandmark[],
  width: number,
  height: number
): void {
  ctx.clearRect(0, 0, width, height);
  ctx.strokeStyle = "rgba(140, 176, 158, 0.9)";
  ctx.fillStyle = "rgba(140, 176, 158, 0.95)";
  ctx.lineWidth = 4;

  for (const [a, b] of CONNECTIONS) {
    const pa = landmarks[a];
    const pb = landmarks[b];
    if (!pa || !pb) continue;
    ctx.beginPath();
    ctx.moveTo(pa.x * width, pa.y * height);
    ctx.lineTo(pb.x * width, pb.y * height);
    ctx.stroke();
  }
  for (const p of landmarks) {
    ctx.beginPath();
    ctx.arc(p.x * width, p.y * height, 4, 0, Math.PI * 2);
    ctx.fill();
  }
}
