## Working Commands

### Rollout (ACT policy)
lerobot-rollout \
  --policy.type act \
  --policy.pretrained_path jan024/pen_to_holder_act \
  --robot.type=so101_follower \
  --robot.id=follower \
  --robot.port=/dev/ttyACM0 \
  --robot.calibration_dir=~/.cache/huggingface/lerobot/calibration \
  --robot.cameras='{"overhead": {"type": "opencv", "index_or_path": 4, "width": 640, "height": 480, "fps": 30, "fourcc": "MJPG"}, "wrist": {"type": "opencv", "index_or_path": 6, "width": 640, "height": 480, "fps": 30}}' \
  --duration 15

### Training (ACT)
lerobot-train \
  --policy.type act \
  --dataset.repo_id lorenz-k/desk-hero-merged \
  --policy.repo_id jan024/pen_to_holder_act \
  --output_dir outputs/train/pen_to_holder_act \
  --rename_map '{"observation.images.overhead": "observation.images.overhead", "observation.images.wrist": "observation.images.wrist"}' \
  --policy.input_features '{"observation.images.overhead": {"type": "VISUAL", "shape": [3, 480, 640]}, "observation.images.wrist": {"type": "VISUAL", "shape": [3, 480, 640]}, "observation.state": {"type": "STATE", "shape": [6]}}' \
  --policy.output_features '{"action": {"type": "ACTION", "shape": [6]}}' \
  --batch_size 32 \
  --steps 10000

### Merge datasets
lerobot-edit-dataset \
  --operation.type merge \
  --operation.repo_ids '["lorenz-k/desk-hero24", "lorenz-k/desk-hero25", "lorenz-k/desk-hero29"]' \
  --new_repo_id lorenz-k/desk-hero-merged