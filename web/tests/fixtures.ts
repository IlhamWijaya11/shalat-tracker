import { BodyJoints, Point2D } from "../src/core/geometry.js";

// Synthetic joints (normalized, y up) for each posture, so the whole pipeline
// runs without a camera.
function pair(x: number, y: number, spread = 0.05): [Point2D, Point2D] {
  return [
    { x: x - spread, y },
    { x: x + spread, y },
  ];
}

function joints(opts: {
  head: Point2D;
  shoulder: number;
  shoulderY: number;
  hip: number;
  hipY: number;
  ankleY: number;
}): BodyJoints {
  const [ls, rs] = pair(opts.shoulder, opts.shoulderY);
  const [lh, rh] = pair(opts.hip, opts.hipY);
  const [la, ra] = pair(0.5, opts.ankleY);
  return {
    nose: opts.head,
    leftShoulder: ls,
    rightShoulder: rs,
    leftHip: lh,
    rightHip: rh,
    leftAnkle: la,
    rightAnkle: ra,
  };
}

export const Fixtures = {
  standing: joints({ head: { x: 0.5, y: 0.9 }, shoulder: 0.5, shoulderY: 0.75, hip: 0.5, hipY: 0.5, ankleY: 0.1 }),
  // Bowing: torso tipped toward horizontal, head still high off the floor.
  ruku: joints({ head: { x: 0.85, y: 0.5 }, shoulder: 0.7, shoulderY: 0.55, hip: 0.5, hipY: 0.5, ankleY: 0.1 }),
  // Prostration: everything low, head near the floor.
  sujud: joints({ head: { x: 0.72, y: 0.12 }, shoulder: 0.6, shoulderY: 0.2, hip: 0.45, hipY: 0.3, ankleY: 0.1 }),
  // Sitting: torso upright, hips low near ankles.
  jalsa: joints({ head: { x: 0.5, y: 0.6 }, shoulder: 0.5, shoulderY: 0.45, hip: 0.5, hipY: 0.2, ankleY: 0.1 }),
};
