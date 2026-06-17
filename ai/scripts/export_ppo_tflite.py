#!/usr/bin/env python3
"""
Export trained PPO policy network to TFLite for on-device inference.
Usage: python export_ppo_tflite.py --model ../models/drl_ppo_tutor --output ../exports/ppo_policy.tflite
"""
import argparse
import numpy as np


def main():
    parser = argparse.ArgumentParser(description="Export PPO to TFLite")
    parser.add_argument("--model", type=str, default="../models/drl_ppo_tutor")
    parser.add_argument("--output", type=str, default="../exports/ppo_policy.tflite")
    args = parser.parse_args()

    import torch
    from stable_baselines3 import PPO

    print(f"Loading PPO model from {args.model}...")
    model = PPO.load(args.model)
    policy = model.policy.to("cpu")
    policy.eval()

    # Export policy's action_net via ONNX
    dummy_input = torch.randn(1, 8)
    onnx_path = args.output.replace(".tflite", ".onnx")

    print(f"Exporting to ONNX: {onnx_path}")
    torch.onnx.export(
        policy.mlp_extractor,
        dummy_input,
        onnx_path,
        input_names=["state"],
        output_names=["features"],
        dynamic_axes={"state": {0: "batch"}},
        opset_version=13,
    )

    # Convert to TFLite
    try:
        import tensorflow as tf
        import onnx
        from onnx_tf.backend import prepare

        print("Converting ONNX → TensorFlow → TFLite...")
        onnx_model = onnx.load(onnx_path)
        tf_rep = prepare(onnx_model)
        tf_rep.export_graph(onnx_path.replace(".onnx", "_saved_model"))

        converter = tf.lite.TFLiteConverter.from_saved_model(
            onnx_path.replace(".onnx", "_saved_model")
        )
        converter.optimizations = [tf.lite.Optimize.DEFAULT]
        converter.target_spec.supported_types = [tf.int8]

        tflite_model = converter.convert()
        with open(args.output, "wb") as f:
            f.write(tflite_model)
        print(f"TFLite model saved: {args.output} ({len(tflite_model) / 1024:.1f} KB)")
    except ImportError:
        print("TFLite conversion requires: pip install tensorflow onnx onnx-tf")
        print(f"ONNX model saved at: {onnx_path}")


if __name__ == "__main__":
    main()
