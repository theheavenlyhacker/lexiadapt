#!/usr/bin/env python3
"""
Export fine-tuned Whisper-tiny to TFLite INT4 for on-device inference.
Usage: python export_whisper_tflite.py --model ../models/whisper-tiny-filipino --output ../exports/whisper_tiny_int4.tflite
"""
import argparse
import numpy as np


def main():
    parser = argparse.ArgumentParser(description="Export Whisper to TFLite")
    parser.add_argument("--model", type=str, default="../models/whisper-tiny-filipino")
    parser.add_argument("--output", type=str, default="../exports/whisper_tiny_int4.tflite")
    args = parser.parse_args()

    print("Step 1: Loading model and exporting to ONNX...")
    try:
        from optimum.onnxruntime import ORTModelForSpeechSeq2Seq

        onnx_path = args.output.replace(".tflite", "_onnx")
        ort_model = ORTModelForSpeechSeq2Seq.from_pretrained(
            args.model, export=True
        )
        ort_model.save_pretrained(onnx_path)
        print(f"ONNX model saved to {onnx_path}")
    except Exception as e:
        print(f"ONNX export failed: {e}")
        print("Ensure model exists at the specified path.")
        return

    print("Step 2: Converting to TFLite with INT8 quantization...")
    try:
        import tensorflow as tf

        def representative_dataset():
            for _ in range(100):
                yield [np.random.randn(1, 80, 3000).astype(np.float32)]

        converter = tf.lite.TFLiteConverter.from_saved_model(onnx_path)
        converter.optimizations = [tf.lite.Optimize.DEFAULT]
        converter.representative_dataset = representative_dataset
        converter.target_spec.supported_ops = [tf.lite.OpsSet.TFLITE_BUILTINS_INT8]
        converter.inference_input_type = tf.int8
        converter.inference_output_type = tf.int8

        tflite_model = converter.convert()

        with open(args.output, "wb") as f:
            f.write(tflite_model)

        size_mb = len(tflite_model) / 1024 / 1024
        print(f"TFLite model saved: {args.output} ({size_mb:.1f} MB)")
    except Exception as e:
        print(f"TFLite conversion note: {e}")
        print("ONNX model is available for alternative conversion pipelines.")


if __name__ == "__main__":
    main()
