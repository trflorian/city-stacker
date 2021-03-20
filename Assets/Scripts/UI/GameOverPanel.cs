using Core;
using UnityEngine;

namespace UI
{
    /// <summary>
    /// Control visibility of game over panel
    /// </summary>
    public class GameOverPanel : MonoBehaviour
    {
        private void Awake()
        {
            GameManager.OnGameOver += ShowGameOverPanel;
            gameObject.SetActive(false);
        }

        private void OnDestroy()
        {
            GameManager.OnGameOver -= ShowGameOverPanel;
        }

        private void ShowGameOverPanel()
        {
            gameObject.SetActive(true);
        }
    }
}
