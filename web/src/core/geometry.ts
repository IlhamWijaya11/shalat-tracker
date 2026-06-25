// 2D geometry + body joints. Convention: normalized coords, origin bottom-left,
// x right, y **up** (0..1) — same as the original Swift RakaatCore. The pose
// estimator converts MediaPipe's y-down coords to this convention.

export interface Point2D {
  x: number;
  y: number;
}

export function sub(a: Point2D, b: Point2D): Point2D {
  return { x: a.x - b.x, y: a.y - b.y };
}

export function length(p: Point2D): number {
  return Math.hypot(p.x, p.y);
}

export function midpoint(a: Point2D, b: Point2D): Point2D {
  return { x: (a.x + b.x) / 2, y: (a.y + b.y) / 2 };
}

/** Joints for one frame. All optional — the detector can drop joints (occlusion,
 *  out of frame — common during sujud). */
export interface BodyJoints {
  nose?: Point2D;
  leftEar?: Point2D;
  rightEar?: Point2D;
  leftShoulder?: Point2D;
  rightShoulder?: Point2D;
  leftHip?: Point2D;
  rightHip?: Point2D;
  leftKnee?: Point2D;
  rightKnee?: Point2D;
  leftAnkle?: Point2D;
  rightAnkle?: Point2D;
}

function mid(a?: Point2D, b?: Point2D): Point2D | undefined {
  if (!a || !b) return undefined;
  return midpoint(a, b);
}

export function shoulderMid(j: BodyJoints): Point2D | undefined {
  return mid(j.leftShoulder, j.rightShoulder);
}
export function hipMid(j: BodyJoints): Point2D | undefined {
  return mid(j.leftHip, j.rightHip);
}
export function ankleMid(j: BodyJoints): Point2D | undefined {
  return mid(j.leftAnkle, j.rightAnkle);
}
/** Head reference: nose, else midpoint of ears. */
export function head(j: BodyJoints): Point2D | undefined {
  return j.nose ?? mid(j.leftEar, j.rightEar);
}
