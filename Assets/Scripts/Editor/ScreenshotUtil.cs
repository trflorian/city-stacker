using System;
using UnityEditor;
using UnityEngine;

namespace Editor
{
    public class ScreenshotUtil : MonoBehaviour
    {
        [MenuItem("Tools/Screenshot")]
        public static void CaptureScreenshot()
        {
            ScreenCapture.CaptureScreenshot($"Assets/Screenshots/Screenshot_{DateTime.Now:yyyy-dd-M--HH-mm-ss}.png");
        }
    }
}
