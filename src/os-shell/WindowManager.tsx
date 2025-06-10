import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { useWindowStore } from '../store/windowStore';
import { useCorruptionStore } from '../store/corruptionStore';
import { GlitchOverlay } from '../effects/GlitchOverlay';

interface Window {
  id: string;
  title: string;
  type: 'file' | 'terminal' | 'app';
  position: { x: number; y: number };
  size: { width: number; height: number };
  isMinimized: boolean;
  isFocused: boolean;
  content: React.ReactNode;
}

export const WindowManager: React.FC = () => {
  const { windows, addWindow, removeWindow, updateWindow } = useWindowStore();
  const { corruptionLevel } = useCorruptionStore();
  const [isDragging, setIsDragging] = useState(false);
  const [activeWindow, setActiveWindow] = useState<string | null>(null);

  // 🎭 Window drag handlers
  const handleDragStart = (windowId: string) => {
    setIsDragging(true);
    setActiveWindow(windowId);
    updateWindow(windowId, { isFocused: true });
  };

  const handleDragEnd = () => {
    setIsDragging(false);
  };

  // 🖥️ Window focus management
  const handleWindowClick = (windowId: string) => {
    setActiveWindow(windowId);
    updateWindow(windowId, { isFocused: true });
  };

  // 🪟 Window animations
  const windowVariants = {
    initial: { scale: 0.8, opacity: 0 },
    animate: { scale: 1, opacity: 1 },
    exit: { scale: 0.8, opacity: 0 },
    minimized: { scale: 0.5, opacity: 0.5, y: '100vh' }
  };

  return (
    <div className="window-manager">
      <GlitchOverlay intensity={corruptionLevel} />
      
      <AnimatePresence>
        {windows.map((window) => (
          <motion.div
            key={window.id}
            className={`window ${window.isFocused ? 'focused' : ''}`}
            style={{
              position: 'absolute',
              left: window.position.x,
              top: window.position.y,
              width: window.size.width,
              height: window.size.height,
              zIndex: window.isFocused ? 100 : 1
            }}
            variants={windowVariants}
            initial="initial"
            animate={window.isMinimized ? 'minimized' : 'animate'}
            exit="exit"
            drag
            dragMomentum={false}
            onDragStart={() => handleDragStart(window.id)}
            onDragEnd={handleDragEnd}
            onClick={() => handleWindowClick(window.id)}
          >
            {/* 🎨 Window Header */}
            <div className="window-header">
              <div className="window-title">
                <span className={corruptionLevel > 0.5 ? 'glitch' : ''}>
                  {window.title}
                </span>
              </div>
              <div className="window-controls">
                <button
                  className="window-control minimize"
                  onClick={() => updateWindow(window.id, { isMinimized: true })}
                >
                  _
                </button>
                <button
                  className="window-control maximize"
                  onClick={() => updateWindow(window.id, { isMinimized: false })}
                >
                  □
                </button>
                <button
                  className="window-control close"
                  onClick={() => removeWindow(window.id)}
                >
                  ×
                </button>
              </div>
            </div>

            {/* 📦 Window Content */}
            <div className="window-content">
              {window.content}
            </div>
          </motion.div>
        ))}
      </AnimatePresence>

      {/* 📱 Taskbar */}
      <div className="taskbar">
        {windows.map((window) => (
          <button
            key={window.id}
            className={`taskbar-item ${window.isFocused ? 'active' : ''}`}
            onClick={() => {
              if (window.isMinimized) {
                updateWindow(window.id, { isMinimized: false });
              }
              handleWindowClick(window.id);
            }}
          >
            {window.title}
          </button>
        ))}
      </div>
    </div>
  );
}; 