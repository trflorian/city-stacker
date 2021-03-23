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
        public event UnityAction OnTouchTap;
        public event UnityAction OnGameOver;

        public int score;
        
        private bool _isGameOver;
    
        private TouchControls _controls;

        private void Awake()
        {
            Reset();
            
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

        public void CallGameOver()
        {
            // dont call game over event a second time
            if (_isGameOver) return;
            
            _isGameOver = true;
            
            OnGameOver?.Invoke();
        }

        public void Reset()
        {
            score = 0;
            _isGameOver = false;

            for (int i = transform.childCount-1; i >= 0; i--)
            {
                Destroy(transform.GetChild(i).gameObject);
            }
        }

        public void Tap()
        {
            OnTouchTap?.Invoke();
        }
    }
}
