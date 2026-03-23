/// <reference path="../pb_data/types.d.ts" />

// ═══════════════════════════════════════════════════════
// Synchronisation au démarrage
// ═══════════════════════════════════════════════════════
onBootstrap(function (e) {
    e.next();
    try {
        require(__hooks + "/sync.js")();
    } catch(err) {
        console.error("Erreur onBootstrap: " + err);
    }
});

// ═══════════════════════════════════════════════════════
// Synchronisation 2x par jour (6h et 18h)
// ═══════════════════════════════════════════════════════
cronAdd("sync_rappels_matin", "0 6 * * *", function() {
    require(__hooks + "/sync.js")();
});

cronAdd("sync_rappels_soir", "0 18 * * *", function() {
    require(__hooks + "/sync.js")();
});