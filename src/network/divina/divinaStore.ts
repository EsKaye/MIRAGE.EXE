import { create } from 'zustand';
import { ethers } from 'ethers';

export interface DivinaState {
  // Connection state
  isConnected: boolean;
  isConnecting: boolean;
  chainId: number | null;
  account: string | null;
  provider: ethers.BrowserProvider | null;
  signer: ethers.JsonRpcSigner | null;
  
  // Network state
  balance: string;
  networkName: string;
  
  // Actions
  connect: () => Promise<void>;
  disconnect: () => void;
  switchNetwork: (chainId: number) => Promise<boolean>;
  getBalance: (address: string) => Promise<void>;
}

export const useDivinaStore = create<DivinaState>((set, get) => ({
  // Initial state
  isConnected: false,
  isConnecting: false,
  chainId: null,
  account: null,
  provider: null,
  signer: null,
  balance: '0',
  networkName: '',

  // Connect to Divina-L3 network
  connect: async () => {
    if (get().isConnecting) return;
    
    try {
      set({ isConnecting: true });
      
      // Check if Web3 is injected
      if (!window.ethereum) {
        throw new Error('No crypto wallet found. Please install MetaMask.');
      }
      
      const provider = new ethers.BrowserProvider(window.ethereum);
      const accounts = await provider.send('eth_requestAccounts', []);
      const signer = await provider.getSigner();
      const network = await provider.getNetwork();
      
      set({
        isConnected: true,
        provider,
        signer,
        account: accounts[0],
        chainId: Number(network.chainId),
        networkName: network.name === 'unknown' ? 'Divina-L3' : network.name,
      });
      
      // Get initial balance
      await get().getBalance(accounts[0]);
      
      // Set up event listeners
      if (window.ethereum.on) {
        window.ethereum.on('accountsChanged', (accounts: string[]) => {
          if (accounts.length === 0) {
            get().disconnect();
          } else {
            set({ account: accounts[0] });
            get().getBalance(accounts[0]);
          }
        });
        
        window.ethereum.on('chainChanged', () => {
          window.location.reload();
        });
      }
      
    } catch (error) {
      console.error('Failed to connect to Divina-L3:', error);
      throw error;
    } finally {
      set({ isConnecting: false });
    }
  },

  // Disconnect from Divina-L3
  disconnect: () => {
    set({
      isConnected: false,
      account: null,
      provider: null,
      signer: null,
      balance: '0',
      chainId: null,
      networkName: '',
    });
  },

  // Switch to a different network
  switchNetwork: async (chainId: number) => {
    try {
      if (!window.ethereum) return false;
      
      await window.ethereum.request({
        method: 'wallet_switchEthereumChain',
        params: [{ chainId: `0x${chainId.toString(16)}` }],
      });
      
      return true;
    } catch (switchError: any) {
      // This error code indicates that the chain has not been added to MetaMask
      if (switchError.code === 4902) {
        // TODO: Add network configuration for Divina-L3
        console.error('Please add the Divina-L3 network to your wallet');
      }
      console.error('Failed to switch network:', switchError);
      return false;
    }
  },

  // Get balance for an address
  getBalance: async (address: string) => {
    const { provider } = get();
    if (!provider) return;
    
    try {
      const balance = await provider.getBalance(address);
      set({ balance: ethers.formatEther(balance) });
    } catch (error) {
      console.error('Failed to get balance:', error);
    }
  },
}));
