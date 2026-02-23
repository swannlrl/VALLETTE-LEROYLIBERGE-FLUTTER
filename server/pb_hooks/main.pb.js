// Variable de configuration pour la traçabilité
const CONFIG = {
    source: "https://codelabs.formation-flutter.fr/assets/rappels.json",
    frequence: "2 fois par jour (00h00 & 12h00)",
    derniere_init: new Date().toLocaleString('fr-FR')
};

onAppAfterBootstrap((e) => {
    // Récupération des statistiques réelles de ta base
    const totalProduits = $app.dao().findRecordsByFilter("produits", "id != ''").length;
    const totalCampagnes = $app.dao().findRecordsByFilter("campagnes", "id != ''").length;

    console.log("=================================================");
    console.log("🔍 MONITORING SYNC RAPPEL-PRODUIT");
    console.log("=================================================");
    console.log(`📡 SOURCE DES DONNÉES : ${CONFIG.source}`);
    console.log(`⏰ PLANNING DE MAJ  : ${CONFIG.frequence}`);
    console.log(`🚀 SERVEUR LANCÉ LE : ${CONFIG.derniere_init}`);
    console.log("-------------------------------------------------");
    console.log(`📦 ÉTAT DE LA BASE   :`);
    console.log(`   - Produits enregistrés : ${totalProduits}`);
    console.log(`   - Campagnes liées     : ${totalCampagnes}`);
    console.log("=================================================");
    console.log("✅ SYSTÈME PRÊT ET OPÉRATIONNEL");
    console.log("=================================================");
});

// Ta tâche Cron reste inchangée pour assurer la mise à jour X2
cronAdd("sync_rappels", "0 0,12 * * *", () => {
    console.log("🔄 " + new Date().toLocaleString() + " : Synchro automatique en cours...");
    // ... ton code de synchronisation ...
});