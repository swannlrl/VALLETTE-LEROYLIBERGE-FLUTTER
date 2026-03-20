const https = require('https');
https.get('https://codelabs.formation-flutter.fr/assets/rappels.json', (res) => {
  let data = '';
  res.on('data', (c) => data += c);
  res.on('end', () => {
    const rappels = JSON.parse(data);
    const codes = rappels.map(r => String(r.gtin).split(',')[0].trim()).filter(Boolean).slice(0, 100);
    
    function checkCode(i) {
      if (i >= codes.length) return;
      const code = codes[i];
      https.get('https://world.openfoodfacts.org/api/v2/product/' + code + '.json', (off) => {
        let offD = '';
        off.on('data', c => offD += c);
        off.on('end', () => {
          try {
            const offJ = JSON.parse(offD);
            if (offJ.status === 1) { console.log('? FOUND WORKING RECALL CODE:', code); process.exit(0); }
          } catch(e) {}
          checkCode(i+1);
        });
      });
    }
    checkCode(0);
  });
});
