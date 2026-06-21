#!/bin/bash
# LeRobot Hackathon Setup Script
# Reproduces the full environment for the "Desk Hero" pen-to-holder task

set -e

echo "=== Installing uv package manager ==="
curl -LsSf https://astral.sh/uv/install.sh | sh
export PATH="$HOME/.local/bin:$PATH"
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc

echo "=== Creating virtual environment with Python 3.12 ==="
uv venv --python 3.12
source .venv/bin/activate

echo "=== Installing LeRobot with all extras ==="
uv pip install -e ".[pusht,viz,smolvla]"

echo "=== Installing additional dependencies ==="
uv pip install pynput

echo "=== Logging into Hugging Face Hub ==="
echo "Run 'hf auth login' manually to authenticate"

echo "=== Adding robot serial port permissions ==="
sudo usermod -a -G dialout $USER

echo ""
echo "Setup complete! Activate with: source .venv/bin/activate"
echo "Clear ROS env with: unset PYTHONPATH; unset AMENT_PREFIX_PATH"
