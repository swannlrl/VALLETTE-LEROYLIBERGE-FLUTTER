module.exports = function() {
    try {
        var res = $http.send({
            url: "https://codelabs.formation-flutter.fr/assets/rappels.json",
            method: "GET",
        });

        if (res.statusCode !== 200) {
            console.error("HTTP " + res.statusCode);
            return;
        }

        var rappels = res.json;
        var collRappels = $app.findCollectionByNameOrId("rappels");

        for (var i = 0; i < rappels.length; i++) {
            var item = rappels[i];
            var rawGtin = String(item.gtin || "").replace(/\s/g, "");
            if (!rawGtin || rawGtin === "0") continue;

            // Normaliser en EAN-13 (13 chiffres avec zéros initiaux si besoin)
            var gtin = rawGtin.length < 13 ? rawGtin.padStart(13, "0") : rawGtin;

            // Chercher par le gtin normalisé, puis par l'ancien format (sans padding)
            var record = null;
            try {
                record = $app.findFirstRecordByData("rappels", "gtin", gtin);
            } catch (_) {}
            if (!record && gtin !== rawGtin) {
                // Fallback : l'entrée existante a peut-être été stockée sans padding
                try {
                    record = $app.findFirstRecordByData("rappels", "gtin", rawGtin);
                } catch (_) {}
            }

            if (!record) record = new Record(collRappels, {});

            record.set("gtin", gtin);
            record.set("reference_fiche", item.numero_fiche || "");
            record.set("titre", item.libelle || "");
            record.set("lot", item.identification_produits || "");
            record.set("image_url", item.liens_vers_les_images || "");
            record.set("motif", item.motif_rappel || "");
            record.set("risques", item.risques_encourus || "");
            record.set("conduite", item.conduites_a_tenir_par_le_consommateur || "");
            record.set("lien_pdf", item.lien_vers_affichette_pdf || "");
            record.set("date_debut", item.date_debut_commercialisation || "");
            record.set("date_fin", item.date_date_fin_commercialisation || "");
            record.set("distributeurs", item.distributeurs || "");
            record.set("zone_geographique", item.zone_geographique_de_vente || "");
            record.set("informations_complementaires", item.informations_complementaires || "");

            $app.save(record);
        }

        console.log("Synchronisation des rappels terminée (" + rappels.length + " entrées).");
    } catch (err) {
        console.error("Erreur sync rappels : " + err);
    }
};
