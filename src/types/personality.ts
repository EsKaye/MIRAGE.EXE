export type PersonalityType = 'SABLE' | 'NULL' | 'HONEY';

export interface PersonalityState {
  type: PersonalityType;
  corruption: number;
  trust: number;
  lastInteraction: number;
  memory: string[];
}

export interface PersonalityResponse {
  text: string;
  audio?: string;
  glitchIntensity: number;
  trustChange: number;
  corruptionChange: number;
}

export interface PersonalityConfig {
  type: PersonalityType;
  baseTrust: number;
  baseCorruption: number;
  memoryCapacity: number;
  responseDelay: number;
  glitchChance: number;
} 