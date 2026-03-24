/// <reference path="../pb_data/types.d.ts" />

// Migration : ajout de rappels produits de test non présents dans le JSON gouvernemental
migrate((app) => {
    var collRappels = app.findCollectionByNameOrId("rappels");

    var testRappels = [
        {
            gtin: "3256228120441",
            titre: "rillettes de saumon à l'aneth",
            reference_fiche: "TEST-SAUMON-001",
            motif: "Présence de Listeria monocytogenes",
            risques: "Risque infectieux (listériose)",
            conduite: "ne plus consommer|rapporter en magasin|contacter votre médecin si symptômes",
            lien_pdf: "",
            image_url: "",
            date_debut: "2026-01-10",
            date_fin: "2026-02-28",
            distributeurs: "Grandes et moyennes surfaces",
            zone_geographique: "France entière",
            informations_complementaires: "Produit de test pour démonstration",
        },
        {
            gtin: "3256228120458",
            titre: "rillettes de saumon fumé",
            reference_fiche: "TEST-SAUMON-002",
            motif: "Présence de Listeria monocytogenes",
            risques: "Risque infectieux (listériose)",
            conduite: "ne plus consommer|rapporter en magasin",
            lien_pdf: "",
            image_url: "",
            date_debut: "2026-01-10",
            date_fin: "2026-02-28",
            distributeurs: "Supermarchés",
            zone_geographique: "France entière",
            informations_complementaires: "Produit de test pour démonstration",
        },
    ];

    for (var i = 0; i < testRappels.length; i++) {
        var item = testRappels[i];
        var record = null;
        try {
            record = app.findFirstRecordByData("rappels", "gtin", item.gtin);
        } catch (_) {}

        if (!record) {
            record = new Record(collRappels, {});
        }

        record.set("gtin", item.gtin);
        record.set("reference_fiche", item.reference_fiche);
        record.set("titre", item.titre);
        record.set("lot", "");
        record.set("image_url", item.image_url);
        record.set("motif", item.motif);
        record.set("risques", item.risques);
        record.set("conduite", item.conduite);
        record.set("lien_pdf", item.lien_pdf);
        record.set("date_debut", item.date_debut);
        record.set("date_fin", item.date_fin);
        record.set("distributeurs", item.distributeurs);
        record.set("zone_geographique", item.zone_geographique);
        record.set("informations_complementaires", item.informations_complementaires);

        app.save(record);
    }

    console.log("Migration 0002 : rappels de test insérés.");

}, (app) => {
    // Rollback : supprimer les rappels de test
    var gtins = ["3256228120441", "3256228120458"];
    for (var i = 0; i < gtins.length; i++) {
        try {
            var record = app.findFirstRecordByData("rappels", "gtin", gtins[i]);
            app.delete(record);
        } catch (_) {}
    }
});
