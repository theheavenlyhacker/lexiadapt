#!/usr/bin/env python3
"""
Export trained LSTM story generator to TFLite.
Usage: python export_lstm_tflite.py --model ../models/story_lstm.pth --output ../exports/story_lstm.tflite
"""
import argparse
import torch
import numpy as np


def main():
    parser = argparse.ArgumentParser(description="Export LSTM to TFLite")
    parser.add_argument("--model", type=str, default="../models/story_lstm.pth")
    parser.add_argument("--output", type=str, default="../exports/story_lstm.tflite")
    args = parser.parse_args()

    from train_lstm import StoryLSTM

    print(f"Loading LSTM from {args.model}...")
    checkpoint = torch.load(args.model, map_location="cpu")
    model = StoryLSTM(
        vocab_size=checkpoint["vocab_size"],
        hidden_dim=checkpoint["hidden_dim"],
    )
    model.load_state_dict(checkpoint["model_state"])
    model.eval()

    onnx_path = args.output.replace(".tflite", ".onnx")
    dummy_input = torch.randint(0, checkpoint["vocab_size"], (1, 20))

    print(f"Exporting to ONNX: {onnx_path}")
    torch.onnx.export(
        model,
        dummy_input,
        onnx_path,
        input_names=["input_tokens"],
        output_names=["output_logits", "hidden"],
        dynamic_axes={"input_tokens": {1: "seq_len"}},
        opset_version=13,
    )

    try:
        import tensorflow as tf

        converter = tf.lite.TFLiteConverter.from_saved_model(
            onnx_path.replace(".onnx", "_saved_model")
        )
        converter.optimizations = [tf.lite.Optimize.DEFAULT]
        tflite_model = converter.convert()

        with open(args.output, "wb") as f:
            f.write(tflite_model)
        print(f"TFLite saved: {args.output} ({len(tflite_model) / 1024 / 1024:.1f} MB)")
    except Exception as e:
        print(f"TFLite conversion note: {e}")
        print(f"ONNX model available at: {onnx_path}")


if __name__ == "__main__":
    main()
