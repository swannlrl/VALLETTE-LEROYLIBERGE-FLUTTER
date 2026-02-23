// --- CONFIGURATION ET MONITORING ---
const CONFIG = {
    source: "https://codelabs.formation-flutter.fr/assets/rappels.json",
    planning: "2 fois par jour (00h00 et 12h00)", // Consigne X2
    version: "1.0.0"
};

// Cet affichage se fera DIRECTEMENT dans ton terminal au lancement
console.log("=================================================");
console.log("🔍 MONITORING SYNC RAPPEL-PRODUIT");
console.log("=================================================");
console.log("📡 SOURCE DES DONNÉES : " + CONFIG.source);
console.log("⏰ PLANNING DE MAJ    : " + CONFIG.planning);
console.log("🚀 ÉTAT DU SYSTÈME    : PRÊT");
console.log("=================================================");

// --- TÂCHE AUTOMATIQUE (CRON) ---
// Cette fonction respecte ta consigne de mise à jour 2 fois par jour
cronAdd("sync_rappels", "0 0,12 * * *", () => {
    const maintenant = new Date().toLocaleString('fr-FR');
    console.log("🔄 [" + maintenant + "] Synchro automatique en cours...");

    try {
        const response = $http.send({ url: CONFIG.source, method: "GET" });
        const data = response.json;

        $app.dao().runInTransaction((dao) => {
            data.forEach((item) => {
                const gtin = item['gtin']?.toString();
                if (!gtin || gtin === '0') return;

                const collection = dao.findCollectionByNameOrId("produits");
                const record = new Record(collection);
                record.set("gtin", gtin);
                record.set("lot", item['identification_produits'] || '');
                dao.saveRecord(record);
            });
        });
        console.log("✅ [" + maintenant + "] Mise à jour réussie.");
    } catch (err) {
        console.log("❌ [" + maintenant + "] Erreur : " + err);
    }
});