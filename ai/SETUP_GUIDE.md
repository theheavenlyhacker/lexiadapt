# AI Training Setup Guide

Step-by-step guide to set up your machine and start training all 3 models.

---

## Step 1: Python Environment

```bash
cd /home/jai/Github/lexiadapt

# Create virtual environment
python3 -m venv ai/venv
source ai/venv/bin/activate

# Install all dependencies
pip install -r ai/requirements.txt
```

**Estimated time:** 5-15 minutes depending on internet speed.
**Disk space:** ~5GB for PyTorch + TensorFlow + dependencies.

---

## Step 2: Verify GPU (Optional but Recommended)

```bash
python3 -c "import torch; print(f'CUDA available: {torch.cuda.is_available()}')"
python3 -c "import torch; print(f'Device: {torch.cuda.get_device_name(0)}')" 2>/dev/null || echo "No GPU - will use CPU (slower but works)"
```

Training works on CPU, just slower:
| Model | GPU (RTX 3060) | CPU (Ryzen 5) |
|-------|---------------|---------------|
| DRL (500k steps) | ~5 min | ~20 min |
| LSTM (50 epochs) | ~10 min | ~45 min |
| Whisper fine-tune (3 epochs) | ~30 min | ~4 hours |

---

## Step 3: Download Datasets

### 3A. LibriSpeech (for Whisper) — REQUIRED

**What:** Clean English speech recordings with transcripts. 100 hours of read English.
**Size:** 6.3 GB
**License:** CC BY 4.0 (free)
**Auto-download:** The training script downloads it automatically via HuggingFace.

If you want to download manually:
```bash
# Option 1: Auto-download (happens when you run the script)
cd ai/scripts
python3 finetune_whisper.py --dataset librispeech --max-samples 5 --epochs 1
# This downloads LibriSpeech on first run

# Option 2: Manual download
mkdir -p ../data/librispeech
cd ../data/librispeech
wget https://www.openslr.org/resources/12/train-clean-100.tar.gz
tar xzf train-clean-100.tar.gz
rm train-clean-100.tar.gz
```

### 3B. English Story Corpus (for LSTM) — ALREADY INCLUDED

35 starter stories are already in `ai/data/stories/`. For better results, add more:

```bash
# Download children's public domain books from Project Gutenberg
mkdir -p ai/data/stories

# Aesop's Fables (simple English, perfect for Grade 1-3)
wget -O ai/data/stories/aesops_fables.txt "https://www.gutenberg.org/cache/epub/11339/pg11339.txt"

# McGuffey's First Reader (actual Grade 1 reading material from 1800s)
wget -O ai/data/stories/mcguffey_first.txt "https://www.gutenberg.org/cache/epub/14640/pg14640.txt"

# McGuffey's Second Reader
wget -O ai/data/stories/mcguffey_second.txt "https://www.gutenberg.org/cache/epub/14880/pg14880.txt"

# Mother Goose nursery rhymes
wget -O ai/data/stories/mother_goose.txt "https://www.gutenberg.org/cache/epub/697/pg697.txt"

# Grimm's Fairy Tales (simplified versions)
wget -O ai/data/stories/grimm_fairy.txt "https://www.gutenberg.org/cache/epub/2591/pg2591.txt"
```

**Total:** ~5 MB of text, thousands of sentences at Grade 1-3 reading level.

### 3C. DRL Training — NO DOWNLOAD NEEDED

The DRL agent trains on a simulated environment (ReadingTutorEnv). No external data required.

### 3D. Whisper Base Model — AUTO-DOWNLOADED

Whisper-tiny (39 MB) downloads automatically on first run. If you want to pre-download:

```bash
python3 -c "import whisper; whisper.load_model('tiny', download_root='ai/models/')"
```

### 3E. IPA Phoneme Dictionary (Optional, for phoneme analysis)

```bash
# Install espeak (required by phonemizer for English phoneme conversion)
# Fedora:
sudo dnf install espeak-ng

# Ubuntu/Debian:
# sudo apt install espeak-ng

# Verify it works:
python3 -c "from phonemizer import phonemize; print(phonemize('hello world', language='en-us', backend='espeak'))"
```

---

## Step 4: Train the Models

**Run these in order.** Each command should be run from the project root with the venv activated.

### 4A. DRL Agent (fastest — start here)

```bash
source ai/venv/bin/activate

# Quick test (2 minutes)
cd ai/scripts
python3 train_drl.py --timesteps 10000 --output ../models/drl_ppo_tutor

# Full training (5-20 minutes)
python3 train_drl.py --timesteps 500000 --output ../models/drl_ppo_tutor
```

