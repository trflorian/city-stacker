using System.Collections;
using Core;
using Unity.MLAgents;
using Unity.MLAgents.Actuators;
using Unity.MLAgents.Sensors;
using UnityEngine;

namespace ML
{
    /// <summary>
    /// Agent that controls the game
    /// </summary>
    public class GameAgent : Agent
    {
        [SerializeField] private GameManager gameManager;
        [SerializeField] private Crane.Crane crane;

        public override void OnEpisodeBegin()
        {
            gameManager.Reset();
            crane.Reset();
        }

        private void Awake()
        {
            gameManager.OnGameOver += OnGameOver;
            crane.OnScoreIncreased += OnScoreIncreased;
        }

        private void OnDestroy()
        {
            gameManager.OnGameOver -= OnGameOver;
            crane.OnScoreIncreased -= OnScoreIncreased;
        }

        private void OnGameOver()
        {
            Invoke(nameof(EndEpisode), 0.1f);
        }

        private void OnScoreIncreased(int swings)
        {
            // after 2 swings max reward is given up 
            var swingCost = 4 * (Mathf.Pow(2,swings) - 1);
            
            var placedHouse = crane.GetCurrentHousePos();
            var previousHouse = crane.GetPreviousHousePos();

            var distance = Mathf.Abs(placedHouse.x - previousHouse.x);
            AddReward(10 - 40*distance - swingCost);

        }

        public override void OnActionReceived(ActionBuffers actions)
        {
            var releaseHouse = actions.DiscreteActions[0] == 1;

            if (releaseHouse)
            {
                var currentHouse = crane.GetCurrentHouse();
                // if tapping when house already detached punish
                if (currentHouse != null && crane.GetCurrentHouse().isDetached)
                {
                    AddReward(-10);
                }
                gameManager.Tap();
            }
        }

        public override void CollectObservations(VectorSensor sensor)
        {
            var currentHouse = crane.GetCurrentHouse();
            var velocityX = 0f;
            var detached = true;
            if (currentHouse != null)
            {
                velocityX = currentHouse.GetVelocityX();
                detached = currentHouse.isDetached;
            }
            var currentHousePosition = crane.GetCurrentHousePos();

            // the first house is the ground at (0,-2)
            var previousHousePos = crane.GetPreviousHousePos();

            if (detached)
            {
                velocityX = 0;
                currentHousePosition = Vector2.zero;
                previousHousePos = Vector2.zero;
            }
            
            sensor.AddObservation(detached);
            sensor.AddObservation(velocityX);
            sensor.AddObservation(currentHousePosition.x - previousHousePos.x);
        }
    }
}
