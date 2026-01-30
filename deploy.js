const { ethers } = require('ethers');
require('dotenv').config();
const fs = require('fs-extra');
const path = require('path');
const chalk = require('chalk');

const RPC_URL = process.env.RPC_URL;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const GAS_LIMIT = process.env.GAS_LIMIT || '3000000';
const GAS_PRICE = process.env.GAS_PRICE || '1000000000';
const EXPLORER_URL = process.env.EXPLORER_URL || 'https://explorer.testnet.inco.org';

if (!RPC_URL || !PRIVATE_KEY) {
    console.error(chalk.red('❌ Missing RPC_URL or PRIVATE_KEY in .env file'));
    process.exit(1);
}

const provider = new ethers.JsonRpcProvider(RPC_URL);
const wallet = new ethers.Wallet(PRIVATE_KEY, provider);

async function deployContract(contractName, abi, bytecode, args = []) {
    console.log(chalk.blue(`\n🚀 Deploying ${contractName}...`));
    
    try {
        const factory = new ethers.ContractFactory(abi, bytecode, wallet);
        
        let deploymentTx;
        if (args.length > 0) {
            deploymentTx = await factory.getDeployTransaction(...args);
        } else {
            deploymentTx = await factory.getDeployTransaction();
        }
        
        const estimatedGas = await provider.estimateGas(deploymentTx);
        console.log(chalk.yellow(`   Estimated gas: ${estimatedGas.toString()}`));
        
        const contract = await factory.deploy(...args, {
            gasLimit: ethers.toBigInt(GAS_LIMIT),
            gasPrice: ethers.toBigInt(GAS_PRICE)
        });
        
        console.log(chalk.yellow(`   Transaction hash: ${contract.deploymentTransaction().hash}`));
        console.log(chalk.yellow(`   Waiting for confirmation...`));
        
        await contract.waitForDeployment();
        
        const address = await contract.getAddress();
        console.log(chalk.green(`✅ ${contractName} deployed at: ${address}`));
        
        if (EXPLORER_URL) {
            console.log(chalk.cyan(`   Explorer: ${EXPLORER_URL}/address/${address}`));
        }
        
        return {
            name: contractName,
            address,
            contract,
            txHash: contract.deploymentTransaction().hash
        };
        
    } catch (error) {
        console.log(chalk.red(`❌ Error deploying ${contractName}:`));
        console.log(chalk.red(error.message));
        
        if (error.transaction) {
            console.log(chalk.red(`   Transaction: ${error.transaction.hash}`));
        }
        
        return null;
    }
}

async function deployFromCompiled(contractName) {
    const buildDir = path.join(__dirname, 'build');
    const compiledPath = path.join(buildDir, `${contractName}.json`);
    
    if (!fs.existsSync(compiledPath)) {
        console.log(chalk.red(`❌ Compiled contract ${contractName} not found`));
        console.log(chalk.yellow(`   Run: node compile.js first`));
        return null;
    }
    
    const { abi, bytecode } = fs.readJsonSync(compiledPath);
    return await deployContract(contractName, abi, bytecode);
}

async function deployAll() {
    console.log(chalk.cyan('🚀 Starting deployment of all contracts...'));
    console.log(chalk.yellow(`   Network: ${RPC_URL}`));
    console.log(chalk.yellow(`   Deployer: ${wallet.address}`));
    
    const buildDir = path.join(__dirname, 'build');
    if (!fs.existsSync(buildDir)) {
        console.log(chalk.red('❌ Build directory not found'));
        console.log(chalk.yellow('   Run: node compile.js first'));
        return;
    }
    
    const files = fs.readdirSync(buildDir)
        .filter(file => file.endsWith('.json'))
        .map(file => path.basename(file, '.json'));
    
    if (files.length === 0) {
        console.log(chalk.red('❌ No compiled contracts found'));
        return;
    }
    
    console.log(chalk.cyan(`\n📋 Found ${files.length} contracts to deploy:`));
    files.forEach((file, i) => console.log(chalk.white(`   ${i + 1}. ${file}`)));
    
    const results = [];
    
    for (const contractName of files) {
        const result = await deployFromCompiled(contractName);
        if (result) {
            results.push(result);
            
            const deploymentsDir = path.join(__dirname, 'deployments');
            if (!fs.existsSync(deploymentsDir)) {
                fs.mkdirSync(deploymentsDir, { recursive: true });
            }
            
            fs.writeJsonSync(
                path.join(deploymentsDir, `${contractName}.json`),
                {
                    ...result,
                    deployedAt: new Date().toISOString(),
                    network: RPC_URL,
                    deployer: wallet.address
                },
                { spaces: 2 }
            );
        }
        
        await new Promise(resolve => setTimeout(resolve, 2000));
    }
    
    if (results.length > 0) {
        console.log(chalk.green('\n🎉 Deployment Summary:'));
        console.log(chalk.green('='.repeat(50)));
        
        const report = results.map(r => ({
            Contract: r.name,
            Address: r.address,
            'Tx Hash': r.txHash
        }));
        
        console.table(report);
        
        fs.writeJsonSync(
            path.join(__dirname, 'deployments', 'summary.json'),
            {
                timestamp: new Date().toISOString(),
                deployer: wallet.address,
                network: RPC_URL,
                contracts: results.map(r => ({
                    name: r.name,
                    address: r.address,
                    txHash: r.txHash
                }))
            },
            { spaces: 2 }
        );
        
        console.log(chalk.cyan(`\n📄 Deployment details saved in /deployments directory`));
    } else {
        console.log(chalk.red('\n❌ No contracts were deployed successfully'));
    }
}

async function main() {
    const args = process.argv.slice(2);
    
    if (args.length === 0) {
        console.log(chalk.cyan('🤖 Inco Contract Deployer'));
        console.log(chalk.cyan('='.repeat(30)));
        console.log(chalk.white('Usage:'));
        console.log(chalk.white('  node deploy.js all              - Deploy all compiled contracts'));
        console.log(chalk.white('  node deploy.js <contract-name>  - Deploy specific contract'));
        console.log(chalk.white('\nExample:'));
        console.log(chalk.white('  node deploy.js all'));
        console.log(chalk.white('  node deploy.js SimpleConfidentialToken'));
        return;
    }
    
    const command = args[0];
    
    if (command === 'all') {
        await deployAll();
    } else {
        await deployFromCompiled(command);
    }
}

if (require.main === module) {
    main().catch(error => {
        console.error(chalk.red('❌ Deployment failed:'));
        console.error(chalk.red(error.message));
        process.exit(1);
    });
}

module.exports = { deployContract, deployFromCompiled, deployAll };
