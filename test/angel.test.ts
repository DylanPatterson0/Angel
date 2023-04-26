// Start - Support direct Mocha run & debug
import 'hardhat'
import '@nomiclabs/hardhat-ethers'
// End - Support direct Mocha run & debug

import chai, {expect} from 'chai'
import hre from 'hardhat'
import {before} from 'mocha'
import {solidity} from 'ethereum-waffle'
import {deployContract, signer} from './framework/contracts'
import {SignerWithAddress} from '@nomiclabs/hardhat-ethers/signers'
import {successfulTransaction} from './framework/transaction'
import {
    ContractFactory,
    ControllerTemplate,
    TokenTemplate
} from '../typechain-types'
// eslint-disable-next-line no-duplicate-imports
import {ethers} from 'hardhat'

chai.use(solidity)

describe('Angel:', () => {
    let contractFactory: ContractFactory
    let controllerContract: ControllerTemplate
    let tokenContract: TokenTemplate
    let s0: SignerWithAddress, s1: SignerWithAddress, s2: SignerWithAddress
    let s0Addr: string, s1Addr: string, s2Addr: string

    before(async () => {
        s0 = await signer(0)
        s1 = await signer(1)
        s2 = await signer(2)
        s0Addr = s0.address
        s1Addr = s1.address
        s2Addr = s2.address
    })

    beforeEach(async () => {
        contractFactory = await deployContract<ContractFactory>(
            'contracts/ContractFactory.sol:ContractFactory'
        )
    })

    describe('Unit tests for deployment', () => {
        /*
         * s0 is owner
         * s1 is operator
         */
        it('Contract Factory: deploy controller contract and check for event emission', async () => {
            const tx = await contractFactory
                .connect(s0)
                .createController(s1.address)
            void expect(tx)
                .to.emit(contractFactory, 'ControllerDeployed')
                .withArgs(s1.address)
        })
        it('Contract Factory: deploy token contract and check for event emission', async () => {
            const tx = await contractFactory
                .connect(s0)
                .createToken(s1.address, 'token', 'SYM', 10000)
            await expect(tx)
                .to.emit(contractFactory, 'TokenDeployed')
                .withArgs(s1.address, 'token', 'SYM', 10000)
        })
        it('Contract Factory: launchTokenControllerPair', async () => {
            const tx = await contractFactory
                .connect(s0)
                .launchTokenControllerPair(s1.address, 'token', 'SYM', 10000)
            await expect(tx)
                .to.emit(contractFactory, 'ControllerDeployed')
                .withArgs(s1.address)
            await expect(tx)
                .to.emit(contractFactory, 'TokenDeployed')
                .withArgs(s1.address, 'token', 'SYM', 10000)
        })
    })
    describe('Function tests', () => {
        /*
         * s0 is owner
         * s1 is operator
         */
        it('Launch and mint tokens', async () => {
            const returnValue = await contractFactory
                .connect(s0)
                .callStatic.launchTokenControllerPair(
                    s1.address,
                    'token',
                    'SYM',
                    10000
                )

            await contractFactory
                .connect(s0)
                .launchTokenControllerPair(s1.address, 'token', 'SYM', 10000)

            tokenContract = <TokenTemplate>(
                await hre.ethers.getContractAt('TokenTemplate', returnValue[0])
            )
            controllerContract = <ControllerTemplate>(
                await hre.ethers.getContractAt(
                    'ControllerTemplate',
                    returnValue[1]
                )
            )

            const tx = await controllerContract
                .connect(s2)
                .invest(s2.address, 100)
            await expect(tx)
                .to.emit(tokenContract, 'Minted')
                .withArgs(s2.address, 100, tokenContract.address)
            await expect(tx)
                .to.emit(controllerContract, 'Invested')
                .withArgs(s2.address, 100, tokenContract.address)

            // need to check timestamp / lockup period funcitonality
        })
        it('Should revert if sale before lockup period', async () => {
            const returnValue = await contractFactory
                .connect(s0)
                .callStatic.launchTokenControllerPair(
                    s1.address,
                    'token',
                    'SYM',
                    10000
                )
            await contractFactory
                .connect(s0)
                .launchTokenControllerPair(s1.address, 'token', 'SYM', 10000)
            tokenContract = <TokenTemplate>(
                await hre.ethers.getContractAt('TokenTemplate', returnValue[0])
            )
            controllerContract = <ControllerTemplate>(
                await hre.ethers.getContractAt(
                    'ControllerTemplate',
                    returnValue[1]
                )
            )
            await controllerContract.connect(s2).invest(s2.address, 100)

            // make random number for amount
            await tokenContract
                .connect(s2)
                .approve(controllerContract.address, 20)
            await expect(
                controllerContract
                    .connect(s2)
                    .sellTokens(s0.address, s2.address, 10)
            ).to.be.revertedWith('Tokens locked up')
        })
    })
})
