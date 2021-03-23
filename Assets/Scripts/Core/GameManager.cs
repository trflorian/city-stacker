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
        private const string HighscorePrefKey = "Highscore";

        [SerializeField] private bool autoStartEnabled;
        
        public event UnityAction OnTouchTap;
        public event UnityAction OnGameOver;

        public int Score { get; private set; }
        public int Highscore { get; private set; }
        
        private bool _isGameOver;
    
        private TouchControls _controls;

        private void Awake()
        {
            Highscore = PlayerPrefs.GetInt(HighscorePrefKey, 0);
            
            Reset();

            _controls = new TouchControls();
            _controls.Core.Fire.started += OnTouchScreenTap;

            if (autoStartEnabled)
            {
                StartGame();
            }
        }

        private void OnDestroy()
        {
            PlayerPrefs.SetInt(HighscorePrefKey, Highscore);
            PlayerPrefs.Save();

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
            Score = 0;
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

        public void IncreaseScore()
        {
            Score++;

            if (Score > Highscore)
            {
                Highscore = Score;
            }
        }

        public void StartGame()
        {
            _controls.Enable();
        }
    }
}
