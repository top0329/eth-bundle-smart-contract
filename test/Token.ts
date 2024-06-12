import {
  time,
  loadFixture,
} from '@nomicfoundation/hardhat-toolbox/network-helpers';
import { anyValue } from '@nomicfoundation/hardhat-chai-matchers/withArgs';
import { expect } from 'chai';
import hre, { ethers } from 'hardhat';
import { SignerWithAddress } from '@nomicfoundation/hardhat-ethers/signers';
import tokenAbi from '../artifacts/contracts/Token.sol/TOKEN.json';

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
    token = await Token.deploy(
      'First Token',
      'TKN',
      100000000000,
      18,
      await Uniswap.getAddress()
    );
    tokenFactory = await TokenFactory.deploy();
  });

  it('test the addLiquidityETH function', async function () {
    await Uniswap.addLiquidityETH(
      await token.getAddress(),
      100000,
      0,
      ethers.parseEther('5'),
      await owner.getAddress(),
      // await ethers.provider.getBlock('latest')
      1719622129
    );
  });

  // it('should be return the token contract address', async function () {
  //   console.log(await token.getAddress());
  // });

  it('should have correct name, symbol, and decimals', async function () {
    // console.log('Token deployed to:', await token.getAddress());
    // console.log('Token owner:', await token.owner());
    // console.log('TokenFactory deployed to:', await tokenFactory.getAddress());
    console.log('Uniswap Router:', await Uniswap.getAddress());
    const address = await owner.getAddress();
    // console.log(await owner.getAddress());
    await tokenFactory.createToken(
      'First Token',
      'TKN',
      100000000000,
      18,
      address,
      await Uniswap.getAddress()
    );
    // console.log(
    //   'token contract address on test script',
    //   await tokenFactory.devTokenContractAddress()
    // );
    const tokenContractAddress = await tokenFactory.devTokenContractAddress();
    const tokenContract = new ethers.Contract(
      tokenContractAddress,
      tokenAbi.abi,
      owner
    );
    // console.log(await tokenContract.owner());
    // const tx = await tokenContract.addLP();
    // console.log(tx);\
    console.log(
      'Eth balance of token contract',
      await ethers.provider.getBalance(await tokenContractAddress)
    );

    await owner.sendTransaction({
      to: await tokenContract.getAddress(),
      value: ethers.parseEther('100'),
    });

    const tx = await tokenContract.addLP();
    // console.log('addLP',tx)
    expect(await tokenContract.name()).to.equal('First Token');
    expect(await tokenContract.owner()).to.equal(
      address
      // '0x48C281DB38eAD8050bBd821d195FaE85A235d8fc'
    );
    expect(await tokenContract.symbol()).to.equal('TKN');
    expect(await tokenContract.decimals()).to.equal(18);
  });

  it('should create new token', async function () {
    await tokenFactory.createToken(
      'Second Token',
      'STK',
      1000000000,
      18,
      '0x48C281DB38eAD8050bBd821d195FaE85A235d8fc',
      await Uniswap.getAddress()
    );
  });

  it('TransferOwnership Test', async function () {
    await token.transferOwnership('0x48C281DB38eAD8050bBd821d195FaE85A235d8fc');
  });

  it('balanceOf Test', async function () {
    await token.balanceOf('0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266');
    await token.balanceOf('0x48C281DB38eAD8050bBd821d195FaE85A235d8fc');
    // console.log(
    //   await token.balanceOf('0x48C281DB38eAD8050bBd821d195FaE85A235d8fc')
    // );
  });

  it('enableTrading Test', async function () {
    // console.log(await token.getTradingStatus());
    await token.enableTrading();
    // console.log(await token.getTradingStatus());
  });

  it('newFee Test', async function () {
    // console.log(await token.buyTax());
    // console.log(await token.sellTax());
    await token.newFee(5, 7);
    // console.log(await token.buyTax());
    // console.log(await token.sellTax());
  });
});
