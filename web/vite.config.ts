import { defineConfig } from "vite";
import { VitePWA } from "vite-plugin-pwa";
import basicSsl from "@vitejs/plugin-basic-ssl";

export default defineConfig({
  // host:true exposes on LAN; https so the camera works on your phone
  // (getUserMedia requires a secure context — http://<ip> is blocked).
  server: { host: true, https: {} },
  plugins: [
    basicSsl(),
    VitePWA({
      registerType: "autoUpdate",
      includeAssets: ["icon.svg"],
      manifest: {
        name: "Shalat Tracker",
        short_name: "Shalat",
        description: "Hitung rakaat shalat via kamera. On-device, tanpa rekam video.",
        theme_color: "#39745F",
        background_color: "#F5F2E8",
        display: "standalone",
        orientation: "portrait",
        icons: [
          { src: "icon.svg", sizes: "any", type: "image/svg+xml", purpose: "any maskable" },
        ],
      },
    }),
  ],
});
