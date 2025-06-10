import { create } from 'zustand';

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

interface WindowStore {
  windows: Window[];
  addWindow: (window: Window) => void;
  removeWindow: (id: string) => void;
  updateWindow: (id: string, updates: Partial<Window>) => void;
}

export const useWindowStore = create<WindowStore>((set) => ({
  windows: [],
  
  addWindow: (window) => set((state) => ({
    windows: [...state.windows, window]
  })),
  
  removeWindow: (id) => set((state) => ({
    windows: state.windows.filter((window) => window.id !== id)
  })),
  
  updateWindow: (id, updates) => set((state) => ({
    windows: state.windows.map((window) =>
      window.id === id ? { ...window, ...updates } : window
    )
  }))
})); 