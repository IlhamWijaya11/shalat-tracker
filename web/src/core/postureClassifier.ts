import { BodyJoints } from "./geometry.js";
import { PoseFeatures, poseFeaturesFrom } from "./poseFeatures.js";
import { Posture } from "./posture.js";

export interface ClassifierThresholds {
  /** Above this torso angle the spine counts as "tilted" (ruku/sujud). */
  tiltedAngle: number;
  /** In a tilted pose, head this low (×torso above ankle) ⇒ sujud. */
  sujudHeadAboveAnkle: number;
  /** Upright pose with hips this high above ankles ⇒ standing, else sitting. */
  standingHipAboveAnkle: number;
}

export const defaultThresholds: ClassifierThresholds = {
  tiltedAngle: 45,
  sujudHeadAboveAnkle: 0.6,
  standingHipAboveAnkle: 0.8,
};

/** Rule-based posture classifier (v1). Transparent, fast, no training data. */
export class PostureClassifier {
  constructor(public thresholds: ClassifierThresholds = { ...defaultThresholds }) {}

  classify(joints: BodyJoints): Posture;
  classify(features: PoseFeatures): Posture;
  classify(input: BodyJoints | PoseFeatures): Posture {
    const f = "torsoAngle" in input ? input : poseFeaturesFrom(input);
    if (!f) return Posture.Unknown;
    const t = this.thresholds;
    if (f.torsoAngle > t.tiltedAngle) {
      // Spine horizontal: ruku vs sujud by head height off the floor.
      return f.headAboveAnkle < t.sujudHeadAboveAnkle ? Posture.Sujud : Posture.Ruku;
    }
    // Spine upright: standing vs sitting by hip height off the floor.
    return f.hipAboveAnkle > t.standingHipAboveAnkle ? Posture.Standing : Posture.Jalsa;
  }
}
