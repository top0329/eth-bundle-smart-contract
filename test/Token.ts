import {
  time,
  loadFixture,
} from '@nomicfoundation/hardhat-toolbox/network-helpers';
import { anyValue } from '@nomicfoundation/hardhat-chai-matchers/withArgs';
import { expect } from 'chai';
import hre, { ethers } from 'hardhat';
import { SignerWithAddress } from '@nomicfoundation/hardhat-ethers/signers';

describe('Token', function () {
  let token: any;
  let tokenFactory: any;
  let Uniswap: any;
  let owner: SignerWithAddress;
  let addr1: SignerWithAddress;
  let addr2: SignerWithAddress;

  beforeEach(async function () {
    [owner, addr1, addr2] = await ethers.getSigners();

    const WETHContract = await ethers.getContractFactory('WETH9');
    const WETH = await WETHContract.deploy();

    const UniswapFactoryContract = await ethers.getContractFactory(
      'UniswapV2Factory'
    );

    const UniswapFactory = await UniswapFactoryContract.deploy();

    const UniswapContract = await ethers.getContractFactory(
      'UniswapV2Router02'
    );
    Uniswap = await UniswapContract.deploy(
      await UniswapFactory.getAddress(),
      await WETH.getAddress()
    );

    const Token = await ethers.getContractFactory('TOKEN');
    const TokenFactory = await ethers.getContractFactory('TokenFactory');
    token = await Token.deploy('First Token', 'TKN', 100000000000, 18);
    tokenFactory = await TokenFactory.deploy();
  });

  it('should have correct name, symbol, and decimals', async function () {
    console.log('Token deployed to:', await token.getAddress());
    console.log('TokenFactory deployed to:', await tokenFactory.getAddress());
    console.log('Uniswap Router:', await Uniswap.getAddress());
    expect(await token.name()).to.equal('First Token');
    expect(await token.symbol()).to.equal('TKN');
    expect(await token.decimals()).to.equal(18);
  });

  it('should create new token', async function () {
    const tokenFactoryAddress = await tokenFactory.getAddress();
    // const tokenFactoryContract =
  });
});
