// ╔══════════════════════════════════════════════════════════════╗
// ║  Perf.qml — Performance Configuration Singleton            ║
// ║  CORE — DO NOT MODIFY (managed by dotfiles installer)      ║
// ║                                                            ║
// ║  Tuned for: Pixelbook Go (Core M3/i5, 8GB, UHD 615)       ║
// ║  All performance knobs live here. Plugins MUST respect     ║
// ║  these values to keep the shell lightweight.               ║
// ╚══════════════════════════════════════════════════════════════╝
pragma Singleton
import QtQuick

QtObject {
    // ── Timer Budget ──
    // Global clock tick rate in ms. Higher = less CPU.
    // 1000 = 1 update/sec (plenty for a clock)
    // 5000 = use for battery/network polling
    readonly property int tickFast: 1000
    readonly property int tickSlow: 5000
    readonly property int tickCrawl: 30000

    // ── Rendering ──
    // Cap animations to 30fps on low-power hardware.
    // Plugins should use this for NumberAnimation.duration math.
    readonly property int targetFps: 30
    readonly property int frameBudgetMs: Math.round(1000 / targetFps)

    // ── Feature Toggles (Retro = lightweight by design) ──
    // Blur is PERMANENTLY off — retro uses flat opaque colors.
    readonly property bool enableBlur: false
    // Shadows use zero-blur rectangular offsets (near-zero GPU cost).
    readonly property bool enableShadows: true
    readonly property bool enableAnimations: true
    readonly property bool enableLayerCache: true

    // ── Plugin Loading ──
    // Stagger plugin initialization to avoid CPU spike on login.
    // Each plugin Loader waits (index * staggerMs) before activating.
    readonly property int pluginStaggerMs: 80
    readonly property bool asyncPluginLoad: true
}
