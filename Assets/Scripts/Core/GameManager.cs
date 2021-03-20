using UnityEngine;
using UnityEngine.Events;
using UnityEngine.InputSystem;

namespace Core
{
    /// <summary>
    /// Core game manager
    /// </summary>
    public class GameManager : MonoBehaviour
    {
        public static event UnityAction OnTouchTap;
        public static event UnityAction OnGameOver;

        public static int Score;
    
        private TouchControls _controls;

        private static bool _isGameOver;

        private void Awake()
        {
            Score = 0;
            _isGameOver = false;
            
            _controls = new TouchControls();

            _controls.Core.Fire.started += OnTouchScreenTap;
            _controls.Enable();
        }

        private void OnDestroy()
        {
            _controls.Core.Fire.started -= OnTouchScreenTap;
            _controls.Disable();
        }

        private void OnTouchScreenTap(InputAction.CallbackContext ctx)
        {
            OnTouchTap?.Invoke();
        }

        public static void CallGameOver()
        {
            // dont call game over event a second time
            if (_isGameOver) return;
            
            _isGameOver = true;
            
            OnGameOver?.Invoke();
        }
    }
}
