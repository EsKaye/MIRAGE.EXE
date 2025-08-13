import 'dotenv/config';
import fetch from 'node-fetch';
import {
  Client,
  GatewayIntentBits,
  REST,
  Routes,
  SlashCommandBuilder,
  SlashCommandSubcommandBuilder,
  SlashCommandSubcommandGroupBuilder,
  Interaction,
  Message
} from 'discord.js';
import { scheduleNightlyCouncilReport, sendCouncilReport } from './nightlyReport.js';
import { performHandshake } from './handshake.js';

// -----------------------------------------------------------------------------
// router.ts
//
// Bootstraps the Serafina Discord bot and wires slash commands to backend
// routines. Messages in the council channel prefixed with `!to` are relayed to
// Unity guardians via the MCP OSC bridge.
// -----------------------------------------------------------------------------

const token = process.env.DISCORD_TOKEN!; // bot token
const clientId = process.env.CLIENT_ID!; // application id
const guildId = process.env.GUILD_ID!; // target guild for commands
const councilChannel = process.env.CHN_COUNCIL!; // channel to relay guardian whispers
const mcp = process.env.MCP_URL!; // MCP base URL

// Helper to forward messages to guardians through the MCP OSC endpoint.
async function relayToGuardian(guardian: string, message: string): Promise<void> {
  try {
    await fetch(`${mcp}/osc`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ address: `/guardian/${guardian}`, value: message })
    });
  } catch (err) {
    console.error('Failed to relay to guardian', guardian, err);
  }
}

// Create Discord client with basic guild message intents.
const client = new Client({
  intents: [GatewayIntentBits.Guilds, GatewayIntentBits.GuildMessages]
});

client.once('ready', () => {
  console.log(`Serafina online as ${client.user?.tag}`);
  scheduleNightlyCouncilReport(client); // start daily report schedule
  performHandshake(); // probe sibling services
});

// Slash command handling.
client.on('interactionCreate', async (interaction: Interaction) => {
  if (!interaction.isChatInputCommand()) return;

  // `/council report now` → immediate council report
  if (
    interaction.commandName === 'council' &&
    interaction.options.getSubcommandGroup() === 'report' &&
    interaction.options.getSubcommand() === 'now'
  ) {
    await interaction.deferReply({ ephemeral: true });
    await sendCouncilReport(client);
    await interaction.editReply('Council report dispatched.');
  }
});

// Text message routing for guardian whispers.
client.on('messageCreate', async (msg: Message) => {
  if (msg.author.bot) return;
  if (msg.channelId !== councilChannel) return;
  if (!msg.content.startsWith('!to ')) return;

  const [_, guardian, ...rest] = msg.content.split(' ');
  const payload = rest.join(' ');
  await relayToGuardian(guardian, payload);
});

// Register slash commands with Discord API.
const commands = [
  new SlashCommandBuilder()
    .setName('council')
    .setDescription('Council coordination commands')
    .addSubcommandGroup((group: SlashCommandSubcommandGroupBuilder) =>
      group
        .setName('report')
        .setDescription('Council reporting utilities')
        .addSubcommand((sub: SlashCommandSubcommandBuilder) =>
          sub.setName('now').setDescription('Dispatch the council report immediately')
        )
    )
].map((c) => c.toJSON());

const rest = new REST({ version: '10' }).setToken(token);

async function main(): Promise<void> {
  try {
    await rest.put(Routes.applicationGuildCommands(clientId, guildId), { body: commands });
    await client.login(token);
  } catch (err) {
    console.error('Serafina bootstrap failure:', err);
  }
}

main();

