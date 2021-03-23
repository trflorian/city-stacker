using System;
using Core;
using TMPro;
using UnityEngine;

namespace UI
{
    /// <summary>
    /// Display score text
    /// </summary>
    public class ScoreUI : MonoBehaviour
    {
        [SerializeField] private GameManager gameManager;
        
        private TMP_Text _scoreText;

        private void Awake()
        {
            _scoreText = GetComponent<TMP_Text>();
        }

        private void Update()
        {
            _scoreText.SetText($"Score: {gameManager.score}");
        }
    }
}
