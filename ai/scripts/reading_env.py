"""
LexiAdapt Reading Tutor Environment for DRL training.
Custom Gymnasium environment that simulates a student reading session.
"""
import gymnasium as gym
from gymnasium import spaces
import numpy as np


class ReadingTutorEnv(gym.Env):
    """
    State (8 dims):
      0: overall_accuracy (0-1)
      1: phonics_score (0-1)
      2: vocabulary_score (0-1)
      3: fluency_wpm_normalized (0-1)
      4: comprehension_score (0-1)
      5: current_difficulty (0-1)
      6: consecutive_successes (0-1, normalized from 0-10)
      7: consecutive_failures (0-1, normalized from 0-10)

    Actions (5 discrete):
      0: decrease difficulty by 2 levels
      1: decrease difficulty by 1 level
      2: maintain current difficulty
      3: increase difficulty by 1 level
      4: increase difficulty by 2 levels

    Reward design based on Zone of Proximal Development (ZPD):
      +1.0 if accuracy improves
      +0.5 if accuracy stays in ZPD range (0.6-0.85)
      +0.3 for maintaining good accuracy (>0.7)
      -0.5 if accuracy drops below 0.4
      -1.0 if 3+ consecutive failures (frustration signal)
    """

    metadata = {"render_modes": []}

    def __init__(self):
        super().__init__()
        self.observation_space = spaces.Box(
            low=0.0, high=1.0, shape=(8,), dtype=np.float32
        )
        self.action_space = spaces.Discrete(5)
        self.state = np.zeros(8, dtype=np.float32)
        self.steps = 0
        self.max_steps = 50

    def reset(self, seed=None, options=None):
        super().reset(seed=seed)
        self.state = np.array([
            0.5,  # overall_accuracy
            0.5,  # phonics
            0.5,  # vocabulary
            0.4,  # fluency (normalized: 60 WPM / 150)
            0.5,  # comprehension
            0.3,  # difficulty (start easy)
            0.0,  # consecutive_successes
            0.0,  # consecutive_failures
        ], dtype=np.float32)
        self.steps = 0
        return self.state.copy(), {}

    def step(self, action):
        self.steps += 1
        difficulty_delta = (action - 2) * 0.1
        new_difficulty = np.clip(self.state[5] + difficulty_delta, 0.0, 1.0)

        ability = np.mean(self.state[:5])
        gap = ability - new_difficulty
        noise = self.np_random.normal(0, 0.1)
        accuracy = np.clip(0.5 + gap * 0.8 + noise, 0.0, 1.0)

        prev_accuracy = self.state[0]
        reward = 0.0

        if accuracy > prev_accuracy:
            reward += 1.0
        if 0.6 <= accuracy <= 0.85:
            reward += 0.5
        if accuracy >= 0.7:
            reward += 0.3
        if accuracy < 0.4:
            reward -= 0.5

        cons_fail = self.state[7] * 10
        if accuracy < 0.5:
            cons_fail = min(cons_fail + 1, 10)
            if cons_fail >= 3:
                reward -= 1.0
        else:
            cons_fail = 0

        cons_succ = self.state[6] * 10
        if accuracy >= 0.6:
            cons_succ = min(cons_succ + 1, 10)
        else:
            cons_succ = 0

        self.state[0] = float(accuracy)
        self.state[1] = np.clip(self.state[1] + (accuracy - 0.5) * 0.05, 0, 1)
        self.state[2] = np.clip(self.state[2] + (accuracy - 0.5) * 0.04, 0, 1)
        self.state[3] = np.clip(self.state[3] + (accuracy - 0.5) * 0.03, 0, 1)
        self.state[4] = np.clip(self.state[4] + (accuracy - 0.5) * 0.04, 0, 1)
        self.state[5] = float(new_difficulty)
        self.state[6] = float(cons_succ / 10.0)
        self.state[7] = float(cons_fail / 10.0)

        terminated = False
        truncated = self.steps >= self.max_steps

        return self.state.copy(), float(reward), terminated, truncated, {
            "accuracy": float(accuracy),
            "difficulty": float(new_difficulty),
        }


# Register with gymnasium
gym.register(
    id="ReadingTutor-v0",
    entry_point="reading_env:ReadingTutorEnv",
    max_episode_steps=50,
)
