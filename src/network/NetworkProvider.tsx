import React, { createContext, useContext, useEffect, useState, ReactNode } from 'react';
import { useDivinaStore } from './divina/divinaStore';
import { useGameDinStore } from './gamedin/gameDinStore';
import { divinaService } from './divina/divinaService';
import { gameDinService } from './gamedin/gameDinService';

interface NetworkContextType {
  // Divina-L3 (Blockchain)
  connectDivina: () => Promise<void>;
  disconnectDivina: () => void;
  isDivinaConnected: boolean;
  divinaAccount: string | null;
  divinaBalance: string;
  
  // GameDin (Multiplayer)
  connectGameDin: (playerName: string) => void;
  disconnectGameDin: () => void;
  isGameDinConnected: boolean;
  currentRoom: any | null;
  availableRooms: any[];
  
  // Loading states
  isInitializing: boolean;
  error: string | null;
}

const NetworkContext = createContext<NetworkContextType | undefined>(undefined);

export const NetworkProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  // Divina-L3 state
  const { 
    isConnected: isDivinaConnected, 
    account: divinaAccount, 
    balance: divinaBalance,
    connect: connectDivinaStore,
    disconnect: disconnectDivinaStore,
  } = useDivinaStore();
  
  // GameDin state
  const { 
    isConnected: isGameDinConnected,
    currentRoom,
    availableRooms,
    connect: connectGameDinStore,
    disconnect: disconnectGameDinStore,
  } = useGameDinStore();
  
  // Local state
  const [isInitializing, setIsInitializing] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Initialize network services
  useEffect(() => {
    const initializeNetworks = async () => {
      try {
        // Check if we have a saved session
        const savedDivinaSession = localStorage.getItem('divinaSession');
        if (savedDivinaSession) {
          try {
            await connectDivinaStore();
          } catch (e) {
            console.warn('Failed to restore Divina session:', e);
            localStorage.removeItem('divinaSession');
          }
        }
        
        // Initialize GameDin connection (but don't connect yet)
        // The actual connection will be established when the player joins a game
        
      } catch (error) {
        console.error('Error initializing networks:', error);
        setError('Failed to initialize network services');
      } finally {
        setIsInitializing(false);
      }
    };

    initializeNetworks();
    
    // Cleanup on unmount
    return () => {
      if (isDivinaConnected) {
        disconnectDivinaStore();
      }
      if (isGameDinConnected) {
        disconnectGameDinStore();
      }
    };
  }, []);

  // Handle Divina-L3 connection
  const handleConnectDivina = async () => {
    try {
      setError(null);
      await connectDivinaStore();
      localStorage.setItem('divinaSession', 'active');
    } catch (error) {
      console.error('Failed to connect to Divina-L3:', error);
      setError('Failed to connect to Divina-L3 network');
      throw error;
    }
  };
  
  // Handle Divina-L3 disconnection
  const handleDisconnectDivina = () => {
    disconnectDivinaStore();
    localStorage.removeItem('divinaSession');
  };
  
  // Handle GameDin connection
  const handleConnectGameDin = (playerName: string) => {
    try {
      setError(null);
      connectGameDinStore(playerName);
    } catch (error) {
      console.error('Failed to connect to GameDin:', error);
      setError('Failed to connect to GameDin server');
      throw error;
    }
  };
  
  // Handle GameDin disconnection
  const handleDisconnectGameDin = () => {
    disconnectGameDinStore();
  };

  return (
    <NetworkContext.Provider
      value={{
        // Divina-L3
        connectDivina: handleConnectDivina,
        disconnectDivina: handleDisconnectDivina,
        isDivinaConnected,
        divinaAccount,
        divinaBalance,
        
        // GameDin
        connectGameDin: handleConnectGameDin,
        disconnectGameDin: handleDisconnectGameDin,
        isGameDinConnected,
        currentRoom,
        availableRooms,
        
        // Loading/Error states
        isInitializing,
        error,
      }}
    >
      {children}
    </NetworkContext.Provider>
  );
};

export const useNetwork = (): NetworkContextType => {
  const context = useContext(NetworkContext);
  if (!context) {
    throw new Error('useNetwork must be used within a NetworkProvider');
  }
  return context;
};

export default NetworkProvider;
