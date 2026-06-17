#!/usr/bin/env python3
"""
Train LSTM story generator for personalized reading narratives.
Usage: python train_lstm.py --data ../data/stories/ --epochs 50 --output ../models/story_lstm.pth
"""
import argparse
import os
import json
import torch
import torch.nn as nn
from torch.utils.data import Dataset, DataLoader


class StoryLSTM(nn.Module):
    def __init__(self, vocab_size, embed_dim=128, hidden_dim=256, num_layers=2, dropout=0.2):
        super().__init__()
        self.hidden_dim = hidden_dim
        self.num_layers = num_layers
        self.embedding = nn.Embedding(vocab_size, embed_dim)
        self.lstm = nn.LSTM(embed_dim, hidden_dim, num_layers,
                            batch_first=True, dropout=dropout)
        self.fc = nn.Linear(hidden_dim, vocab_size)

    def forward(self, x, hidden=None):
        x = self.embedding(x)
        output, hidden = self.lstm(x, hidden)
        output = self.fc(output)
        return output, hidden

    def generate(self, start_tokens, max_len=100, temperature=0.8, eos_token=1):
        self.eval()
        tokens = start_tokens.clone()
        hidden = None

        with torch.no_grad():
            for _ in range(max_len):
                output, hidden = self.forward(tokens[:, -1:], hidden)
                probs = torch.softmax(output[:, -1] / temperature, dim=-1)
                next_token = torch.multinomial(probs, 1)
                tokens = torch.cat([tokens, next_token], dim=1)
                if next_token.item() == eos_token:
                    break

        return tokens


class Vocabulary:
    def __init__(self):
        self.word2idx = {"<PAD>": 0, "<EOS>": 1, "<UNK>": 2}
        self.idx2word = {0: "<PAD>", 1: "<EOS>", 2: "<UNK>"}

    def build(self, texts, min_freq=2):
        freq = {}
        for text in texts:
            for word in text.lower().split():
                freq[word] = freq.get(word, 0) + 1
        for word, count in sorted(freq.items(), key=lambda x: -x[1]):
            if count >= min_freq:
                idx = len(self.word2idx)
                self.word2idx[word] = idx
                self.idx2word[idx] = word

    def encode(self, text):
        return [self.word2idx.get(w, 2) for w in text.lower().split()] + [1]

    def decode(self, indices):
        return " ".join(self.idx2word.get(i, "<UNK>") for i in indices if i > 1)

    def save(self, path):
        with open(path, "w") as f:
            json.dump(self.word2idx, f)

    def load(self, path):
        with open(path) as f:
            self.word2idx = json.load(f)
        self.idx2word = {v: k for k, v in self.word2idx.items()}

    @property
    def size(self):
        return len(self.word2idx)


class StoryDataset(Dataset):
    def __init__(self, encoded_stories, seq_len=30):
        self.data = []
        for story in encoded_stories:
            for i in range(0, len(story) - seq_len, seq_len // 2):
                chunk = story[i:i + seq_len + 1]
                if len(chunk) == seq_len + 1:
                    self.data.append(chunk)

    def __len__(self):
        return len(self.data)

    def __getitem__(self, idx):
        chunk = self.data[idx]
        return torch.tensor(chunk[:-1], dtype=torch.long), torch.tensor(chunk[1:], dtype=torch.long)


def load_stories(data_dir):
    stories = []
    if os.path.isdir(data_dir):
        for fname in os.listdir(data_dir):
            if fname.endswith(".txt"):
                with open(os.path.join(data_dir, fname)) as f:
                    stories.append(f.read().strip())
    if not stories:
        stories = [
            "The little boy went to the river and saw a big fish swimming in the water.",
            "A brave girl climbed the tall mountain and found a golden treasure chest at the top.",
            "The cat and the dog became best friends and played together every day in the garden.",
            "Once upon a time a kind teacher helped all the children learn to read beautiful stories.",
            "The sun rose over the green hills and all the birds sang their happy morning songs.",
        ] * 100
        print("WARNING: No training data found. Using placeholder stories.")
    return stories


def main():
    parser = argparse.ArgumentParser(description="Train LSTM story generator")
    parser.add_argument("--data", type=str, default="../data/stories/")
    parser.add_argument("--epochs", type=int, default=50)
    parser.add_argument("--batch-size", type=int, default=32)
    parser.add_argument("--lr", type=float, default=1e-3)
    parser.add_argument("--hidden-dim", type=int, default=256)
    parser.add_argument("--seq-len", type=int, default=30)
    parser.add_argument("--output", type=str, default="../models/story_lstm.pth")
    args = parser.parse_args()

    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    print(f"Using device: {device}")

    stories = load_stories(args.data)
    print(f"Loaded {len(stories)} stories")

    vocab = Vocabulary()
    vocab.build(stories, min_freq=1)
    print(f"Vocabulary size: {vocab.size}")

    encoded = [vocab.encode(s) for s in stories]
    dataset = StoryDataset(encoded, seq_len=args.seq_len)
    loader = DataLoader(dataset, batch_size=args.batch_size, shuffle=True)
    print(f"Training samples: {len(dataset)}")

    model = StoryLSTM(vocab.size, hidden_dim=args.hidden_dim).to(device)
    optimizer = torch.optim.Adam(model.parameters(), lr=args.lr)
    criterion = nn.CrossEntropyLoss(ignore_index=0)

    for epoch in range(args.epochs):
        model.train()
        total_loss = 0
        for inputs, targets in loader:
            inputs, targets = inputs.to(device), targets.to(device)
            output, _ = model(inputs)
            loss = criterion(output.view(-1, vocab.size), targets.view(-1))
            optimizer.zero_grad()
            loss.backward()
            torch.nn.utils.clip_grad_norm_(model.parameters(), 1.0)
            optimizer.step()
            total_loss += loss.item()

        avg_loss = total_loss / len(loader)
        if (epoch + 1) % 5 == 0 or epoch == 0:
            print(f"Epoch {epoch+1}/{args.epochs} — Loss: {avg_loss:.4f}")

    os.makedirs(os.path.dirname(args.output), exist_ok=True)
    torch.save({
        "model_state": model.state_dict(),
        "vocab_size": vocab.size,
        "hidden_dim": args.hidden_dim,
    }, args.output)
    vocab.save(args.output.replace(".pth", "_vocab.json"))
    print(f"Model saved to {args.output}")

    # Test generation
    model.eval()
    start = torch.tensor([vocab.encode("the")[:1]], dtype=torch.long).to(device)
    generated = model.generate(start, max_len=30)
    print(f"Sample: {vocab.decode(generated[0].tolist())}")


if __name__ == "__main__":
    main()
