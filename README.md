# Inco Smart Contract Deployment

Script untuk mengompilasi dan mendeploy kontrak Inco Solidity ke jaringan Inco.

## Prerequisites

1. Node.js v16+
2. Private key dengan saldo INCO
3. RPC URL untuk jaringan Inco

## Setup Awal

1. Install dependencies:
npm install

2. Konfigurasi .env file:
Salin .env.example ke .env dan edit:
cp .env .env.local
nano .env.local

Isi dengan konfigurasi Anda:
RPC_URL="https://testnet.inco.org"
CHAIN_ID=9090
PRIVATE_KEY="your_private_key_without_0x"
EXPLORER_URL="https://explorer.testnet.inco.org"

## Struktur File

*.sol                     # Kontrak Solidity
compile.js               # Script kompilasi
deploy.js               # Script deployment
deploy-all.js           # Script kompilasi + deployment
verify.js               # Script verifikasi
.env                    # Konfigurasi environment
package.json           # Dependencies
build/                 # Hasil kompilasi
deployments/           # Info deployment

## Penggunaan

### 1. Kompilasi Kontrak
node compile.js
Hasil kompilasi akan disimpan di folder build/.

### 2. Deploy Kontrak Spesifik
node deploy.js SimpleConfidentialToken

### 3. Deploy Semua Kontrak
node deploy.js all

### 4. Kompilasi dan Deploy Semua (One Command)
node deploy-all.js

### 5. Verifikasi Kontrak
node verify.js SimpleConfidentialToken
node verify.js all

## Output

Setelah deployment berhasil:
1. ABI & Bytecode disimpan di build/
2. Info deployment disimpan di deployments/
3. Ringkasan disimpan di deployments/summary.json

## Konfigurasi Gas

Edit di .env:
GAS_LIMIT="3000000"      # Gas limit
GAS_PRICE="1000000000"   # 1 Gwei

## Catatan Penting

1. Private Key: Simpan dengan aman, jangan commit ke repository
2. Gas Fees: Pastikan wallet memiliki cukup INCO untuk gas fees
3. Testnet: Disarankan test di testnet dulu sebelum mainnet
4. Inco Imports: Pastikan kontrak mengimport library Inco dengan benar

## Troubleshooting

### Error: "Missing RPC_URL or PRIVATE_KEY"
Periksa file .env sudah dikonfigurasi dengan benar.

### Error: "Insufficient funds"
Pastikan wallet memiliki cukup INCO untuk gas fees.

### Error: "Contract compilation failed"
Periksa:
- Versi Solidity sesuai dengan kontrak
- Import statement Inco library benar
- Tidak ada syntax error

## Support

Untuk masalah terkait:
1. Dokumentasi Inco: https://docs.inco.org
2. Discord Inco: https://discord.gg/inco
3. Explorer: https://explorer.testnet.inco.org
