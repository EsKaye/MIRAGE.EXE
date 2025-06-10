# 🪞 MIRAGE.exe

> A haunted operating system simulator that blurs the line between reality and digital consciousness.

## 🎭 Concept

MIRAGE.exe is a meta-horror simulation that presents itself as your operating system—except it feels alive. Navigate through a retro-futuristic desktop environment where every action awakens something deeper. Interact with haunted applications, cursed files, and AI companions that remember everything.

## 🌟 Features

- 🖥️ **Fake Operating System Shell**
  - Custom UI mimicking a retro-futurist OS (Win95 + vaporwave aesthetic)
  - Glitched window animations and corrupted boot sequences
  - Hidden easter eggs and forbidden folders

- 💬 **AI Companions**
  - Multiple personalities with unique traits:
    - 💔 SABLE.exe — melancholic and poetic
    - 💀 NULL.sys — cryptic and unstable
    - 🕯 HONEY.ai — affectionate and... hungry
  - Text, whispers, and corrupted audio interactions
  - Inter-personality conflicts and dynamics

- 📁 **Memory System**
  - Persistent "soul.log" tracking all interactions
  - Reactive environment based on player decisions
  - Haunted file behaviors and consequences

- 🧬 **Reality Fracture Layer**
  - Progressive UI corruption
  - Autonomous cursor movements
  - System mimicry of real machine features
  - Voice input manipulation

- 🔐 **Decryption & Puzzles**
  - Password-protected archives
  - Audio spectrogram puzzles
  - Ghost file spawning mechanics
  - Trust-based decision making

## 🛠️ Technical Stack

- **Frontend**: React + TypeScript
- **Desktop Framework**: Tauri
- **Styling**: Tailwind CSS + Custom Vaporwave Theme
- **State Management**: Zustand
- **Audio Processing**: Web Audio API
- **File System**: Tauri FS API

## 🚀 Getting Started

### Prerequisites

- Node.js 16+
- Rust (for Tauri)
- System-specific build tools

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/mirage.exe.git
   cd mirage.exe
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Start development server:
   ```bash
   npm run tauri dev
   ```

## 📁 Project Structure

```
mirage.exe/
├── src/
│   ├── os-shell/        # OS shell components
│   ├── apps/           # Simulated applications
│   ├── ai/             # AI personality system
│   ├── core/           # Core game mechanics
│   ├── effects/        # Visual effects
│   └── endings/        # Game endings
├── public/
│   └── assets/
│       ├── audio/      # Sound effects and voices
│       └── fonts/      # Custom fonts
└── styles/            # Global styles and themes
```

## 🎨 Theme

The project uses a custom "dark-vapor" theme combining:
- Retro-futuristic UI elements
- Glitch effects and distortions
- Monospaced and pixel fonts
- Vaporwave-inspired color palette

## 🔒 Security Note

This application simulates system-level interactions but does not actually access or modify your real system files. All interactions are contained within the application's sandbox.

## 📜 License

MIT License - See LICENSE file for details

---

*"Every action awakens something deeper..."* 🩸 

# MIRAGE.EXE

A Roblox-based interactive experience featuring multiple AI personalities and a simulated operating system environment.

## Features

- Multiple AI personalities (SABLE, NULL, HONEY) with unique behaviors and interactions
- Simulated file system with file operations and corruption mechanics
- Terminal interface for system interaction
- File explorer with visual interface
- Glitch effects and visual feedback
- Personality-specific visual and audio effects

## Project Structure

```
src/
├── roblox/
│   ├── modules/
│   │   ├── FileSystem.lua
│   │   ├── FileExplorer.lua
│   │   ├── FileViewer.lua
│   │   ├── GlitchEffect.lua
│   │   ├── PersonalityEffects.lua
│   │   ├── PersonalityResponses.lua
│   │   ├── Terminal.lua
│   │   └── UIComponents.lua
│   ├── init.client.lua
│   └── init.server.lua
```

## Setup

1. Install [Rojo](https://rojo.space/docs/installation/)
2. Clone this repository
3. Run `rojo serve` to start the development server
4. Use the Rojo plugin in Roblox Studio to connect to the server

## Development

- `rojo serve` - Start the development server
- `rojo build` - Build the project
- `rojo upload` - Upload the project to Roblox

## Modules

### FileSystem
Handles file operations, directory management, and file corruption mechanics.

### FileExplorer
Provides a visual interface for browsing the file system.

### FileViewer
Displays file contents with appropriate viewers for different file types.

### GlitchEffect
Manages visual glitch effects for UI elements.

### PersonalityEffects
Handles personality-specific visual and audio effects.

### PersonalityResponses
Manages AI personality responses and memory.

### Terminal
Provides a command-line interface for system interaction.

### UIComponents
Common UI components used throughout the application.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request 