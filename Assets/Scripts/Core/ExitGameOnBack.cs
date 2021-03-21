using UnityEngine;
using UnityEngine.InputSystem;

namespace Core
{
    /// <summary>
    /// Exits the game if the escape key is pressed or the back button on android
    /// </summary>
    public class ExitGameOnBack : MonoBehaviour
    {
        private void Update()
        {
            if (Keyboard.current.escapeKey.wasPressedThisFrame)
            {
                Application.Quit();
            }
        }
    }
}
