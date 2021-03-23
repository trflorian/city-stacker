using System;
using Core;
using UnityEngine;
using UnityEngine.Events;
using Random = UnityEngine.Random;

namespace Crane
{
    /// <summary>
    /// Crane controller
    /// </summary>
    public class Crane : MonoBehaviour
    {
        public event UnityAction<int> OnScoreIncreased;
        
        public const float CraneLength = 6;
        private const float MaxHouseAngle = 10;

        [SerializeField] private GameManager gameManager;
        [SerializeField] private GameObject housePrefab;
        [SerializeField] private HingeJoint2D craneJoint;
        [SerializeField] private LineRenderer craneLine;

        private float _previousVelocityX;
        private int _currentLevel, _swingCount;
        private House _currentHouse, _previousHouse;

        public Vector2 GetCurrentHousePos() =>
            _currentHouse == null
                ? new Vector2(0, 0)
                : new Vector2(_currentHouse.transform.localPosition.x,
                    _currentHouse.transform.localPosition.y);
        public Vector2 GetPreviousHousePos()  =>
            _previousHouse == null
                ? new Vector2(0, 0)
                : new Vector2(_previousHouse.transform.localPosition.x,
                    _previousHouse.transform.localPosition.y);

        private bool _isGameOver;

        private void Awake()
        {
            Reset();
        }

        private void Update()
        {
            if (_currentHouse != null && !_currentHouse.isDetached)
            {
                UpdateCraneLine();

                var newVelocityX = _currentHouse.GetVelocityX();
                if (newVelocityX > 0 && _previousVelocityX <= 0 || newVelocityX < 0 && _previousVelocityX >= 0)
                {
                    _swingCount++;
                }
                _previousVelocityX = newVelocityX;
            }
        }

        private void OnEnable()
        {
            gameManager.OnTouchTap += ReleaseHouse;
            gameManager.OnGameOver += OnGameOver;
        }

        private void OnDisable()
        {
            gameManager.OnTouchTap -= ReleaseHouse;
            gameManager.OnGameOver -= OnGameOver;
        }

        private void ReleaseHouse()
        {
            if (_currentHouse == null || _currentHouse.isDetached) return;
            
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

            OnScoreIncreased?.Invoke(_swingCount);
            gameManager.score ++;
            
            _currentHouse.OnTouchDown -= MoveUp;
            
            if (_currentLevel >= House.BuildingHeight) return;
            
            _currentLevel++;
            
            transform.position += new Vector3(0, 1, 0);
        
            SpawnHouse();
        }

        private void SpawnHouse()
        {
            // alternate left and right spawning position
            var houseSpawnAngle = Random.Range(-MaxHouseAngle, MaxHouseAngle);//_currentLevel % 2 == 0 ? -MaxHouseAngle : MaxHouseAngle;

            var houseSpawnDx = Mathf.Sin(Mathf.Deg2Rad * houseSpawnAngle) * CraneLength;        
            var houseSpawnDy = -Mathf.Cos(Mathf.Deg2Rad * houseSpawnAngle) * CraneLength;

            var maxDy = -Mathf.Cos(Mathf.Deg2Rad * MaxHouseAngle) * CraneLength;
            var ddy = maxDy - houseSpawnDy;
            var velocityMag = Mathf.Sqrt(2 * House.GravityScale * 9.81f * ddy);

            if (Random.Range(0, 2) == 0) velocityMag *= -1;

            var angleTowardsCenter = Mathf.Abs(houseSpawnAngle);
            var velocityDirection = new Vector2(Mathf.Cos(Mathf.Deg2Rad * angleTowardsCenter),
                Mathf.Sin(Mathf.Deg2Rad * angleTowardsCenter));

            var velocity = velocityDirection * velocityMag;
            
            var houseSpawnPos = transform.position + new Vector3(houseSpawnDx, houseSpawnDy, 0);

            var houseSpawnRot = Quaternion.Euler(0, 0, houseSpawnAngle);

            if (_currentHouse != null)
            {
                _previousHouse = _currentHouse;
            }

            _currentHouse = Instantiate(housePrefab, houseSpawnPos, houseSpawnRot, transform).GetComponent<House>();
            _currentHouse.Setup(gameManager, _currentLevel, velocity);
            _currentHouse.OnTouchDown += MoveUp;
            
            craneJoint.connectedBody = _currentHouse.GetComponent<Rigidbody2D>();
            
            craneLine.gameObject.SetActive(true);
            UpdateCraneLine();

            _swingCount = 0;
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

        public void Reset()
        {
            if (_currentHouse != null)
            {
                Destroy(_currentHouse.gameObject);
                craneJoint.connectedBody = null;
                _currentHouse = null;
            }
            _previousHouse = null;
            transform.position = gameManager.transform.position + new Vector3(0, 7, 0);
            _isGameOver = false;
            _currentLevel = 0;
            SpawnHouse();
        }

        public House GetCurrentHouse() => _currentHouse;
    }
}
