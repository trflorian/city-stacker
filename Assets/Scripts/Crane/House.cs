using System;
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
        public const int BuildingHeight = 20;

        public event UnityAction OnTouchDown;

        [SerializeField] private SpriteRenderer spriteRenderer;
        [SerializeField] private Sprite houseBase, houseBody, houseRoof;

        private Rigidbody2D _rigidbody;

        private int _level;

        public bool isDetached;

        private void Awake()
        {
            isDetached = false;

            _rigidbody = GetComponent<Rigidbody2D>();
        }

        public void SetLevel(int floorLevel)
        {
            _level = floorLevel;
            
            var sprite = floorLevel switch
            {
                0 => houseBase,
                BuildingHeight => houseRoof,
                _ => houseBody
            };

            spriteRenderer.sprite = sprite;
        }

        public void Detach()
        {
            transform.SetParent(null);
            isDetached = true;

            _rigidbody.drag = 1f;
            _rigidbody.angularDrag = 0.01f;
        }

        private void OnCollisionEnter2D(Collision2D other)
        {
            var touchGround = other.transform.CompareTag("Ground");
            if (other.transform.CompareTag("House") || _level == 0  && touchGround)
            {
                OnTouchDown?.Invoke();
            }

            if (_level > 0 && touchGround)
            {
                GameManager.CallGameOver();
            }
        }

        private void OnTriggerEnter2D(Collider2D other)
        {
            if (other.transform.CompareTag("Border"))
            {
                GameManager.CallGameOver();
            }
        }
    }
}
