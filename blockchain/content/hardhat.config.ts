// import type { HardhatUserConfig } from "hardhat/config";

// import hardhatToolboxViemPlugin from "@nomicfoundation/hardhat-toolbox-viem";
// import { configVariable } from "hardhat/config";

// const config: HardhatUserConfig = {
//   plugins: [hardhatToolboxViemPlugin],
//   solidity: {
//     profiles: {
//       default: {
//         version: "0.8.28",
//       },
//       production: {
//         version: "0.8.28",
//         settings: {
//           optimizer: {
//             enabled: true,
//             runs: 200,
//           },
//         },
//       },
//     },
//   },
//   networks: {
//     hardhatMainnet: {
//       type: "edr-simulated",
//       chainType: "l1",
//     },
//     hardhatOp: {
//       type: "edr-simulated",
//       chainType: "op",
//     },
//     sepolia: {
//       type: "http",
//       chainType: "l1",
//       url: configVariable("SEPOLIA_RPC_URL"),
//       accounts: [configVariable("SEPOLIA_PRIVATE_KEY")],
//     },
//   },
// };

// export default config;


import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import * as dotenv from "dotenv";
dotenv.config();

const config: HardhatUserConfig = {
  solidity: "0.8.24",
  networks: {
    hardhat: {},
    avalanche: {
      url: process.env.AVALANCHE_RPC_URL || "https://api.avax.network/ext/bc/C/rpc",
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : []
    }
  },
  etherscan: {
    apiKey: process.env.SNOWTRACE_API_KEY
  }
};

export default config;
