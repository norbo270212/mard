<!DOCTYPE html>
<html lang="hu">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kávégép Vezérlő Központ</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; text-align: center; background: #121212; color: #e0e0e0; padding: 20px; }
        .card { background: #1e1e1e; padding: 25px; border-radius: 20px; display: inline-block; box-shadow: 0 10px 30px rgba(0,0,0,0.5); border: 1px solid #333; max-width: 350px; width: 100%; }
        h2 { color: #f39c12; margin-bottom: 5px; }
        .status { font-size: 14px; margin-bottom: 20px; color: #888; }
        button { cursor: pointer; border: none; border-radius: 12px; font-weight: bold; transition: 0.3s; }
        .btn-connect { background: #27ae60; color: white; padding: 15px 30px; width: 100%; font-size: 18px; margin-bottom: 20px; }
        .btn-connect:active { background: #1e8449; }
        .btn-brew { background: #e67e22; color: white; width: 80px; height: 60px; font-size: 20px; margin: 5px; }
        .btn-brew:active { background: #d35400; }
        .btn-refresh { background: #3498db; color: white; padding: 10px 20px; margin-top: 20px; width: 100%; }
        .admin-section { margin-top: 30px; padding-top: 20px; border-top: 1px dashed #444; }
        input { background: #2c3e50; border: 1px solid #444; color: white; padding: 8px; border-radius: 5px; width: 60px; margin: 5px; text-align: center; }
    </style>
</head>
<body>

<div class="card">
    <h2>☕ KAVEGEP_BLE</h2>
    <div id="status" class="status">Állapot: Nincs kapcsolódva</div>
    
    <button class="btn-connect" onclick="connect()">CSATLAKOZÁS</button>

    <div id="controls" style="display:none;">
        <p>Ital választása:</p>
        <button class="btn-brew" onclick="send('b1')">1</button>
        <button class="btn-brew" onclick="send('b2')">2</button>
        <button class="btn-brew" onclick="send('b3')">3</button>
        <br>
        <button class="btn-brew" onclick="send('b4')">4</button>
        <button class="btn-brew" onclick="send('b5')">5</button>
        <button class="btn-brew" onclick="send('b6')">6</button>
        <br>
        <button class="btn-brew" style="width:175px;" onclick="send('b7')">7 (ADMIN)</button>
        
        <div class="admin-section">
            <p>Kredit módosítás (Slot:Érték):</p>
            <input type="number" id="slot" placeholder="Slot" min="1" max="50">
            <input type="number" id="val" placeholder="HUF">
            <button onclick="updateCredit()" style="background:#8e44ad; color:white; padding:8px 15px; border-radius:5px;">BEÁLLÍT</button>
        </div>

        <button class="btn-refresh" onclick="send('refresh')">ADATOK FRISSÍTÉSE</button>
    </div>
</div>

<script>
    let char;
    const S_UUID = "12345678-1234-1234-1234-1234567890ab";
    const C_UUID = "12345678-1234-1234-1234-1234567890ac";

    async function connect() {
        const st = document.getElementById('status');
        try {
            st.innerText = "Keresés...";
            const device = await navigator.bluetooth.requestDevice({
                filters: [{ name: 'KAVEGEP_BLE' }],
                optionalServices: [S_UUID]
            });
            const server = await device.gatt.connect();
            const service = await server.getPrimaryService(S_UUID);
            char = await service.getCharacteristic(C_UUID);
            
            st.innerText = "✅ CSATLAKOZVA";
            st.style.color = "#2ecc71";
            document.getElementById('controls').style.display = 'block';
        } catch (e) { 
            st.innerText = "Hiba: " + e;
        }
    }

    async function send(cmd) {
        if(!char) return;
        try {
            await char.writeValue(new TextEncoder().encode(cmd));
            console.log("Küldve: " + cmd);
        } catch (e) { alert("Hiba: " + e); }
    }

    function updateCredit() {
        const slot = document.getElementById('slot').value;
        const val = document.getElementById('val').value;
        if(slot && val) {
            send(`k${slot}:${val}`);
        } else {
            alert("Töltsd ki mindkét mezőt!");
        }
    }
</script>

</body>
</html>
