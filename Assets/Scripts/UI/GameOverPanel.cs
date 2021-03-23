using Core;
using UnityEngine;

namespace UI
{
    /// <summary>
    /// Control visibility of game over panel
    /// </summary>
    public class GameOverPanel : MonoBehaviour
    {
        [SerializeField] private GameManager gameManager;
        
        private void Awake()
        {
            gameManager.OnGameOver += ShowGameOverPanel;
            gameObject.SetActive(false);
        }

        private void OnDestroy()
        {
            gameManager.OnGameOver -= ShowGameOverPanel;
        }

        private void ShowGameOverPanel()
        {
            gameObject.SetActive(true);
        }
    }
}
