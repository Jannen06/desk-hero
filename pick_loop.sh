#!/bin/bash
# Desk Hero - Continuous Pick-and-Place Loop
# Uses lerobot-record with policy inference for autonomous pen picking
# Press Ctrl+C to stop

# Unset ROS environment pollution
unset PYTHONPATH
unset AMENT_PREFIX_PATH

# ============================================================
# Configuration - change these to match your setup
# ============================================================
ROBOT_PORT="/dev/ttyACM0"
ROBOT_ID="follower_arm"
WRIST_CAM_INDEX=4
OVERHEAD_CAM_INDEX=2
EPISODE_DURATION=30
NUM_EPISODES=100

# Choose your policy (uncomment one):
# High resolution / more training steps (best results)
#POLICY_PATH="lorenz-k/desk-hero31-50k"
POLICY_PATH="Nikhil-Ravi/act_desk-hero"
# Medium training (faster inference)
# POLICY_PATH="lorenz-k/desk-hero31-20k"
# SmolVLA policy (experimental)
# POLICY_PATH="amrit97/pen_to_holder_final_act"

# ============================================================
# Run inference loop
# ============================================================

echo "============================================"
echo "  Desk Hero - Autonomous Pen Organizer"
echo "============================================"
echo ""
echo "Policy:   $POLICY_PATH"
echo "Robot:    $ROBOT_PORT ($ROBOT_ID)"
echo "Cameras:  wrist=$WRIST_CAM_INDEX, overhead=$OVERHEAD_CAM_INDEX"
echo "Duration: ${EPISODE_DURATION}s per episode"
echo ""
echo "Place a pen on the desk and press Enter to start."
echo "Press Ctrl+C to stop at any time."
echo ""

lerobot-record \
  --robot.type=so101_follower \
  --robot.port="$ROBOT_PORT" \
  --robot.id="$ROBOT_ID" \
  --robot.cameras="{\"wrist\": {\"type\": \"opencv\", \"index_or_path\": $WRIST_CAM_INDEX, \"width\": 640, \"height\": 480, \"fps\": 30, \"fourcc\": \"MJPG\"}, \"overhead\": {\"type\": \"opencv\", \"index_or_path\": $OVERHEAD_CAM_INDEX, \"width\": 640, \"height\": 480, \"fps\": 30, \"fourcc\": \"MJPG\"}}" \
  --policy.path="$POLICY_PATH" \
  --dataset.repo_id=lorenz-k/eval_desk-hero-merged4 \
  --dataset.single_task="Pick and place the pen in the cup" \
  --dataset.num_episodes="$NUM_EPISODES" \
  --dataset.episode_time_s="$EPISODE_DURATION" \
  --dataset.push_to_hub=false
