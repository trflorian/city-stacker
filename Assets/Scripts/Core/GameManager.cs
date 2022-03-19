using Crane;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using UnityEngine.InputSystem;

namespace Core
{
    /// <summary>
    /// Core game manager
    /// </summary>
    public class GameManager : MonoBehaviour
    {
        private const string HighScorePrefKey = "Highscore";

        [SerializeField] private bool autoStartEnabled;
        
        public event UnityAction OnTouchTap;
        public event UnityAction OnGameOver;

        public int Score { get; private set; }
        public int HighScore { get; private set; }
        
        private bool _isGameOver;
    
        private TouchControls _controls;
        public int houseColorId;

        private void Awake()
        {
            HighScore = PlayerPrefs.GetInt(HighScorePrefKey, 0);
            
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
            PlayerPrefs.SetInt(HighScorePrefKey, HighScore);
            PlayerPrefs.Save();

            _controls.Core.Fire.started -= OnTouchScreenTap;
            _controls.Disable();
        }

        private void OnTouchScreenTap(InputAction.CallbackContext ctx)
        {
            if (!EventSystem.current.IsPointerOverGameObject())
            {
                OnTouchTap?.Invoke();
            }
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
            houseColorId = Random.Range(0, House.MaxColors);
            
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

            if (Score > HighScore)
            {
                HighScore = Score;
            }
        }

        public void StartGame()
        {
            _controls.Enable();
        }
    }
}
