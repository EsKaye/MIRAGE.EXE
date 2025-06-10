# MIRAGE.EXE Development Guide

## Setup

1. Install required tools:
   ```bash
   # Install Rust and Cargo
   brew install rust

   # Install Rojo
   cargo install rojo

   # Add Cargo to PATH
   echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.zshrc
   source ~/.zshrc
   ```

2. Start development server:
   ```bash
   rojo serve --port 25069
   ```

3. In Roblox Studio:
   - Install Rojo plugin
   - Connect to `localhost:25069`

## Project Structure

```
src/
├── roblox/
│   ├── modules/
│   │   ├── FileSystem.lua      # File system operations
│   │   ├── FileExplorer.lua    # File explorer UI
│   │   ├── FileViewer.lua      # File content viewer
│   │   ├── GlitchEffect.lua    # Visual glitch effects
│   │   ├── PersonalityEffects.lua  # Personality-specific effects
│   │   ├── PersonalityResponses.lua # AI personality responses
│   │   ├── Terminal.lua        # Command-line interface
│   │   └── UIComponents.lua    # Common UI components
│   ├── init.client.lua         # Client initialization
│   └── init.server.lua         # Server initialization
```

## Development Workflow

1. **Module Development**
   - Create new modules in `src/roblox/modules/`
   - Follow existing module patterns
   - Include comprehensive documentation

2. **Testing**
   - Test in Roblox Studio
   - Verify functionality
   - Check for performance issues

3. **Version Control**
   - Use descriptive commit messages
   - Follow branching strategy
   - Review code before merging

## Coding Standards

### Lua Style Guide
- Use PascalCase for module names
- Use camelCase for function names
- Use UPPER_CASE for constants
- Include comments for complex logic
- Document public functions

### Module Structure
```lua
-- ModuleName.lua
local ModuleName = {}

-- Constants
local CONSTANTS = {
    VALUE = "value"
}

-- Private functions
local function privateFunction()
    -- Implementation
end

-- Public functions
function ModuleName.publicFunction()
    -- Implementation
end

return ModuleName
```

### Error Handling
- Use pcall for critical operations
- Provide meaningful error messages
- Log errors appropriately

## Personality System

### SABLE
- Corruption-based mechanics
- Dark theme
- Memory system

### NULL
- Aggressive behavior
- Red theme
- Infection mechanics

### HONEY
- Friendly behavior
- Gold theme
- Healing mechanics

## File System

### Operations
- Create/Delete files
- Read/Write content
- Directory management
- File corruption

### Security
- Access control
- File permissions
- Corruption prevention

## UI Components

### Windows
- Draggable
- Resizable
- Close/Minimize/Maximize

### Effects
- Glitch effects
- Personality themes
- Animations

## Testing

### Unit Tests
- Test individual functions
- Verify expected behavior
- Check edge cases

### Integration Tests
- Test module interactions
- Verify system behavior
- Check performance

## Performance

### Optimization
- Minimize memory usage
- Optimize loops
- Cache results

### Monitoring
- Track performance
- Identify bottlenecks
- Measure impact

## Security

### Best Practices
- Validate input
- Sanitize data
- Prevent exploits

### Anti-Cheat
- Verify client actions
- Prevent manipulation
- Log suspicious activity

## Documentation

### Code Documentation
- Function descriptions
- Parameter details
- Return values
- Examples

### User Documentation
- Installation guide
- Usage instructions
- Troubleshooting

## Deployment

### Preparation
- Version check
- Dependency verification
- Configuration review

### Process
- Build project
- Test thoroughly
- Deploy to production

## Maintenance

### Regular Tasks
- Update dependencies
- Fix bugs
- Optimize performance

### Monitoring
- Track issues
- Gather feedback
- Plan improvements 