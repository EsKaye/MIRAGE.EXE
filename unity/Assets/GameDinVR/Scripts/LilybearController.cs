using UnityEngine;

/// <summary>
/// Lilybear acts as the voice & operations hub, routing commands and logging
/// the last received message for debugging.
/// </summary>
public class LilybearController : GuardianBase
{
    [TextArea]
    public string LastMessage;

    private void Start()
    {
        GuardianName = "Lilybear";
        Role = "Voice & Operations";
    }

    public override void OnMessage(string from, string message)
    {
        LastMessage = $"{from}: {message}";

        // Example command: "/route <msg>" broadcasts to all guardians.
        if (message.StartsWith("/route "))
        {
            var payload = message.Substring(7);
            Whisper("*", payload);
        }
    }

    [ContextMenu("Test Whisper")]
    private void TestWhisper()
    {
        Whisper("*", "The council is assembled.");
    }
}
