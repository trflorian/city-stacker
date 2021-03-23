using System;
using Core;
using TMPro;
using UnityEngine;

namespace UI
{
    /// <summary>
    /// Display highscore text
    /// </summary>
    public class HighScoreUI : MonoBehaviour
    {
        [SerializeField] private GameManager gameManager;
        
        private TMP_Text _scoreText;

        private void Awake()
        {
            _scoreText = GetComponent<TMP_Text>();
        }

        private void Update()
        {
            _scoreText.SetText($"High Score: {gameManager.HighScore}");
        }
    }
}
