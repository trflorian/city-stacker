using System;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

namespace UI
{
    /// <summary>
    /// Button that restarts the game
    /// </summary>
    public class RestartGameButton : MonoBehaviour
    {
        private Button _button;
        
        private void Awake()
        {
            _button = GetComponent<Button>();
            _button.onClick.AddListener(RestartGame);
        }

        private void OnDestroy()
        {
            _button.onClick.RemoveListener(RestartGame);
        }

        private void RestartGame()
        {
            SceneManager.LoadSceneAsync("StackerScene");
        }
    }
}
