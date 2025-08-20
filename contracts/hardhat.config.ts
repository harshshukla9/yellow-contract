import { HardhatUserConfig, vars } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomicfoundation/hardhat-ignition";

const config: HardhatUserConfig = {
  networks: {
    yellowTestnet: {
      url: vars.get('YELLOW_RPC_URL', 'https://rpc.yellow.org'),
      chainId: parseInt(vars.get('YELLOW_CHAIN_ID', '12345')),
      accounts: [vars.get('PRIVATE_KEY')],
    },
    yellowMainnet: {
      url: vars.get('YELLOW_MAINNET_RPC_URL', 'https://mainnet-rpc.yellow.org'),
      chainId: parseInt(vars.get('YELLOW_MAINNET_CHAIN_ID', '54321')),
      accounts: [vars.get('PRIVATE_KEY')],
    },
  },
  etherscan: {
    apiKey: {
      yellowTestnet: vars.get('YELLOW_EXPLORER_API_KEY', ''),
      yellowMainnet: vars.get('YELLOW_EXPLORER_API_KEY', ''),
    },
    customChains: [
      {
        network: "yellowTestnet",
        chainId: parseInt(vars.get('YELLOW_CHAIN_ID', '12345')),
        urls: {
          apiURL: vars.get('YELLOW_EXPLORER_API_URL', 'https://explorer.yellow.org/api'),
          browserURL: vars.get('YELLOW_EXPLORER_URL', 'https://explorer.yellow.org')
        }
      },
      {
        network: "yellowMainnet", 
        chainId: parseInt(vars.get('YELLOW_MAINNET_CHAIN_ID', '54321')),
        urls: {
          apiURL: vars.get('YELLOW_MAINNET_EXPLORER_API_URL', 'https://mainnet-explorer.yellow.org/api'),
          browserURL: vars.get('YELLOW_MAINNET_EXPLORER_URL', 'https://mainnet-explorer.yellow.org')
        }
      }
    ]
  },
  solidity: "0.8.28",
};

export default config;
