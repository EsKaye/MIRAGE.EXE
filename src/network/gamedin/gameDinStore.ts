import { create } from 'zustand';
import { io, Socket } from 'socket.io-client';

export interface Player {
  id: string;
  name: string;
  isHost: boolean;
  isReady: boolean;
}

export interface GameRoom {
  id: string;
  name: string;
  players: Player[];
  maxPlayers: number;
  isPrivate: boolean;
  gameState: any; // Will be typed based on game requirements
}

export interface GameDinState {
  // Connection state
  isConnected: boolean;
  isConnecting: boolean;
  socket: Socket | null;
  
  // Game state
  playerId: string | null;
  currentRoom: GameRoom | null;
  availableRooms: GameRoom[];
  
  // Actions
  connect: (playerName: string) => Promise<void>;
  disconnect: () => void;
  createRoom: (roomName: string, maxPlayers: number, isPrivate: boolean) => void;
  joinRoom: (roomId: string, password?: string) => void;
  leaveRoom: () => void;
  setReady: (isReady: boolean) => void;
  sendGameAction: (action: string, data: any) => void;
}

const GAME_DIN_SERVER = process.env.REACT_APP_GAMEDIN_SERVER || 'ws://localhost:3001';

export const useGameDinStore = create<GameDinState>((set, get) => ({
  // Initial state
  isConnected: false,
  isConnecting: false,
  socket: null,
  playerId: null,
  currentRoom: null,
  availableRooms: [],

  // Connect to GameDin server
  connect: async (playerName: string) => {
    if (get().isConnecting || get().isConnected) return;
    
    try {
      set({ isConnecting: true });
      
      const socket = io(GAME_DIN_SERVER, {
        autoConnect: true,
        query: { playerName },
      });
      
      // Set up socket event listeners
      socket.on('connect', () => {
        console.log('Connected to GameDin server');
        set({ 
          isConnected: true,
          isConnecting: false,
          socket,
          playerId: socket.id,
        });
      });
      
      socket.on('disconnect', () => {
        console.log('Disconnected from GameDin server');
        set({
          isConnected: false,
          currentRoom: null,
          availableRooms: [],
        });
      });
      
      socket.on('roomList', (rooms: GameRoom[]) => {
        set({ availableRooms: rooms });
      });
      
      socket.on('roomJoined', (room: GameRoom) => {
        set({ currentRoom: room });
      });
      
      socket.on('roomLeft', () => {
        set({ currentRoom: null });
      });
      
      socket.on('playerJoined', (player: Player) => {
        set(state => ({
          currentRoom: state.currentRoom ? {
            ...state.currentRoom,
            players: [...state.currentRoom.players, player]
          } : null
        }));
      });
      
      socket.on('playerLeft', (playerId: string) => {
        set(state => ({
          currentRoom: state.currentRoom ? {
            ...state.currentRoom,
            players: state.currentRoom.players.filter(p => p.id !== playerId)
          } : null
        }));
      });
      
      socket.on('gameStateUpdate', (gameState: any) => {
        set(state => ({
          currentRoom: state.currentRoom ? {
            ...state.currentRoom,
            gameState
          } : null
        }));
      });
      
      // Connect the socket
      socket.connect();
      
    } catch (error) {
      console.error('Failed to connect to GameDin server:', error);
      set({ isConnecting: false });
      throw error;
    }
  },
  
  // Disconnect from GameDin server
  disconnect: () => {
    const { socket } = get();
    if (socket) {
      socket.disconnect();
    }
    set({
      isConnected: false,
      socket: null,
      playerId: null,
      currentRoom: null,
      availableRooms: [],
    });
  },
  
  // Create a new game room
  createRoom: (roomName: string, maxPlayers: number, isPrivate: boolean = false) => {
    const { socket } = get();
    if (socket && socket.connected) {
      socket.emit('createRoom', { name: roomName, maxPlayers, isPrivate });
    }
  },
  
  // Join an existing game room
  joinRoom: (roomId: string, password?: string) => {
    const { socket } = get();
    if (socket && socket.connected) {
      socket.emit('joinRoom', { roomId, password });
    }
  },
  
  // Leave the current room
  leaveRoom: () => {
    const { socket } = get();
    if (socket && socket.connected) {
      socket.emit('leaveRoom');
    }
  },
  
  // Toggle player ready status
  setReady: (isReady: boolean) => {
    const { socket } = get();
    if (socket && socket.connected) {
      socket.emit('playerReady', { isReady });
    }
  },
  
  // Send a game action to the server
  sendGameAction: (action: string, data: any) => {
    const { socket } = get();
    if (socket && socket.connected) {
      socket.emit('gameAction', { action, data });
    }
  },
}));
