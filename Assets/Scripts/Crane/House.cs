using System.Collections.Generic;
using Core;
using UnityEngine;
using UnityEngine.Events;

namespace Crane
{
    /// <summary>
    /// Controls the house game object
    /// </summary>
    public class House : MonoBehaviour
    {
        public const int MaxColors = 5;
        public const float GravityScale = 1.8f;
        public const int BuildingHeight = 20;

        public event UnityAction OnTouchDown;
        
        [SerializeField] private List<SpriteRenderer> spriteRenderers;

        [SerializeField] private List<Color> facadeColors;
        
        [SerializeField] private Sprite houseBase, houseBody, houseTop;
        [SerializeField] private Sprite houseWindowsBase, houseWindowsBody, houseWindowsTop;
        [SerializeField] private Sprite houseDoor, houseRoof;

        [SerializeField] private AudioClip clipLand;

        private Rigidbody2D _rigidbody;
        private AudioSource _audioSource;

        private GameManager _gameManager;

        private int _level;

        public bool isDetached;

        private void Awake()
        {
            isDetached = false;

            _rigidbody = GetComponent<Rigidbody2D>();
            _rigidbody.gravityScale = GravityScale;

            _audioSource = GetComponent<AudioSource>();
        }

        public void Setup(GameManager gameManager, int floorLevel, Vector2 initialVelocity)
        {
            _gameManager = gameManager;
            _level = floorLevel;
            _rigidbody.velocity = initialVelocity;
            
            var facadeSprite = floorLevel switch
            {
                0 => houseBase,
                BuildingHeight => houseTop,
                _ => houseBody
            };
            var windowsSprite = floorLevel switch
            {
                0 => houseWindowsBase,
                BuildingHeight => houseWindowsTop,
                _ => houseWindowsBody
            };
            var additionalSprite = floorLevel switch
            {
                0 => houseDoor,
                BuildingHeight => houseRoof,
                _ => null
            };

            spriteRenderers[0].sprite = facadeSprite;
            spriteRenderers[1].sprite = windowsSprite;
            spriteRenderers[2].sprite = additionalSprite;

            spriteRenderers[0].color = facadeColors[_gameManager.houseColorId];
            
            if (floorLevel > 0 && floorLevel < BuildingHeight)
            {
                foreach (var spriteRenderer in spriteRenderers)
                {
                    spriteRenderer.flipY = floorLevel % 2 == 0;
                }
            }
        }

        public void Detach()
        {
            transform.SetParent(_gameManager.transform);
            isDetached = true;

            _rigidbody.drag = 1f;
            _rigidbody.angularDrag = 0.01f;
        }

        private void OnCollisionEnter2D(Collision2D other)
        {
            // play sound effect
            _audioSource.PlayOneShot(clipLand);
            
            var touchGround = other.transform.CompareTag("Ground");
            if (other.transform.CompareTag("House") || _level == 0  && touchGround)
            {
                OnTouchDown?.Invoke();
            }

            if (_level > 0 && touchGround)
            {
                _gameManager.CallGameOver();
            }
        }

        private void OnTriggerEnter2D(Collider2D other)
        {
            if (other.transform.CompareTag("Border"))
            {
                _gameManager.CallGameOver();
            }
        }

        public float GetVelocityX()
        {
            return _rigidbody.velocity.x;
        }
    }
}
