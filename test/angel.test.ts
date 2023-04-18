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
import {ContractFactory, ControllerTemplate} from '../typechain-types'

import {ethers} from 'ethers'

chai.use(solidity)

describe('Angel:', () => {
    let contractOne: ContractFactory
    let contractTwo: ControllerTemplate
    let s0: SignerWithAddress, s1: SignerWithAddress
    let s0Addr: string, s1Addr: string

    before(async () => {
        s0 = await signer(0)
        s1 = await signer(1)
        s0Addr = s0.address
        s1Addr = s1.address
    })

    beforeEach(async () => {
        contractOne = await deployContract<ContractFactory>('ContractFactory')
        contractTwo = await deployContract<ControllerTemplate>(
            'ControllerTemplate'
        )
    })

    describe('2) Standalone Function: 1.5%', () => {
        it('Set Cotroller Contract', async () => {
            /*
             * const setController = await contract
             *     .connect(s0)
             *     .setController()
             */
        })
    })
})
