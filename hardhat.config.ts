import { HardhatUserConfig } from 'hardhat/config';
import '@nomicfoundation/hardhat-toolbox';
import '@nomicfoundation/hardhat-verify';
import 'dotenv/config';

const config: HardhatUserConfig = {
  solidity: {
    compilers: [
      {
        version: '0.4.18',
        settings: {
          optimizer: {
            enabled: true,
          },
        },
      },
      {
        version: '0.5.16',
        settings: {
          optimizer: {
            enabled: true,
          },
        },
      },
      {
        version: '0.6.6',
        settings: {
          optimizer: {
            enabled: true,
          },
        },
      },
      {
        version: '0.8.19',
        settings: {
          optimizer: {
            enabled: true,
          },
        },
      },
      {
        version: '0.8.24',
        settings: {
          optimizer: {
            enabled: true,
          },
        },
      },
    ],
  },
  networks: {
    sepolia: {
      url: `https://sepolia.infura.io/v3/${process.env.INFURA_API_KEY}`,
      accounts: [process.env.SEPOLIA_PRIVATE_KEY!],
    },
  },
  etherscan: {
    // Your API key for Etherscan
    // Obtain one at https://etherscan.io/
    apiKey: 'JA8GEE6AYZKNPFD6HR6KZYV6V4J1SSRFWC',
  },
  sourcify: {
    enabled: true,
  },
};

export default config;
