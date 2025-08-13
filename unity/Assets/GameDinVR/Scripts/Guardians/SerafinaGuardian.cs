using UnityEngine;

/// <summary>
/// Serafina represents communications; she relays blessings to ShadowFlowers
/// when invoked.
/// </summary>
public class SerafinaGuardian : GuardianBase
{
    private void Start()
    {
        GuardianName = "Serafina";
        Role = "Comms & Routing";
    }

    public override void OnMessage(string from, string message)
    {
        if (message.StartsWith("bless"))
        {
            Whisper("ShadowFlowers", "Please deliver a blessing to the hall.");
        }
    }
}
