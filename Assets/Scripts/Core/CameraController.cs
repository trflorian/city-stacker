using System;
using DG.Tweening;
using UnityEngine;

namespace Core
{
    /// <summary>
    /// Control camera to follow crane
    /// </summary>
    public class CameraController : MonoBehaviour
    {
        private const float CraneCameraOffset = 1.5f;
        private const float GameOverZoomTime = 1;
        
        [SerializeField] private GameManager gameManager;
        [SerializeField] private GameObject crane;

        private Camera _camera;
        
        private bool _isGameOver;

        private void Awake()
        {
            _camera = GetComponent<Camera>();
            
            _isGameOver = false;
            
            gameManager.OnGameOver += OnGameOver;
        }

        private void OnDestroy()
        {
            gameManager.OnGameOver -= OnGameOver;
        }

        private void Update()
        {
            if (_isGameOver) return;

            FocusOnCrane();
        }

        private void FocusOnCrane()
        {
            var offset = Vector3.down * (Crane.Crane.CraneLength + CraneCameraOffset);
            var targetPosition = crane.transform.position + offset;
            targetPosition.z = transform.position.z;
            transform.position = Vector3.Lerp(transform.position, targetPosition, Time.deltaTime * 3f);
        }

        private void OnGameOver()
        {
            _isGameOver = true;

            var reachedHeight = transform.position.y;
            transform.DOMoveY(reachedHeight / 2f, GameOverZoomTime);
            _camera.DOOrthoSize(5+reachedHeight, GameOverZoomTime);
        }
    }
}
