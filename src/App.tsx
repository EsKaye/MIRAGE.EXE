import React, { useEffect, Suspense, lazy } from 'react';
import { WindowManager } from './os-shell/WindowManager';
import { useCorruptionStore } from './store/corruptionStore';
import { useWindowStore } from './store/windowStore';
import { PersonalityWindow } from './components/PersonalityWindow';
import NetworkProvider from './network/NetworkProvider';
import NetworkStatus from './components/NetworkStatus';
import './styles/dark-vapor.css';
import './styles/personality.css';
import './styles/network.css';

// Lazy load heavy components
const LazyPersonalityWindow = lazy(() => import('./components/PersonalityWindow'));

const AppContent: React.FC = () => {
  const { increaseCorruption } = useCorruptionStore();
  const { addWindow } = useWindowStore();
  
  // Initialize the haunted OS
  useEffect(() => {
    // Add initial windows
    addWindow({
      id: 'welcome',
      title: 'WELCOME.exe',
      type: 'app',
      position: { x: 100, y: 100 },
      size: { width: 500, height: 400 },
      isMinimized: false,
      isFocused: true,
      content: (
        <div className="welcome-content p-4">
          <h1 className="glitch text-4xl font-bold mb-4" data-text="MIRAGE.exe">
            MIRAGE.exe
          </h1>
          <p className="mb-4">A haunted operating system that remembers...</p>
          <div className="network-info bg-gray-900 bg-opacity-50 p-3 rounded-md">
            <h3 className="text-lg font-semibold mb-2">Network Status</h3>
            <p className="text-sm mb-1">Divina-L3: <span className="text-blue-400">Initializing...</span></p>
            <p className="text-sm">GameDin: <span className="text-purple-400">Ready</span></p>
          </div>
        </div>
      )
    });

    // Add personality windows
    addWindow({
      id: 'sable',
      title: 'SABLE.exe',
      type: 'app',
      position: { x: 150, y: 150 },
      size: { width: 600, height: 500 },
      isMinimized: false,
      isFocused: false,
      content: (
        <Suspense fallback={<div className="p-4">Loading personality module...</div>}>
          <LazyPersonalityWindow type="SABLE" />
        </Suspense>
      )
    });

    addWindow({
      id: 'null',
      title: 'NULL.sys',
      type: 'app',
      position: { x: 200, y: 200 },
      size: { width: 500, height: 400 },
      isMinimized: false,
      isFocused: false,
      content: <PersonalityWindow type="NULL" />
    });

    addWindow({
      id: 'honey',
      title: 'HONEY.ai',
      type: 'app',
      position: { x: 250, y: 250 },
      size: { width: 500, height: 400 },
      isMinimized: false,
      isFocused: false,
      content: <PersonalityWindow type="HONEY" />
    });

    // 🎵 Initialize audio context for whispers
    const audioContext = new (window.AudioContext || (window as any).webkitAudioContext)();
    
    // 🧬 Start corruption timer
    const corruptionInterval = setInterval(() => {
      if (Math.random() > 0.7) {
        increaseCorruption(0.1);
      }
    }, 5000);

    return () => {
      clearInterval(corruptionInterval);
      audioContext.close();
    };
  }, []);

  return (
    <div className="app">
      <WindowManager />
    </div>
  );
}; 