import { FilesetResolver, PoseLandmarker, type NormalizedLandmark } from "@mediapipe/tasks-vision";
import { BodyJoints, Point2D } from "../core/geometry.js";

// MediaPipe Pose landmark indices we use.
const IDX = {
  nose: 0,
  leftEar: 7,
  rightEar: 8,
  leftShoulder: 11,
  rightShoulder: 12,
  leftHip: 23,
  rightHip: 24,
  leftKnee: 25,
  rightKnee: 26,
  leftAnkle: 27,
  rightAnkle: 28,
} as const;

/** Bridges MediaPipe Pose Landmarker to RakaatCore's BodyJoints. Runs fully
 *  on-device (WASM/GPU in the browser); the video frame is processed and
 *  discarded — never uploaded or stored. */
export class PoseEstimator {
  private landmarker: PoseLandmarker | null = null;
  minVisibility = 0.5;

  async init(): Promise<void> {
    const vision = await FilesetResolver.forVisionTasks(
      "https://cdn.jsdelivr.net/npm/@mediapipe/tasks-vision@0.10.14/wasm"
    );
    this.landmarker = await PoseLandmarker.createFromOptions(vision, {
      baseOptions: {
        modelAssetPath:
          "https://storage.googleapis.com/mediapipe-models/pose_landmarker/pose_landmarker_lite/float16/1/pose_landmarker_lite.task",
        delegate: "GPU",
      },
      runningMode: "VIDEO",
      numPoses: 1,
    });
  }

  /** Detect joints for one video frame. Returns null if no pose found.
   *  `timestampMs` must be monotonically increasing. Also returns raw landmarks
   *  for drawing the skeleton overlay. */
  detect(
    video: HTMLVideoElement,
    timestampMs: number
  ): { joints: BodyJoints; landmarks: NormalizedLandmark[] } | null {
    if (!this.landmarker) return null;
    const result = this.landmarker.detectForVideo(video, timestampMs);
    const pose = result.landmarks?.[0];
    if (!pose) return null;
    return { joints: this.map(pose), landmarks: pose };
  }

  /** Map MediaPipe landmarks (origin top-left, y DOWN) to BodyJoints
   *  (origin bottom-left, y UP) by flipping y. */
  private map(lm: NormalizedLandmark[]): BodyJoints {
    const pt = (i: number): Point2D | undefined => {
      const p = lm[i];
      if (!p) return undefined;
      if (p.visibility !== undefined && p.visibility < this.minVisibility) return undefined;
      return { x: p.x, y: 1 - p.y }; // flip to y-up
    };
    return {
      nose: pt(IDX.nose),
      leftEar: pt(IDX.leftEar),
      rightEar: pt(IDX.rightEar),
      leftShoulder: pt(IDX.leftShoulder),
      rightShoulder: pt(IDX.rightShoulder),
      leftHip: pt(IDX.leftHip),
      rightHip: pt(IDX.rightHip),
      leftKnee: pt(IDX.leftKnee),
      rightKnee: pt(IDX.rightKnee),
      leftAnkle: pt(IDX.leftAnkle),
      rightAnkle: pt(IDX.rightAnkle),
    };
  }
}
