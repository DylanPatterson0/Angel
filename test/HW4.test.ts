// Start - Support direct Mocha run & debug
import 'hardhat'
import '@nomiclabs/hardhat-ethers'
// End - Support direct Mocha run & debug

import chai, {expect} from 'chai'
import {before} from 'mocha'
import {solidity} from 'ethereum-waffle'
import {deployContract, signer} from './framework/contracts'
import {SignerWithAddress} from '@nomiclabs/hardhat-ethers/signers'
import {successfulTransaction} from './framework/transaction'
import {HW4} from '../typechain-types'
import {ethers} from 'ethers'

chai.use(solidity)

describe('HW4: 5.5%', () => {
    let contract: HW4
    let s0: SignerWithAddress, s1: SignerWithAddress
    let s0Addr: string, s1Addr: string

    before(async () => {
        s0 = await signer(0)
        s1 = await signer(1)
        s0Addr = s0.address
        s1Addr = s1.address
    })

    beforeEach(async () => {
        contract = await deployContract<HW4>('HW4')
    })

    describe('2) Standalone Function: 1.5%', () => {
        it('1. getMin: 1.5%', async () => {
            // eslint-disable-next-line @typescript-eslint/no-unsafe-assignment
            const input = [...Array(10)].map(() =>
                Math.ceil(Math.random() * 10000)
            )
            const result = await contract.getMin(input)
            expect(result).equals(Math.min(...input))
        })
    })

    describe('3) Registry: 4%', () => {
        let recipients: string[]
        const depositAmount = ethers.utils.parseEther(
            `${Math.floor(Math.random() * 10)}`
        )

        before(() => {
            recipients = [s0Addr, s1Addr]
        })

        it('1. Ownable: 0.5%', async () => {
            expect(await contract.owner()).equals(s0Addr)
            const tx = await contract.connect(s0).transferOwnership(s1Addr)
            void expect(tx)
                .to.emit(contract, 'OwnershipTransferred')
                .withArgs(s1Addr)
            expect(await contract.owner()).equals(s1Addr)
            await expect(contract.connect(s0).transferOwnership(s0Addr)).to.be
                .reverted
        })
        it('2. Pausable: 0.5%', async () => {
            expect(await contract.paused()).equals(false)
            await contract.connect(s0).togglePause()
            expect(await contract.paused()).equals(true)
        })
        describe('3. Deposit: 1.5%', () => {
            it('A. deposit() + balanceOf(): 1.2%', async () => {
                const tx = await contract.connect(s0).deposit('target', s1Addr, {
                    value: depositAmount
                })
                void expect(tx)
                    .to.emit(contract, 'DidDepositFunds')
                    .withArgs('target', s1Addr)
                const balanceR1 = await contract.balanceOf('target', s1Addr)
                expect(balanceR1).equals(depositAmount)
            })
            it('B. deposit() cannot run while paused: 0.3%', async () => {
                await contract.connect(s0).togglePause()
                await expect(
                    contract.connect(s0).deposit('target', s1Addr, {
                        value: depositAmount
                    })
                ).to.be.reverted
            })
        })
        describe('4. Withdraw: 1.5%', () => {
            it('A. Normal withdraw(): 0.9%', async () => {
                const startingBalanceS0 = await s0.getBalance()
                const startingBalanceS1 = await s1.getBalance()
                const receiptS0 = await successfulTransaction(
                    contract.connect(s0).deposit('target', s1Addr, {
                        value: depositAmount
                    })
                )
                const withdrawAmount = await contract.balanceOf('target', s1Addr)
                const txS1 = await contract.connect(s1).withdraw(withdrawAmount)
                const receiptS1 = await successfulTransaction(
                    contract.connect(s1).withdraw(withdrawAmount)
                )
                void expect(txS1)
                    .to.emit(contract, 'DidWithdrawFunds')
                    .withArgs(withdrawAmount, s1.address)
                expect(await s0.getBalance()).equals(
                    startingBalanceS0
                        .sub(depositAmount)
                        .sub(
                            receiptS0.gasUsed.mul(
                                receiptS0.effectiveGasPrice
                            )
                        )
                        .sub(receiptS0.gasUsed.mul(receiptS0.effectiveGasPrice))
                )
                expect(await s1.getBalance()).equals(
                    startingBalanceS1
                        .sub(receiptS1.gasUsed.mul(receiptS1.effectiveGasPrice))
                        .add(withdrawAmount)
                )
            })
            it('B. withdraw() overdraft should fail: 0.3%', async () => {
                await contract.connect(s0).deposit('target', s1Addr, {
                    value: depositAmount
                })
                const withdrawAmount = await contract.balanceOf(s1Addr)
                await expect(
                    contract.connect(s1).withdraw(withdrawAmount.mul(2))
                ).to.be.reverted
            })
            it('C. withdraw() cannot run while paused: 0.3%', async () => {
                await contract.connect(s0).togglePause()
                await expect(contract.connect(s0).withdraw(0)).to.be.reverted
            })
        })
    })
})
