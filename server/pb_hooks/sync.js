/// <reference path="../pb_data/types.d.ts" />

/**
 * Récupère les rappels produits depuis l'API RappelConso
 * et les enregistre/met à jour dans la collection "rappels".
 */
module.exports = function () {
    var res = $http.send({
        url: "https://codelabs.formation-flutter.fr/assets/rappels.json",
        method: "GET",
    });

    if (res.statusCode !== 200) {
        throw new Error("HTTP " + res.statusCode);
    }

    var rappels = res.json;
    var collection = $app.findCollectionByNameOrId("rappels");
    var count = 0;

    for (var i = 0; i < rappels.length; i++) {
        var item = rappels[i];
        var rawGtin = String(item.gtin || "").replace(/\s/g, "");
        if (!rawGtin || rawGtin === "0") continue;

        // Normaliser en EAN-13 (13 chiffres)
        var gtin = rawGtin.length < 13 ? rawGtin.padStart(13, "0") : rawGtin;

        // Chercher un enregistrement existant
        var record = null;
        try {
            record = $app.findFirstRecordByData("rappels", "gtin", gtin);
        } catch (_) {}

        if (!record) {
            record = new Record(collection, {});
        }

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
        count++;
    }

    console.log("Synchronisation terminée (" + count + " rappels traités).");
};
