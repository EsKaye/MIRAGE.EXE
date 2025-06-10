import { create } from 'zustand';

interface CorruptionStore {
  corruptionLevel: number;
  setCorruptionLevel: (level: number) => void;
  increaseCorruption: (amount: number) => void;
  decreaseCorruption: (amount: number) => void;
}

export const useCorruptionStore = create<CorruptionStore>((set) => ({
  corruptionLevel: 0,
  
  setCorruptionLevel: (level) => set(() => ({
    corruptionLevel: Math.max(0, Math.min(1, level))
  })),
  
  increaseCorruption: (amount) => set((state) => ({
    corruptionLevel: Math.min(1, state.corruptionLevel + amount)
  })),
  
  decreaseCorruption: (amount) => set((state) => ({
    corruptionLevel: Math.max(0, state.corruptionLevel - amount)
  }))
})); 