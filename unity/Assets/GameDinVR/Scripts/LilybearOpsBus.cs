using UnityEngine;

/// <summary>
/// Simple in-scene event bus allowing guardians to whisper to each other.
/// </summary>
public class LilybearOpsBus : MonoBehaviour
{
    public static LilybearOpsBus I;

    private void Awake()
    {
        I = this; // singleton-style instance for easy access
    }

    public delegate void Whisper(string from, string to, string message);
    public event Whisper OnWhisper;

    /// <summary>
    /// Broadcast a message across the bus.
    /// </summary>
    public void Say(string from, string to, string message)
    {
        OnWhisper?.Invoke(from, to, message);
        Debug.Log($"[LilybearBus] {from} → {to}: {message}");
    }
}
