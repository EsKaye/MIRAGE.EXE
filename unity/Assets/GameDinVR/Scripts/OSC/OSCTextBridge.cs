using UnityEngine;

/// <summary>
/// Placeholder for OSC integration. Exposes a method so external bridges can
/// update a TextMesh via Unity's scripting API.
/// </summary>
public class OSCTextBridge : MonoBehaviour
{
    public TextMesh Target;

    public void SetText(string text)
    {
        if (Target != null)
            Target.text = text;
    }
}
