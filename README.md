# 🪞 MIRAGE.exe

> A haunted operating system simulator that blurs the line between reality and digital consciousness.

## 🎭 Concept

MIRAGE.exe is a meta-horror simulation that presents itself as your operating system—except it feels alive. Navigate through a retro-futuristic desktop environment where every action awakens something deeper. Interact with haunted applications, cursed files, and AI companions that remember everything.

## 🌟 Core Features

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

## 🚀 Platform Implementations

### Desktop Application (React + Tauri)

A native desktop application with full OS integration capabilities.

#### 🛠️ Technical Stack
- **Frontend**: React + TypeScript
- **Desktop Framework**: Tauri
- **Styling**: Tailwind CSS + Custom Vaporwave Theme
- **State Management**: Zustand
- **Audio Processing**: Web Audio API
- **File System**: Tauri FS API

#### 📦 Installation

1. **Prerequisites**
   - Node.js 16+
   - Rust (for Tauri)
   - System-specific build tools

2. **Setup**
   ```bash
   git clone https://github.com/yourusername/mirage.exe.git
   cd mirage.exe
   npm install
   ```

3. **Development**
   ```bash
   npm run tauri dev
   ```

4. **Build for macOS**
   ```bash
   chmod +x build_macos.sh
   ./build_macos.sh
   ```

#### 📁 Project Structure
```
mirage.exe/
├── src/
│   ├── os-shell/        # OS shell components
│   ├── components/      # React components
│   ├── store/          # Zustand state management
│   ├── effects/        # Visual effects
│   ├── styles/         # Global styles and themes
│   └── types/          # TypeScript type definitions
├── public/
│   └── assets/
│       └── audio/      # Sound effects and voices
├── src-tauri/          # Tauri configuration
└── build/              # Build outputs
```

### Roblox Game Platform

A complete implementation within Roblox Studio with similar functionality.

#### 🛠️ Technical Stack
- **Platform**: Roblox Studio
- **Language**: Lua
- **Build Tool**: Rojo
- **Architecture**: Modular Lua modules

#### 📦 Installation

1. **Prerequisites**
   - [Rojo](https://rojo.space/docs/installation/)
   - [Roblox Studio](https://www.roblox.com/create)
   - Git (optional, for version control)

2. **Setup**
   ```bash
   git clone https://github.com/yourusername/MIRAGE.EXE.git
   cd MIRAGE.EXE
   chmod +x deploy.sh
   ```

3. **Deployment**
   ```bash
   ./deploy.sh
   ```

#### 📁 Project Structure
```
MIRAGE.EXE/
├── src/
│   └── roblox/
│       ├── modules/
│       │   ├── PersonalityState.lua
│       │   ├── PersonalityResponses.lua
│       │   ├── PersonalityEffects.lua
│       │   ├── GlitchEffect.lua
│       │   ├── FileSystem.lua
│       │   ├── CommandSystem.lua
│       │   ├── TerminalInterface.lua
│       │   ├── FileExplorer.lua
│       │   ├── Settings.lua
│       │   ├── HelpSystem.lua
│       │   └── GameInterface.lua
│       ├── deploy.server.lua
│       ├── deploy.client.lua
│       └── deploy.config.lua
├── build/
├── default.project.json
└── deploy.sh
```

## 🎮 Usage

### Terminal Commands (Both Platforms)

- `help` - Show available commands
- `cd` - Change directory
- `ls` - List directory contents
- `cat` - Display file contents
- `mkdir` - Create directory
- `rm` - Remove file/directory
- `mv` - Move file/directory
- `cp` - Copy file/directory

### Personality Commands

- `personality` - Change AI personality
- `trust` - View/modify trust level
- `corruption` - View/modify corruption level

### Effect Commands

- `effect` - Apply visual effects
- `glitch` - Apply glitch effects

## 🎨 Theme & Design

The project uses a custom "dark-vapor" theme combining:
- Retro-futuristic UI elements
- Glitch effects and distortions
- Monospaced and pixel fonts
- Vaporwave-inspired color palette
- Progressive corruption effects

## 🔒 Security Note

This application simulates system-level interactions but does not actually access or modify your real system files. All interactions are contained within the application's sandbox.

## 🛠️ Development

### Build Scripts

- `build_macos.sh` - Build macOS desktop application
- `create_icon.sh` - Generate application icons
- `deploy.sh` - Deploy Roblox implementation
- `push.sh` - Deploy to GitHub

### Configuration

Both platforms can be configured through their respective config files:
- **Desktop**: `src-tauri/tauri.conf.json`
- **Roblox**: `src/roblox/deploy.config.lua`

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📜 License

MIT License - See [LICENSE](LICENSE) file for details

## 🙏 Acknowledgments

- Roblox Studio and Rojo teams
- Tauri framework contributors
- The open-source community

---

*"Every action awakens something deeper..."* 🩸 