#!/usr/bin/env python3
"""
Train a PPO agent for adaptive difficulty adjustment.
Usage: python train_drl.py --timesteps 500000 --output ../models/drl_ppo_tutor
"""
import argparse
import sys
import os

sys.path.insert(0, os.path.dirname(__file__))

from stable_baselines3 import PPO
from stable_baselines3.common.env_util import make_vec_env
from reading_env import ReadingTutorEnv


def main():
    parser = argparse.ArgumentParser(description="Train DRL agent for LexiAdapt")
    parser.add_argument("--timesteps", type=int, default=500_000)
    parser.add_argument("--output", type=str, default="../models/drl_ppo_tutor")
    parser.add_argument("--lr", type=float, default=3e-4)
    parser.add_argument("--batch-size", type=int, default=64)
    parser.add_argument("--n-epochs", type=int, default=10)
    args = parser.parse_args()

    print(f"Training PPO for {args.timesteps} timesteps...")

    env = make_vec_env(ReadingTutorEnv, n_envs=4)

    model = PPO(
        "MlpPolicy",
        env,
        learning_rate=args.lr,
        n_steps=2048,
        batch_size=args.batch_size,
        n_epochs=args.n_epochs,
        gamma=0.99,
        gae_lambda=0.95,
        clip_range=0.2,
        verbose=1,
        tensorboard_log="../models/tb_logs/",
    )

    model.learn(total_timesteps=args.timesteps, progress_bar=True)
    model.save(args.output)
    print(f"Model saved to {args.output}")

    # Quick evaluation
    env = ReadingTutorEnv()
    obs, _ = env.reset()
    total_reward = 0
    for _ in range(50):
        action, _ = model.predict(obs, deterministic=True)
        obs, reward, terminated, truncated, info = env.step(action)
        total_reward += reward
        if terminated or truncated:
            break
    print(f"Evaluation reward: {total_reward:.2f}")


if __name__ == "__main__":
    main()
