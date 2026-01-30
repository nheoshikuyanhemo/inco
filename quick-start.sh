#!/bin/bash

echo "🚀 Inco Deployment Quick Start"
echo "=============================="

# Check if .env exists
if [ ! -f .env ]; then
    echo "❌ .env file not found!"
    echo "Creating .env.example..."
    cp .env .env.example 2>/dev/null || echo "RPC_URL=\"https://testnet.inco.org\"" > .env.example
    echo "Please edit .env file with your configuration"
    exit 1
fi

# Install dependencies
echo "📦 Installing dependencies..."
npm install

# Compile contracts
echo "🔨 Compiling contracts..."
node compile.js

# Check if compilation was successful
if [ ! -d "build" ] || [ -z "$(ls -A build 2>/dev/null)" ]; then
    echo "❌ Compilation failed or no contracts compiled"
    exit 1
fi

echo "✅ Compilation successful!"
echo ""
echo "Next steps:"
echo "1. Edit .env file with your PRIVATE_KEY and RPC_URL"
echo "2. Deploy a specific contract:"
echo "   node deploy.js SimpleConfidentialToken"
echo "3. Deploy all contracts:"
echo "   node deploy.js all"
echo "4. Or use the all-in-one command:"
echo "   node deploy-all.js"
