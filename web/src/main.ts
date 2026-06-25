import { Camera, requestWakeLock } from "./camera.js";
import { postureLabel } from "./core/posture.js";
import { prayerDisplayName } from "./core/prayerType.js";
import { RakaatSession, sessionIsValid } from "./core/rakaatSession.js";
import { RakaatTracker } from "./core/rakaatTracker.js";
import { PoseEstimator } from "./pose/poseEstimator.js";
import { SessionStore } from "./storage.js";

const $ = <T extends HTMLElement = HTMLElement>(id: string) => document.getElementById(id) as T;

type Screen = "onboarding" | "setup" | "live" | "result" | "history" | "stats" | "settings";
const TAB_SCREENS = new Set<Screen>(["setup", "history", "stats", "settings"]);

function show(screen: Screen): void {
  for (const s of ["onboarding", "setup", "live", "result", "history", "stats", "settings"] as Screen[]) {
    $(`screen-${s}`).classList.toggle("hidden", s !== screen);
  }
  // Tab bar visible only on tab screens.
  $("tabbar").classList.toggle("hidden", !TAB_SCREENS.has(screen));
  document.querySelectorAll(".tab").forEach((t) =>
    t.classList.toggle("active", (t as HTMLElement).dataset.tab === screen)
  );
}

// ---- Live session ----
const video = $("video") as HTMLVideoElement;
const canvas = $("overlay") as HTMLCanvasElement;
const camera = new Camera(video);
const estimator = new PoseEstimator();
let tracker = new RakaatTracker();
let rafId = 0;
let modelReady = false;
let wakeLock: WakeLockSentinel | null = null;

async function ensureModel(): Promise<void> {
  if (modelReady) return;
  $("cam-status").textContent = "Memuat model…";
  await estimator.init();
  modelReady = true;
}

async function startSession(): Promise<void> {
  show("live");
  tracker = new RakaatTracker();
  $("rakaat-count").textContent = "0";
  $("posture-label").textContent = "—";
  try {
    await ensureModel();
    await camera.start();
    wakeLock = await requestWakeLock();
    $("cam-status").textContent = "Deteksi aktif";
    loop();
  } catch (e) {
    $("cam-status").textContent = "Gagal akses kamera";
    console.error(e);
  }
}

function loop(): void {
  const tMs = performance.now();
  if (video.readyState >= 2) {
    const result = estimator.detect(video, tMs);
    const w = (canvas.width = canvas.clientWidth);
    const h = (canvas.height = canvas.clientHeight);
    const ctx = canvas.getContext("2d")!;
    if (result) {
      tracker.process(result.joints, tMs / 1000);
      ctx.clearRect(0, 0, w, h); // no skeleton overlay — detection runs silently
      $("posture-label").textContent = postureLabel(tracker.livePosture);
      $("rakaat-count").textContent = String(tracker.rakaatCount);
      if (tracker.isComplete) {
        finishSession();
        return;
      }
    } else {
      ctx.clearRect(0, 0, w, h);
      $("posture-label").textContent = "Cari badan…";
    }
  }
  rafId = requestAnimationFrame(loop);
}

function finishSession(): void {
  cancelAnimationFrame(rafId);
  tracker.stop(performance.now() / 1000);
  camera.stop();
  wakeLock?.release().catch(() => {});
  wakeLock = null;
  const session = tracker.makeSession();
  SessionStore.add(session);
  showResult(session);
}

function showResult(s: RakaatSession): void {
  const valid = sessionIsValid(s);
  $("result-icon").textContent = valid ? "✓" : "⚠️";
  $("result-prayer").textContent = prayerDisplayName(s.prayer);
  $("result-rakaat").textContent = `${s.rakaat} Rakaat`;
  const box = $("result-violations");
  box.innerHTML = valid
    ? `<div class="ok">✓ Gerakan tertib</div>`
    : s.violations.map((v) => `<div class="viol">⚠ ${v}</div>`).join("");
  show("result");
}

// ---- History & stats rendering ----
function renderHistory(): void {
  const list = SessionStore.all();
  const el = $("history-list");
  if (list.length === 0) {
    el.innerHTML = `<div class="empty">Belum ada riwayat.<br>Sesi shalat akan muncul di sini.</div>`;
    return;
  }
  const fmt = new Intl.DateTimeFormat("id-ID", { day: "numeric", month: "short", hour: "2-digit", minute: "2-digit" });
  el.innerHTML = list
    .map((s) => {
      const valid = sessionIsValid(s);
      return `<div class="row">
        <div><div class="name">${prayerDisplayName(s.prayer)}</div>
        <div class="meta">${fmt.format(s.timestamp)}</div></div>
        <div><b>${s.rakaat}</b><span class="tag ${valid ? "ok" : "warn"}">${valid ? "✓" : "⚠"}</span></div>
      </div>`;
    })
    .join("");
}

function renderStats(): void {
  const weekAgo = Date.now() - 7 * 24 * 3600 * 1000;
  const week = SessionStore.all().filter((s) => s.timestamp >= weekAgo);
  const tidy = week.length ? Math.round((week.filter(sessionIsValid).length / week.length) * 100) : 0;
  const days = new Set(week.map((s) => new Date(s.timestamp).toDateString())).size;
  $("stats-cards").innerHTML = `
    <div class="stat-box"><div class="stat-num">${week.length}</div><div class="stat-lbl">Shalat</div></div>
    <div class="stat-box"><div class="stat-num">${tidy}%</div><div class="stat-lbl">Tertib</div></div>
    <div class="stat-box"><div class="stat-num">${days}</div><div class="stat-lbl">Hari aktif</div></div>`;
}

// ---- Navigation wiring ----
function goTab(tab: Screen): void {
  if (tab === "history") renderHistory();
  if (tab === "stats") renderStats();
  show(tab);
}

$("btn-allow-cam").addEventListener("click", async () => {
  // Trigger the permission prompt early; ignore result (asked again on start).
  try {
    const s = await navigator.mediaDevices.getUserMedia({ video: true });
    s.getTracks().forEach((t) => t.stop());
  } catch { /* user can still proceed */ }
});
$("btn-onboard-done").addEventListener("click", () => {
  localStorage.setItem("onboarded", "1");
  goTab("setup");
});
$("btn-start").addEventListener("click", startSession);
$("btn-stop").addEventListener("click", finishSession);
$("btn-flip").addEventListener("click", async () => {
  try {
    const facing = await camera.flip();
    $("cam-status").textContent = facing === "user" ? "Kamera depan" : "Kamera belakang";
  } catch {
    $("cam-status").textContent = "Cuma 1 kamera";
  }
});
$("btn-result-done").addEventListener("click", () => goTab("setup"));
$("btn-clear").addEventListener("click", () => {
  SessionStore.clear();
  renderHistory();
});
document.querySelectorAll(".tab").forEach((t) =>
  t.addEventListener("click", () => goTab((t as HTMLElement).dataset.tab as Screen))
);

// ---- Boot ----
show(localStorage.getItem("onboarded") ? "setup" : "onboarding");
if (localStorage.getItem("onboarded")) $("tabbar").classList.remove("hidden");
