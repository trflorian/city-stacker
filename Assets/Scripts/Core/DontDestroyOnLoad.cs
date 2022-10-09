using UnityEngine;

namespace Core
{
    /// <summary>
    /// Dont destroy this object
    /// </summary>
    public class DontDestroyOnLoad : MonoBehaviour
    {
        private static bool _isInstanced;
        
        private void Awake()
        {
            if (_isInstanced)
            {
                Destroy(gameObject);
                return;
            }
            
            _isInstanced = true;
            
            DontDestroyOnLoad(gameObject);
        }
    }
}
