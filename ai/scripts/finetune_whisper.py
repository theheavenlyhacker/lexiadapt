#!/usr/bin/env python3
"""
Fine-tune Whisper-tiny on children's English reading data.
Uses LibriSpeech clean-100 as base, with optional kid-specific datasets.

Usage:
  # Quick test (100 samples)
  python finetune_whisper.py --dataset librispeech --max-samples 100 --epochs 1

  # Full training on LibriSpeech clean-100
  python finetune_whisper.py --dataset librispeech --epochs 3

  # Train on custom local audio files
  python finetune_whisper.py --dataset local --data-dir ../data/audio/ --epochs 5
"""
import argparse
import os


def load_librispeech(split="train.clean.100", max_samples=None):
    from datasets import load_dataset, Audio

    print(f"Loading LibriSpeech ({split})...")
    dataset = load_dataset("librispeech_asr", split=split, trust_remote_code=True)
    if max_samples:
        dataset = dataset.select(range(min(max_samples, len(dataset))))
    dataset = dataset.cast_column("audio", Audio(sampling_rate=16000))
    print(f"Loaded {len(dataset)} samples")
    return dataset, "text"


def load_common_voice_en(max_samples=None):
    from datasets import load_dataset, Audio

    print("Loading Common Voice English...")
    dataset = load_dataset(
        "mozilla-foundation/common_voice_16_1", "en",
        split="train", trust_remote_code=True,
    )
    if max_samples:
        dataset = dataset.select(range(min(max_samples, len(dataset))))
    dataset = dataset.cast_column("audio", Audio(sampling_rate=16000))
    print(f"Loaded {len(dataset)} samples")
    return dataset, "sentence"


def load_local_dataset(data_dir, max_samples=None):
    """Load local .wav/.mp3 files paired with .txt transcripts."""
    import glob
    from datasets import Dataset, Audio

    audio_files = sorted(glob.glob(os.path.join(data_dir, "*.wav")) +
                         glob.glob(os.path.join(data_dir, "*.mp3")))

    records = []
    for audio_path in audio_files:
        txt_path = os.path.splitext(audio_path)[0] + ".txt"
        if os.path.exists(txt_path):
            with open(txt_path) as f:
                text = f.read().strip()
            records.append({"audio": audio_path, "text": text})

    if not records:
        print(f"No audio+transcript pairs found in {data_dir}")
        print("Expected: file.wav + file.txt pairs")
        return None, None

    if max_samples:
        records = records[:max_samples]

    dataset = Dataset.from_list(records)
    dataset = dataset.cast_column("audio", Audio(sampling_rate=16000))
    print(f"Loaded {len(records)} local samples from {data_dir}")
    return dataset, "text"


def main():
    parser = argparse.ArgumentParser(description="Fine-tune Whisper-tiny for English reading")
    parser.add_argument("--dataset", type=str, default="librispeech",
                        choices=["librispeech", "common_voice_en", "local"],
                        help="Dataset to train on")
    parser.add_argument("--data-dir", type=str, default="../data/audio/",
                        help="Directory for local audio files")
    parser.add_argument("--epochs", type=int, default=3)
    parser.add_argument("--batch-size", type=int, default=8)
    parser.add_argument("--lr", type=float, default=1e-5)
    parser.add_argument("--output", type=str, default="../models/whisper-tiny-en")
    parser.add_argument("--max-samples", type=int, default=None,
                        help="Limit training samples (for quick testing)")
    args = parser.parse_args()

    from transformers import (
        WhisperForConditionalGeneration,
        WhisperProcessor,
        Seq2SeqTrainer,
        Seq2SeqTrainingArguments,
    )
    import torch

    print("Loading Whisper-tiny base model...")
    model = WhisperForConditionalGeneration.from_pretrained("openai/whisper-tiny")
    processor = WhisperProcessor.from_pretrained("openai/whisper-tiny")

    model.config.forced_decoder_ids = processor.get_decoder_prompt_ids(language="en", task="transcribe")
    model.config.suppress_tokens = []

    # Load dataset
    if args.dataset == "librispeech":
        dataset, text_col = load_librispeech(max_samples=args.max_samples)
    elif args.dataset == "common_voice_en":
        dataset, text_col = load_common_voice_en(max_samples=args.max_samples)
    elif args.dataset == "local":
        dataset, text_col = load_local_dataset(args.data_dir, max_samples=args.max_samples)
    else:
        print(f"Unknown dataset: {args.dataset}")
        return

    if dataset is None:
        return

    def prepare_dataset(batch):
        audio = batch["audio"]
        batch["input_features"] = processor(
            audio["array"], sampling_rate=16000, return_tensors="pt"
        ).input_features[0]
        batch["labels"] = processor.tokenizer(batch[text_col]).input_ids
        return batch

    print("Preprocessing audio...")
    dataset = dataset.map(
        prepare_dataset,
        remove_columns=dataset.column_names,
        num_proc=1,
    )

    training_args = Seq2SeqTrainingArguments(
        output_dir=args.output,
        per_device_train_batch_size=args.batch_size,
        num_train_epochs=args.epochs,
        learning_rate=args.lr,
        warmup_steps=100,
        fp16=torch.cuda.is_available(),
        predict_with_generate=True,
        save_total_limit=2,
        logging_steps=25,
        eval_strategy="no",
        report_to="none",
    )

    trainer = Seq2SeqTrainer(
        model=model,
        args=training_args,
        train_dataset=dataset,
        tokenizer=processor.feature_extractor,
    )

    print(f"Fine-tuning for {args.epochs} epochs on {len(dataset)} samples...")
    trainer.train()

    os.makedirs(args.output, exist_ok=True)
    model.save_pretrained(args.output)
    processor.save_pretrained(args.output)
    print(f"Model saved to {args.output}")

    # Quick test
    print("\nTesting model...")
    from transformers import pipeline
    pipe = pipeline("automatic-speech-recognition", model=args.output)
    print("Model loaded successfully. Ready for inference.")


if __name__ == "__main__":
    main()
