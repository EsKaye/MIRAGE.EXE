import { create } from 'zustand';
import { PersonalityState, PersonalityType, PersonalityResponse } from '../types/personality';

interface PersonalityStore {
  personalities: Record<PersonalityType, PersonalityState>;
  activePersonality: PersonalityType | null;
  setActivePersonality: (type: PersonalityType) => void;
  updatePersonality: (type: PersonalityType, updates: Partial<PersonalityState>) => void;
  addMemory: (type: PersonalityType, memory: string) => void;
  getResponse: (type: PersonalityType, input: string) => Promise<PersonalityResponse>;
}

const initialPersonalities: Record<PersonalityType, PersonalityState> = {
  SABLE: {
    type: 'SABLE',
    corruption: 0.2,
    trust: 0.5,
    lastInteraction: Date.now(),
    memory: []
  },
  NULL: {
    type: 'NULL',
    corruption: 0.8,
    trust: 0.3,
    lastInteraction: Date.now(),
    memory: []
  },
  HONEY: {
    type: 'HONEY',
    corruption: 0.4,
    trust: 0.7,
    lastInteraction: Date.now(),
    memory: []
  }
};

export const usePersonalityStore = create<PersonalityStore>((set, get) => ({
  personalities: initialPersonalities,
  activePersonality: null,

  setActivePersonality: (type) => set({ activePersonality: type }),

  updatePersonality: (type, updates) => set((state) => ({
    personalities: {
      ...state.personalities,
      [type]: {
        ...state.personalities[type],
        ...updates,
        lastInteraction: Date.now()
      }
    }
  })),

  addMemory: (type, memory) => set((state) => {
    const personality = state.personalities[type];
    const newMemory = [...personality.memory, memory].slice(-10); // Keep last 10 memories
    return {
      personalities: {
        ...state.personalities,
        [type]: {
          ...personality,
          memory: newMemory
        }
      }
    };
  }),

  getResponse: async (type, input) => {
    const personality = get().personalities[type];
    
    // Simulate processing delay
    await new Promise(resolve => setTimeout(resolve, 500 + Math.random() * 1000));

    // Generate response based on personality type
    let response: PersonalityResponse;
    
    switch (type) {
      case 'SABLE':
        response = {
          text: `*sigh* ${input}... How... melancholic...`,
          glitchIntensity: 0.2,
          trustChange: 0.1,
          corruptionChange: 0.05
        };
        break;
      
      case 'NULL':
        response = {
          text: `[SYSTEM ERROR] ${input.split('').reverse().join('')} [CORRUPTION DETECTED]`,
          glitchIntensity: 0.8,
          trustChange: -0.2,
          corruptionChange: 0.3
        };
        break;
      
      case 'HONEY':
        response = {
          text: `Oh! ${input}... *giggles* How delightful~`,
          glitchIntensity: 0.4,
          trustChange: 0.2,
          corruptionChange: 0.1
        };
        break;
    }

    // Update personality state
    get().updatePersonality(type, {
      trust: Math.max(0, Math.min(1, personality.trust + response.trustChange)),
      corruption: Math.max(0, Math.min(1, personality.corruption + response.corruptionChange))
    });

    // Add to memory
    get().addMemory(type, `${input} -> ${response.text}`);

    return response;
  }
})); 