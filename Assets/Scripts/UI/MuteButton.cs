using System;
using UnityEngine;
using UnityEngine.Audio;
using UnityEngine.UI;

namespace UI
{
    /// <summary>
    /// Mute and unmute the game
    /// </summary>
    public class MuteButton : MonoBehaviour
    {
        private const float MinVolume = -100f;
        private const float MaxVolume = 0f;
        
        [SerializeField] private AudioMixer audioMixer;
        [SerializeField] private Sprite audioOn, audioOff;
        
        private Button _button;
        private bool _muted;
        
        private void Awake()
        {
            _button = GetComponent<Button>();
            _button.onClick.AddListener(OnToggleMute);
        }

        private void OnToggleMute()
        {
            _muted = !_muted;
            audioMixer.SetFloat("MusicVol", _muted ? MinVolume : MaxVolume);
            _button.image.sprite = _muted ? audioOff : audioOn;
        }
    }
}
