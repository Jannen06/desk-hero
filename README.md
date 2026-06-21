# Desk Hero - Autonomous Pen Organizer

> **Berlin Robotics x AI Hackathon 2025**
> Hugging Face "Desk Hero" Track

A robot arm that autonomously picks up pens from your desk and places them into a cup holder using imitation learning.

![Demo](media/demo.gif)

---

## The Problem

Pens scattered on your desk are a small but persistent annoyance. We trained a robot arm to solve it - watch the pen go from desk to cup, hands free.

---

## How It Works

We used **imitation learning** via [LeRobot](https://github.com/huggingface/lerobot):

1. **Teleoperation** - A human demonstrated the pick-and-place task ~50 times using a leader arm
2. **Dataset** - Recordings were uploaded to Hugging Face Hub as structured datasets
3. **Training** - An ACT (Action Chunking Transformer) policy was trained on a university GPU cluster (25GB VRAM)
4. **Deployment** - The trained policy runs on the follower arm autonomously in real time

```
Human demos → Dataset (HF Hub) → ACT Training → Autonomous Robot
```

---

## Hardware

| Component | Details |
|---|---|
| Robot Arms | 2x SO-101 follower/leader arms |
| Camera (overhead) | Innomaker USB 1080p camera |
| Camera (wrist) | USB webcam mounted on end effector |
| Compute (training) | H-BRS University cluster, 25GB VRAM |
| Compute (inference) | Laptop with NVIDIA RTX 500 Ada Mobile GPU |
| OS | Ubuntu 22.04 |

---

## Datasets & Models

| Resource | Link |
|---|---|
| Dataset (merged) | [lorenz-k/desk-hero-merged](https://huggingface.co/datasets/lorenz-k/desk-hero-merged) |
| Trained Policy | [jan024/pen_to_holder_act](https://huggingface.co/jan024/pen_to_holder_act) |

---

## Setup & Installation

### Prerequisites

- Ubuntu 22.04
- Python 3.12
- NVIDIA GPU with CUDA
- SO-101 robot arm(s)

### Install

```bash
# Clone this repo
git clone https://github.com/YOUR_USERNAME/desk-hero.git
cd desk-hero

# Install uv
curl -LsSf https://astral.sh/uv/install.sh | sh
export PATH="$HOME/.local/bin:$PATH"

# Clone and install LeRobot
git clone https://github.com/Jannen06/lerobot.git
cd lerobot
uv venv --python 3.12
source .venv/bin/activate
uv pip install -e ".[pusht,viz,smolvla]"
uv pip install pynput

# Login to HuggingFace
hf auth login

# Robot serial port permissions
sudo usermod -a -G dialout $USER
sudo chmod 666 /dev/ttyACM0
```

### Important: Clear ROS environment if installed

```bash
unset PYTHONPATH
unset AMENT_PREFIX_PATH
```

---

## Running the Demo

### Find your camera and robot ports

```bash
lerobot-find-cameras
lerobot-find-port
```

### Run continuous pick-and-place loop

```bash
chmod +x pick_loop.sh
./pick_loop.sh
```

The script will prompt you to place a pen before each episode. The robot picks it up and places it in the cup, then resets for the next pen.

### Single rollout

```bash
lerobot-rollout \
  --policy.type act \
  --policy.pretrained_path jan024/pen_to_holder_act \
  --robot.type=so101_follower \
  --robot.id=follower \
  --robot.port=/dev/ttyACM0 \
  --robot.calibration_dir=~/.cache/huggingface/lerobot/calibration \
  --robot.cameras='{"overhead": {"type": "opencv", "index_or_path": 4, "width": 640, "height": 480, "fps": 30, "fourcc": "MJPG"}, "wrist": {"type": "opencv", "index_or_path": 6, "width": 640, "height": 480, "fps": 30}}' \
  --duration 15
```

---

## Training (reproduce from scratch)

```bash
# Record your own demonstrations
lerobot-record \
  --robot.type=so101_follower \
  --robot.port=/dev/ttyACM0 \
  --teleop.type=so101_leader \
  --teleop.port=/dev/ttyACM1 \
  --dataset.repo_id=YOUR_HF_USERNAME/desk-hero \
  --dataset.single_task="Pick up the pen and place it in the cup" \
  --dataset.num_episodes=50 \
  --dataset.episode_time_s=15 \
  --robot.cameras='{"overhead": {"type": "opencv", "index_or_path": 4, "width": 640, "height": 480, "fps": 30, "fourcc": "MJPG"}, "wrist": {"type": "opencv", "index_or_path": 6, "width": 640, "height": 480, "fps": 30}}'

# Train ACT policy
lerobot-train \
  --policy.type act \
  --dataset.repo_id lorenz-k/desk-hero-merged \
  --policy.repo_id YOUR_HF_USERNAME/pen_to_holder_act \
  --output_dir outputs/train/desk_hero_act \
  --batch_size 32 \
  --steps 10000
```

---

## Team

| Name | Role |
|---|---|
| Jannen | Software, Vision Systems, Training Pipeline |
| Lorenz | Hardware, Data Collection |
| [Teammate 3] | Hardware, Teleoperation |

**University:** Hochschule Bonn-Rhein-Sieg (H-BRS)

---

## Acknowledgements

- [Hugging Face LeRobot](https://github.com/huggingface/lerobot) - robot learning framework
- [H-BRS GPU Cluster](https://www.h-brs.de) - compute for training
- Berlin Robotics x AI Hackathon organizers
