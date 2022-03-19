using System;
using System.Collections.Generic;
using Core;
using UnityEngine;

namespace UI
{
    /// <summary>
    /// Show title screen before first tap 
    /// </summary>
    public class TitleScreenManager : MonoBehaviour
    {
        public static bool started;

        [SerializeField] private GameManager gameManager;
        [SerializeField] private List<GameObject> titleScreenUi;
        [SerializeField] private List<GameObject> gameUiToHideBeforeStart;

        private void Awake()
        {
            gameManager.OnTouchTap += OnTap;
        }

        private void Start()
        {
            SetShowInGameState();
        }

        private void OnDestroy()
        {
            gameManager.OnTouchTap -= OnTap;
        }

        private void OnTap()
        {
            // only check first tap
            if (started) return;
            started = true;

            SetShowInGameState();
        }

        private void SetShowInGameState()
        {
            // hide tile screen ui
            foreach (var go in titleScreenUi)
            {
                go.SetActive(!started);
            }
            
            // show in-game ui
            foreach (var go in gameUiToHideBeforeStart)
            {
                go.SetActive(started);
            }
        }
    }
}
