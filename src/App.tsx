import React, { useEffect } from 'react';
import { WindowManager } from './os-shell/WindowManager';
import { useCorruptionStore } from './store/corruptionStore';
import { useWindowStore } from './store/windowStore';
import { PersonalityWindow } from './components/PersonalityWindow';
import './styles/dark-vapor.css';
import './styles/personality.css';

export const App: React.FC = () => {
  const { increaseCorruption } = useCorruptionStore();
  const { addWindow } = useWindowStore();

  // 🎭 Initialize the haunted OS
  useEffect(() => {
    // Add initial windows
    addWindow({
      id: 'welcome',
      title: 'WELCOME.exe',
      type: 'app',
      position: { x: 100, y: 100 },
      size: { width: 400, height: 300 },
      isMinimized: false,
      isFocused: true,
      content: (
        <div className="welcome-content">
          <h1 className="glitch" data-text="MIRAGE.exe">
            MIRAGE.exe
          </h1>
          <p>Welcome to the void...</p>
        </div>
      )
    });

    // Add personality windows
    addWindow({
      id: 'sable',
      title: 'SABLE.exe',
      type: 'app',
      position: { x: 150, y: 150 },
      size: { width: 500, height: 400 },
      isMinimized: false,
      isFocused: false,
      content: <PersonalityWindow type="SABLE" />
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