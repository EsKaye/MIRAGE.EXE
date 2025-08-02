import React from 'react';
import { useNetwork } from '../network/NetworkProvider';
import { motion, AnimatePresence } from 'framer-motion';
import { FaEthereum, FaGamepad, FaPlug, FaSpinner } from 'react-icons/fa';

const NetworkStatus: React.FC = () => {
  const {
    isDivinaConnected,
    isGameDinConnected,
    divinaAccount,
    divinaBalance,
    currentRoom,
    error,
  } = useNetwork();

  // Format Ethereum address
  const formatAddress = (address: string | null) => {
    if (!address) return 'Not connected';
    return `${address.substring(0, 6)}...${address.substring(address.length - 4)}`;
  };

  // Format balance
  const formatBalance = (balance: string) => {
    return parseFloat(balance).toFixed(4);
  };

  return (
    <div className="fixed bottom-4 right-4 z-50 flex flex-col gap-2">
      {/* Error notification */}
      <AnimatePresence>
        {error && (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: 20 }}
            className="bg-red-600 text-white px-4 py-2 rounded-md shadow-lg flex items-center gap-2"
          >
            <FaPlug className="animate-pulse" />
            <span>{error}</span>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Network status cards */}
      <div className="flex flex-col gap-2">
        {/* Divina-L3 Status */}
        <motion.div
          layout
          className={`bg-gray-800 bg-opacity-90 backdrop-blur-sm rounded-md p-3 shadow-lg border-l-4 ${
            isDivinaConnected ? 'border-blue-500' : 'border-gray-600'
          }`}
          initial={{ opacity: 0, x: 50 }}
          animate={{ opacity: 1, x: 0 }}
          transition={{ type: 'spring', stiffness: 300, damping: 30 }}
        >
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <FaEthereum className={`text-xl ${isDivinaConnected ? 'text-blue-400' : 'text-gray-400'}`} />
              <span className="font-mono text-sm">DIVINA-L3</span>
            </div>
            <div className="flex items-center gap-2">
              <span className={`h-2 w-2 rounded-full ${isDivinaConnected ? 'bg-green-500' : 'bg-red-500'}`} />
              <span className="text-xs">
                {isDivinaConnected ? 'Connected' : 'Disconnected'}
              </span>
            </div>
          </div>
          
          {isDivinaConnected && (
            <div className="mt-2 pt-2 border-t border-gray-700">
              <div className="text-xs text-gray-300">Account</div>
              <div className="font-mono text-sm">{formatAddress(divinaAccount)}</div>
              <div className="text-xs text-gray-300 mt-1">Balance</div>
              <div className="font-mono text-sm">{formatBalance(divinaBalance)} DIV</div>
            </div>
          )}
        </motion.div>

        {/* GameDin Status */}
        <motion.div
          layout
          className={`bg-gray-800 bg-opacity-90 backdrop-blur-sm rounded-md p-3 shadow-lg border-l-4 ${
            isGameDinConnected ? 'border-purple-500' : 'border-gray-600'
          }`}
          initial={{ opacity: 0, x: 50 }}
          animate={{ opacity: 1, x: 0 }}
          transition={{ type: 'spring', stiffness: 300, damping: 30, delay: 0.1 }}
        >
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <FaGamepad className={`text-xl ${isGameDinConnected ? 'text-purple-400' : 'text-gray-400'}`} />
              <span className="font-mono text-sm">GAMEDIN</span>
            </div>
            <div className="flex items-center gap-2">
              <span className={`h-2 w-2 rounded-full ${isGameDinConnected ? 'bg-green-500' : 'bg-red-500'}`} />
              <span className="text-xs">
                {isGameDinConnected ? 'Connected' : 'Disconnected'}
              </span>
            </div>
          </div>
          
          {isGameDinConnected && currentRoom && (
            <div className="mt-2 pt-2 border-t border-gray-700">
              <div className="text-xs text-gray-300">Room</div>
              <div className="text-sm truncate">{currentRoom.name}</div>
              <div className="text-xs text-gray-300 mt-1">Players</div>
              <div className="text-sm">
                {currentRoom.players.filter((p: any) => p.isReady).length} / {currentRoom.maxPlayers} ready
              </div>
            </div>
          )}
        </motion.div>
      </div>
    </div>
  );
};

export default NetworkStatus;
