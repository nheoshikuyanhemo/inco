#!/usr/bin/env node
const { compileAll } = require('./compile.js');
const { deployAll } = require('./deploy.js');
const chalk = require('chalk');

async function main() {
    console.log(chalk.cyan('🚀 Starting full deployment pipeline...'));
    console.log(chalk.cyan('='.repeat(50)));
    
    try {
        console.log(chalk.blue('\n📦 Step 1: Compiling contracts...'));
        const compiled = await compileAll();
        
        if (compiled.length === 0) {
            console.log(chalk.red('❌ No contracts compiled successfully'));
            process.exit(1);
        }
        
        console.log(chalk.blue('\n🚀 Step 2: Deploying contracts...'));
        await deployAll();
        
        console.log(chalk.green('\n🎉 Full deployment completed successfully!'));
        
    } catch (error) {
        console.error(chalk.red('\n❌ Deployment pipeline failed:'));
        console.error(chalk.red(error.message));
        process.exit(1);
    }
}

if (require.main === module) {
    main().catch(console.error);
}
