#!/bin/bash
# Continuous pick-and-place loop for SO-101
# Press Ctrl+C to stop between episodes

POLICY_PATH="jan024/pen_to_holder_act"
ROBOT_PORT="/dev/ttyACM0"
CALIB_DIR="/home/jannen/.cache/huggingface/lerobot/calibration"
EPISODE_DURATION=15  # seconds per pick attempt
RESET_PAUSE=5        # seconds to reset the scene between picks

# Unset ROS environment pollution
unset PYTHONPATH
unset AMENT_PREFIX_PATH

# Activate venv
source ~/Documents/Jannen/Berlin\ Hackathon/lerobot/.venv/bin/activate

echo "Starting continuous pick-and-place loop"
echo "Place pen on desk, then press Enter to begin each episode"
echo "Press Ctrl+C anytime to stop"
echo ""

pick_count=0

while true; do
    pick_count=$((pick_count + 1))
    echo "=== Episode $pick_count ==="
    echo "Place a pen on the desk and press Enter..."
    read -r

    echo "Running rollout for ${EPISODE_DURATION}s..."
    lerobot-rollout \
        --policy.type act \
        --policy.pretrained_path "$POLICY_PATH" \
        --robot.type=so101_follower \
        --robot.id=follower \
        --robot.port="$ROBOT_PORT" \
        --robot.calibration_dir="$CALIB_DIR" \
        --robot.cameras='{"overhead": {"type": "opencv", "index_or_path": 4, "width": 640, "height": 480, "fps": 30, "fourcc": "MJPG"}, "wrist": {"type": "opencv", "index_or_path": 6, "width": 640, "height": 480, "fps": 30}}' \
        --duration "$EPISODE_DURATION"

    echo "Episode $pick_count done. Resetting in ${RESET_PAUSE}s..."
    sleep "$RESET_PAUSE"
    echo ""
done
