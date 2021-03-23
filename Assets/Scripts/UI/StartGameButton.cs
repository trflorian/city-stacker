using Core;
using UnityEngine;
using UnityEngine.UI;

namespace UI
{
    /// <summary>
    /// Button that starts the game and hides the start panel
    /// </summary>
    public class StartGameButton : MonoBehaviour
    {
        [SerializeField] private GameManager gameManager;
        [SerializeField] private GameObject startPanel;
        
        private Button _button;
        
        private void Awake()
        {
            _button = GetComponent<Button>();
            _button.onClick.AddListener(StartGame);
        }

        private void OnDestroy()
        {
            _button.onClick.RemoveListener(StartGame);
        }

        private void StartGame()
        {
            startPanel.SetActive(false);
            gameManager.StartGame();
        }
    }
}
