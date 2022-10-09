using System;
using Core;
using UnityEngine;

namespace Audio
{
    /// <summary>
    /// Handles playing of sound effects
    /// </summary>
    [RequireComponent(typeof(AudioSource))]
    public class SFXManager : MonoBehaviour
    {
        private AudioSource _audioSource;
        
        [SerializeField] private GameManager gameManager;
        [SerializeField] private AudioClip snapClip;
        
        private void Awake()
        {
            _audioSource = GetComponent<AudioSource>();
            
            gameManager.OnTouchTap += PlaySnap;
        }

        private void OnDestroy()
        {
            gameManager.OnTouchTap -= PlaySnap;
        }

        private void PlaySnap()
        {
            _audioSource.PlayOneShot(snapClip);
        }
    }
}
