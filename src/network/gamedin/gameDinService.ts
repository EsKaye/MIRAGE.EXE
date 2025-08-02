import { io, Socket } from 'socket.io-client';
import { GameRoom, Player } from './gameDinStore';

interface GameAction {
  type: string;
  data: any;
  timestamp: number;
  playerId: string;
}

interface GameDinServiceEvents {
  onConnected: () => void;
  onDisconnected: () => void;
  onRoomList: (rooms: GameRoom[]) => void;
  onRoomJoined: (room: GameRoom) => void;
  onRoomLeft: () => void;
  onPlayerJoined: (player: Player) => void;
  onPlayerLeft: (playerId: string) => void;
  onPlayerReady: (playerId: string, isReady: boolean) => void;
  onGameStateUpdate: (gameState: any) => void;
  onChatMessage: (message: { player: string; text: string; timestamp: number }) => void;
  onError: (error: { code: string; message: string }) => void;
}

export class GameDinService {
  private socket: Socket | null = null;
  private eventHandlers: Partial<GameDinServiceEvents> = {};
  private isConnecting = false;
  private reconnectAttempts = 0;
  private maxReconnectAttempts = 5;
  private reconnectDelay = 1000; // 1 second

  constructor() {
    this.connect = this.connect.bind(this);
    this.disconnect = this.disconnect.bind(this);
    this.handleConnect = this.handleConnect.bind(this);
    this.handleDisconnect = this.handleDisconnect.bind(this);
  }

  // Set up event listeners
  on<E extends keyof GameDinServiceEvents>(
    event: E,
    handler: GameDinServiceEvents[E]
  ): void {
    this.eventHandlers[event] = handler;
  }

  // Connect to the GameDin server
  connect(playerName: string): void {
    if (this.socket?.connected || this.isConnecting) return;

    this.isConnecting = true;
    this.reconnectAttempts = 0;

    try {
      // Use environment variable or default to localhost
      const serverUrl = process.env.REACT_APP_GAMEDIN_SERVER || 'ws://localhost:3001';
      
      this.socket = io(serverUrl, {
        query: { playerName },
        reconnectionAttempts: this.maxReconnectAttempts,
        reconnectionDelay: this.reconnectDelay,
        autoConnect: true,
      });

      // Set up socket event listeners
      this.socket.on('connect', this.handleConnect);
      this.socket.on('disconnect', this.handleDisconnect);
      this.socket.on('connect_error', (error) => {
        console.error('Connection error:', error);
        this.isConnecting = false;
        this.eventHandlers.onError?.({
          code: 'CONNECTION_ERROR',
          message: 'Failed to connect to game server',
        });
      });

      // Game server events
      this.socket.on('roomList', (rooms: GameRoom[]) => {
        this.eventHandlers.onRoomList?.(rooms);
      });

      this.socket.on('roomJoined', (room: GameRoom) => {
        this.eventHandlers.onRoomJoined?.(room);
      });

      this.socket.on('roomLeft', () => {
        this.eventHandlers.onRoomLeft?.();
      });

      this.socket.on('playerJoined', (player: Player) => {
        this.eventHandlers.onPlayerJoined?.(player);
      });

      this.socket.on('playerLeft', (playerId: string) => {
        this.eventHandlers.onPlayerLeft?.(playerId);
      });

      this.socket.on('playerReady', (data: { playerId: string; isReady: boolean }) => {
        this.eventHandlers.onPlayerReady?.(data.playerId, data.isReady);
      });

      this.socket.on('gameState', (gameState: any) => {
        this.eventHandlers.onGameStateUpdate?.(gameState);
      });

      this.socket.on('chatMessage', (message: { player: string; text: string; timestamp: number }) => {
        this.eventHandlers.onChatMessage?.(message);
      });

      this.socket.on('error', (error: { code: string; message: string }) => {
        console.error('Game server error:', error);
        this.eventHandlers.onError?.(error);
      });

    } catch (error) {
      console.error('Error connecting to GameDin server:', error);
      this.isConnecting = false;
      this.eventHandlers.onError?.({
        code: 'CONNECTION_FAILED',
        message: 'Failed to initialize connection',
      });
    }
  }

  // Handle successful connection
  private handleConnect() {
    console.log('Connected to GameDin server');
    this.isConnecting = false;
    this.reconnectAttempts = 0;
    this.eventHandlers.onConnected?.();
  }

  // Handle disconnection
  private handleDisconnect() {
    console.log('Disconnected from GameDin server');
    this.isConnecting = false;
    this.eventHandlers.onDisconnected?.();
  }

  // Disconnect from the server
  disconnect(): void {
    if (this.socket) {
      this.socket.disconnect();
      this.socket = null;
    }
  }

  // Room management
  createRoom(roomName: string, maxPlayers: number, isPrivate = false): void {
    if (!this.socket?.connected) {
      this.eventHandlers.onError?.({
        code: 'NOT_CONNECTED',
        message: 'Not connected to game server',
      });
      return;
    }
    this.socket.emit('createRoom', { name: roomName, maxPlayers, isPrivate });
  }

  joinRoom(roomId: string, password?: string): void {
    if (!this.socket?.connected) {
      this.eventHandlers.onError?.({
        code: 'NOT_CONNECTED',
        message: 'Not connected to game server',
      });
      return;
    }
    this.socket.emit('joinRoom', { roomId, password });
  }

  leaveRoom(): void {
    if (this.socket?.connected) {
      this.socket.emit('leaveRoom');
    }
  }

  // Player actions
  setReady(isReady: boolean): void {
    if (this.socket?.connected) {
      this.socket.emit('playerReady', { isReady });
    }
  }

  sendChatMessage(message: string): void {
    if (this.socket?.connected) {
      this.socket.emit('chatMessage', { text: message });
    }
  }

  // Game actions
  sendGameAction(action: string, data: any): void {
    if (!this.socket?.connected) return;
    
    const gameAction: GameAction = {
      type: action,
      data,
      timestamp: Date.now(),
      playerId: this.socket.id,
    };
    
    this.socket.emit('gameAction', gameAction);
  }

  // Get current connection status
  get isConnected(): boolean {
    return this.socket?.connected || false;
  }

  // Get current player ID
  get playerId(): string | null {
    return this.socket?.id || null;
  }
}

export const gameDinService = new GameDinService();
