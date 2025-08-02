import { ethers } from 'ethers';
import { DivinaState } from './divinaStore';

// Divina-L3 network configuration
export const DIVINA_NETWORK = {
  chainId: '0x1234', // Replace with actual Divina-L3 chain ID
  chainName: 'Divina L3',
  nativeCurrency: {
    name: 'DIV',
    symbol: 'DIV',
    decimals: 18,
  },
  rpcUrls: ['https://rpc.divina-l3.xyz'], // Replace with actual RPC URL
  blockExplorerUrls: ['https://explorer.divina-l3.xyz'], // Replace with actual explorer URL
};

// Contract ABIs (simplified for example)
const DIVINA_ABI = [
  // ERC-20 standard functions
  'function balanceOf(address owner) view returns (uint256)',
  'function transfer(address to, uint256 amount) returns (bool)',
  // Custom Divina-L3 functions
  'function getPlayerData(address player) view returns (tuple(uint256 level, uint256 experience, string memory name))',
  'function updatePlayerName(string memory newName)',
];

// Contract addresses (replace with actual addresses)
const CONTRACT_ADDRESSES = {
  main: '0x0000000000000000000000000000000000000000', // Replace with actual address
};

export class DivinaService {
  private provider: ethers.BrowserProvider | null = null;
  private signer: ethers.JsonRpcSigner | null = null;
  private contract: ethers.Contract | null = null;

  constructor() {
    this.initialize();
  }

  private async initialize() {
    if (typeof window.ethereum === 'undefined') {
      console.warn('No Ethereum provider found');
      return;
    }

    this.provider = new ethers.BrowserProvider(window.ethereum);
    this.signer = await this.provider.getSigner();
    
    // Initialize contract instance
    this.contract = new ethers.Contract(
      CONTRACT_ADDRESSES.main,
      DIVINA_ABI,
      this.signer
    );
  }

  // Check if Divina-L3 network is added to wallet
  async isNetworkConfigured(): Promise<boolean> {
    if (!this.provider) return false;
    
    try {
      const network = await this.provider.getNetwork();
      return network.chainId.toString(16) === DIVINA_NETWORK.chainId.slice(2);
    } catch (error) {
      console.error('Error checking network:', error);
      return false;
    }
  }

  // Add Divina-L3 network to wallet
  async addNetworkToWallet(): Promise<boolean> {
    try {
      await window.ethereum.request({
        method: 'wallet_addEthereumChain',
        params: [DIVINA_NETWORK],
      });
      return true;
    } catch (addError) {
      console.error('Error adding network:', addError);
      return false;
    }
  }

  // Get player data from the blockchain
  async getPlayerData(address: string) {
    if (!this.contract) throw new Error('Contract not initialized');
    
    try {
      const playerData = await this.contract.getPlayerData(address);
      return {
        level: playerData.level.toString(),
        experience: playerData.experience.toString(),
        name: playerData.name,
      };
    } catch (error) {
      console.error('Error fetching player data:', error);
      throw error;
    }
  }

  // Update player name on the blockchain
  async updatePlayerName(newName: string) {
    if (!this.contract) throw new Error('Contract not initialized');
    
    try {
      const tx = await this.contract.updatePlayerName(newName);
      await tx.wait();
      return tx.hash;
    } catch (error) {
      console.error('Error updating player name:', error);
      throw error;
    }
  }

  // Transfer tokens to another address
  async transferTokens(to: string, amount: string) {
    if (!this.contract) throw new Error('Contract not initialized');
    
    try {
      const tx = await this.contract.transfer(to, ethers.parseEther(amount));
      await tx.wait();
      return tx.hash;
    } catch (error) {
      console.error('Error transferring tokens:', error);
      throw error;
    }
  }
}

export const divinaService = new DivinaService();
