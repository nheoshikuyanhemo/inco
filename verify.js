const { ethers } = require('ethers');
require('dotenv').config();
const fs = require('fs-extra');
const path = require('path');
const chalk = require('chalk');
const axios = require('axios');

const RPC_URL = process.env.RPC_URL;
const EXPLORER_API = process.env.EXPLORER_API || '';
const PRIVATE_KEY = process.env.PRIVATE_KEY;

async function verifyOnExplorer(contractAddress, contractName, sourceCode) {
    if (!EXPLORER_API) {
        console.log(chalk.yellow('⚠️  Explorer API URL not configured in .env'));
        return false;
    }
    
    console.log(chalk.blue(`\n🔍 Verifying ${contractName} on explorer...`));
    
    try {
        const response = await axios.post(EXPLORER_API, {
            address: contractAddress,
            contractName: contractName,
            sourceCode: sourceCode,
            compilerVersion: 'v0.8.23',
            optimizationUsed: true,
            runs: 200
        });
        
        if (response.data.status === '1') {
            console.log(chalk.green(`✅ ${contractName} verified successfully!`));
            return true;
        } else {
            console.log(chalk.red(`❌ Verification failed: ${response.data.message}`));
            return false;
        }
    } catch (error) {
        console.log(chalk.red(`❌ Error during verification: ${error.message}`));
        return false;
    }
}

async function verifyContract(contractName) {
    console.log(chalk.cyan(`\n🔎 Verifying ${contractName}...`));
    
    const deploymentPath = path.join(__dirname, 'deployments', `${contractName}.json`);
    if (!fs.existsSync(deploymentPath)) {
        console.log(chalk.red(`❌ Deployment info not found for ${contractName}`));
        return false;
    }
    
    const deployment = fs.readJsonSync(deploymentPath);
    const { address, txHash } = deployment;
    
    const sourceFiles = fs.readdirSync(__dirname)
        .filter(file => file.endsWith('.sol'))
        .map(file => path.join(__dirname, file));
    
    let sourceCode = '';
    for (const file of sourceFiles) {
        const content = fs.readFileSync(file, 'utf8');
        if (content.includes(`contract ${contractName}`)) {
            sourceCode = content;
            break;
        }
    }
    
    if (!sourceCode) {
        console.log(chalk.red(`❌ Source code not found for ${contractName}`));
        return false;
    }
    
    console.log(chalk.yellow(`   Address: ${address}`));
    console.log(chalk.yellow(`   Tx Hash: ${txHash}`));
    
    if (EXPLORER_API) {
        return await verifyOnExplorer(address, contractName, sourceCode);
    } else {
        try {
            const provider = new ethers.JsonRpcProvider(RPC_URL);
            const code = await provider.getCode(address);
            
            if (code && code !== '0x') {
                console.log(chalk.green(`✅ ${contractName} is deployed at ${address}`));
                console.log(chalk.yellow(`   Code size: ${(code.length - 2) / 2} bytes`));
                return true;
            } else {
                console.log(chalk.red(`❌ No code at address ${address}`));
                return false;
            }
        } catch (error) {
            console.log(chalk.red(`❌ Error checking contract: ${error.message}`));
            return false;
        }
    }
}

async function verifyAll() {
    console.log(chalk.cyan('🔎 Verifying all deployed contracts...'));
    
    const deploymentsDir = path.join(__dirname, 'deployments');
    if (!fs.existsSync(deploymentsDir)) {
        console.log(chalk.red('❌ No deployments found'));
        return;
    }
    
    const files = fs.readdirSync(deploymentsDir)
        .filter(file => file.endsWith('.json') && file !== 'summary.json')
        .map(file => path.basename(file, '.json'));
    
    if (files.length === 0) {
        console.log(chalk.red('❌ No deployment files found'));
        return;
    }
    
    const results = [];
    
    for (const contractName of files) {
        const success = await verifyContract(contractName);
        results.push({ contract: contractName, verified: success });
        
        await new Promise(resolve => setTimeout(resolve, 1000));
    }
    
    console.log(chalk.cyan('\n📊 Verification Summary:'));
    console.log(chalk.cyan('='.repeat(40)));
    
    const verified = results.filter(r => r.verified).length;
    const total = results.length;
    
    console.log(chalk.white(`   Verified: ${verified}/${total}`));
    
    if (verified === total) {
        console.log(chalk.green('🎉 All contracts verified successfully!'));
    } else {
        console.log(chalk.yellow(`⚠️  ${total - verified} contracts failed verification`));
    }
}

async function main() {
    const args = process.argv.slice(2);
    
    if (args.length === 0) {
        console.log(chalk.cyan('🔍 Contract Verifier'));
        console.log(chalk.cyan('='.repeat(30)));
        console.log(chalk.white('Usage:'));
        console.log(chalk.white('  node verify.js all              - Verify all deployed contracts'));
        console.log(chalk.white('  node verify.js <contract-name>  - Verify specific contract'));
        return;
    }
    
    const command = args[0];
    
    if (command === 'all') {
        await verifyAll();
    } else {
        await verifyContract(command);
    }
}

if (require.main === module) {
    main().catch(error => {
        console.error(chalk.red('❌ Verification failed:'));
        console.error(chalk.red(error.message));
        process.exit(1);
    });
}

module.exports = { verifyContract, verifyAll };
