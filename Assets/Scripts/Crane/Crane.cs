using System;
using Core;
using UnityEngine;

namespace Crane
{
    /// <summary>
    /// Crane controller
    /// </summary>
    public class Crane : MonoBehaviour
    {
        public const float CraneLength = 6;
        private const float MaxHouseAngle = 10;

        [SerializeField] private GameObject housePrefab;
        [SerializeField] private HingeJoint2D craneJoint;
        [SerializeField] private LineRenderer craneLine;
    
        private int _currentLevel;
        private House _currentHouse;

        private bool _isGameOver;

        private void Awake()
        {
            _isGameOver = false;
            _currentLevel = 0;
            SpawnHouse();
        }

        private void Update()
        {
            if (!_currentHouse.isDetached)
            {
                UpdateCraneLine();
            }
        }

        private void OnEnable()
        {
            GameManager.OnTouchTap += ReleaseHouse;
            GameManager.OnGameOver += OnGameOver;
        }

        private void OnDisable()
        {
            GameManager.OnTouchTap -= ReleaseHouse;
            GameManager.OnGameOver -= OnGameOver;
        }

        private void ReleaseHouse()
        {
            if (_currentHouse.isDetached) return;
            
            craneLine.gameObject.SetActive(false);
            
            _currentHouse.Detach();
            craneJoint.connectedBody = null;
        }

        private void DestroyHouse()
        {
            if (_currentHouse.isDetached) return;
            
            craneLine.gameObject.SetActive(false);
            
            Destroy(_currentHouse.gameObject);
            craneJoint.connectedBody = null;
            _currentHouse = null;
        }

        private void MoveUp()
        {
            if (_isGameOver) return;

            GameManager.Score ++;
            
            _currentHouse.OnTouchDown -= MoveUp;
            
            if (_currentLevel >= House.BuildingHeight) return;
            
            _currentLevel++;
            
            transform.position += new Vector3(0, 1, 0);
        
            SpawnHouse();
        }

        private void SpawnHouse()
        {
            // alternate left and right spawning position
            var houseSpawnAngle = _currentLevel % 2 == 0 ? -MaxHouseAngle : MaxHouseAngle;

            var houseSpawnDx = Mathf.Sin(Mathf.Deg2Rad * houseSpawnAngle) * CraneLength;        
            var houseSpawnDy = -Mathf.Cos(Mathf.Deg2Rad * houseSpawnAngle) * CraneLength;
            var houseSpawnPos = transform.position + new Vector3(houseSpawnDx, houseSpawnDy, 0);

            var houseSpawnRot = Quaternion.Euler(0, 0, houseSpawnAngle);

            _currentHouse = Instantiate(housePrefab, houseSpawnPos, houseSpawnRot, transform).GetComponent<House>();
            _currentHouse.SetLevel(_currentLevel);
            _currentHouse.OnTouchDown += MoveUp;
            
            craneJoint.connectedBody = _currentHouse.GetComponent<Rigidbody2D>();
            
            craneLine.gameObject.SetActive(true);
            UpdateCraneLine();
        }

        private void OnGameOver()
        {
            _isGameOver = true;

            DestroyHouse();
        }

        private void UpdateCraneLine()
        {
            craneLine.SetPositions(new []
            {
                transform.position, _currentHouse.transform.position
            });
        }
    }
}
