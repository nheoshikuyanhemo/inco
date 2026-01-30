const fs = require('fs-extra');
const solc = require('solc');
const path = require('path');
const chalk = require('chalk');

async function compileContract(contractPath) {
    console.log(chalk.blue(`\n🔨 Compiling: ${contractPath}`));
    
    try {
        const source = fs.readFileSync(contractPath, 'utf8');
        const contractMatch = source.match(/contract\s+(\w+)/);
        if (!contractMatch) {
            console.log(chalk.yellow(`⚠️  No contract found in ${contractPath}`));
            return null;
        }
        const contractName = contractMatch[1];
        
        const input = {
            language: 'Solidity',
            sources: {
                [contractPath]: {
                    content: source
                }
            },
            settings: {
                optimizer: {
                    enabled: true,
                    runs: 200
                },
                evmVersion: 'paris',
                outputSelection: {
                    '*': {
                        '*': ['abi', 'evm.bytecode']
                    }
                }
            }
        };
        
        const output = JSON.parse(solc.compile(JSON.stringify(input)));
        
        if (output.errors) {
            const errors = output.errors.filter(err => err.severity === 'error');
            if (errors.length > 0) {
                console.log(chalk.red('❌ Compilation errors:'));
                errors.forEach(err => console.log(chalk.red(`   ${err.formattedMessage || err.message}`)));
                return null;
            }
        }
        
        if (!output.contracts[contractPath] || !output.contracts[contractPath][contractName]) {
            console.log(chalk.red(`❌ Contract ${contractName} not found in output`));
            return null;
        }
        
        const contract = output.contracts[contractPath][contractName];
        
        const buildDir = path.join(__dirname, 'build');
        if (!fs.existsSync(buildDir)) {
            fs.mkdirSync(buildDir, { recursive: true });
        }
        
        const compiledPath = path.join(buildDir, `${contractName}.json`);
        fs.writeJsonSync(compiledPath, {
            contractName,
            abi: contract.abi,
            bytecode: contract.evm.bytecode.object
        }, { spaces: 2 });
        
        console.log(chalk.green(`✅ Compiled ${contractName} → ${compiledPath}`));
        
        return {
            name: contractName,
            abi: contract.abi,
            bytecode: contract.evm.bytecode.object
        };
        
    } catch (error) {
        console.log(chalk.red(`❌ Error compiling ${contractPath}:`));
        console.log(chalk.red(error.message));
        return null;
    }
}

async function compileAll() {
    console.log(chalk.cyan('🚀 Starting compilation of all contracts...'));
    
    const files = fs.readdirSync(__dirname)
        .filter(file => file.endsWith('.sol'))
        .map(file => path.join(__dirname, file));
    
    const compiledContracts = [];
    
    for (const file of files) {
        const compiled = await compileContract(file);
        if (compiled) {
            compiledContracts.push({
                ...compiled,
                sourceFile: path.basename(file)
            });
        }
    }
    
    console.log(chalk.green(`\n🎉 Compiled ${compiledContracts.length} contracts successfully!`));
    return compiledContracts;
}

if (require.main === module) {
    compileAll().catch(console.error);
}

module.exports = { compileContract, compileAll };