**Expected output:**
```
Training PPO for 500000 timesteps...
| rollout/           |          |
|    ep_len_mean     | 50       |
|    ep_rew_mean     | 18.5     |
| time/              |          |
|    fps             | 2500     |
|    total_timesteps | 500000   |
Model saved to ../models/drl_ppo_tutor
Evaluation reward: 22.35
```

### 4B. LSTM Story Generator

```bash
# With starter data (5 minutes)
python3 train_lstm.py --data ../data/stories/ --epochs 50 --output ../models/story_lstm.pth

# With expanded data after downloading Gutenberg books
python3 train_lstm.py --data ../data/stories/ --epochs 100 --output ../models/story_lstm.pth
```

**Expected output:**
```
Using device: cpu
Loaded 35 stories
Vocabulary size: 487
Training samples: 142
Epoch 5/50 — Loss: 5.2341
Epoch 10/50 — Loss: 3.8712
...
Epoch 50/50 — Loss: 1.2345
Model saved to ../models/story_lstm.pth
Sample: the cat sat on the mat and saw a bird
```

### 4C. Whisper Fine-tuning

```bash
# Quick test first (5 minutes, 100 samples)
python3 finetune_whisper.py --dataset librispeech --max-samples 100 --epochs 1 --output ../models/whisper-tiny-en

# Full training (30 min GPU / 4 hours CPU)
python3 finetune_whisper.py --dataset librispeech --epochs 3 --output ../models/whisper-tiny-en
```

**Expected output:**
```
Loading Whisper-tiny base model...
Loading LibriSpeech (train.clean.100)...
Loaded 28539 samples
Preprocessing audio...
Fine-tuning for 3 epochs on 28539 samples...
{'loss': 0.432, 'learning_rate': 8.5e-06, 'epoch': 1.0}
{'loss': 0.287, 'learning_rate': 5.2e-06, 'epoch': 2.0}
{'loss': 0.198, 'learning_rate': 1.8e-06, 'epoch': 3.0}
Model saved to ../models/whisper-tiny-en
```

### 4D. Test Phoneme Analysis

```bash
# Quick test (no audio file needed)
python3 phoneme_extractor.py --test

# With a real audio file (record yourself reading a sentence)
python3 phoneme_extractor.py --audio test.wav --expected "The cat sat on the mat"
```

---

## Step 5: Export to TFLite (for mobile deployment)

After training, convert models to mobile-ready format:

```bash
# Export DRL policy
python3 export_ppo_tflite.py --model ../models/drl_ppo_tutor --output ../exports/ppo_policy.tflite

# Export LSTM
python3 export_lstm_tflite.py --model ../models/story_lstm.pth --output ../exports/story_lstm.tflite

# Export Whisper (requires tensorflow)
python3 export_whisper_tflite.py --model ../models/whisper-tiny-en --output ../exports/whisper_tiny_int4.tflite
```

Then copy to Flutter assets:
```bash
mkdir -p ../../assets/models
cp ../exports/*.tflite ../../assets/models/
```

---

## Summary: What to Download

| What | Size | How | Required? |
|------|------|-----|-----------|
| Python packages (`pip install`) | ~5 GB | `pip install -r ai/requirements.txt` | Yes |
| LibriSpeech clean-100 | 6.3 GB | Auto-downloads on first Whisper training run | Yes (for Whisper) |
| Whisper-tiny base model | 39 MB | Auto-downloads on first run | Yes |
| espeak-ng (phoneme engine) | ~5 MB | `sudo dnf install espeak-ng` | Optional |
| Gutenberg books (extra LSTM data) | ~5 MB | `wget` commands in Step 3B | Recommended |
| **Total disk space needed** | **~12 GB** | | |

### Things that DON'T need downloading:
- DRL training data (simulated environment, no external data)
- LSTM starter stories (already included in `ai/data/stories/`)
- Flutter mock AI services (already working in the app)

---

## Troubleshooting

**"No module named 'torch'"**
→ You forgot to activate the venv: `source ai/venv/bin/activate`

**"CUDA out of memory"**
→ Reduce batch size: `--batch-size 4` or `--batch-size 2`

**"Could not load dataset"**
→ For LibriSpeech, ensure internet connection. First download is ~6GB.

**"espeak not found" (phonemizer error)**
→ Install: `sudo dnf install espeak-ng` (Fedora) or `sudo apt install espeak-ng` (Ubuntu)

**Training is very slow on CPU**
→ Start with DRL (fastest). For Whisper, use `--max-samples 500` to limit data. Use Google Colab for free GPU if needed.

**"Killed" during training**
→ Out of RAM. Reduce `--batch-size` to 2 or use `--max-samples` to limit dataset size.
