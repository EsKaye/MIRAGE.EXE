using UnityEngine;

/// <summary>
/// Base class for all guardians. Handles subscription to the ops bus and
/// provides a simple Whisper helper for subclasses.
/// </summary>
public class GuardianBase : MonoBehaviour
{
    [Header("Identity")]
    public string GuardianName = "Guardian";
    public string Role = "Undefined";

    protected virtual void OnEnable()
    {
        if (LilybearOpsBus.I != null)
            LilybearOpsBus.I.OnWhisper += HandleWhisper;
    }

    protected virtual void OnDisable()
    {
        if (LilybearOpsBus.I != null)
            LilybearOpsBus.I.OnWhisper -= HandleWhisper;
    }

    protected virtual void HandleWhisper(string from, string to, string message)
    {
        if (to == GuardianName || to == "*")
        {
            Debug.Log($"[{GuardianName}] received from {from}: {message}");
            OnMessage(from, message);
        }
    }

    /// <summary>
    /// Override to implement guardian-specific reactions.
    /// </summary>
    public virtual void OnMessage(string from, string message) { }

    protected void Whisper(string to, string message)
    {
        LilybearOpsBus.I?.Say(GuardianName, to, message);
    }
}
