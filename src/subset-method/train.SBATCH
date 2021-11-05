#!/bin/bash

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --time=2:00:00
#SBATCH --mem=10GB
#SBATCH --gres=gpu
#SBATCH --job-name=AL_similarity_heuristic

module purge

set -e

# Note: on GCP the overlay directory does not exist
OVERLAY_DIRECTORY=/scratch/work/public/overlay-fs-ext3/
if [[ ! -d $OVERLAY_DIRECTORY ]]; then
OVERLAY_DIRECTORY=/scratch/wz2247/singularity/overlays/
fi

TMP_OVERLAY_SOURCE=overlay-0.5GB-200K.ext3

TMP_OVERLAY=${TMP_OVERLAY:-overlay-temp.ext3}

DATA_DIRECTORY=${DATA_DIRECTORY:-/mnt/ram}
IMAGE=${IMAGE:-/scratch/wz2247/singularity/images/pytorch_21.06-py3.sif}

if [[ ! -f $TMP_OVERLAY ]]; then

echo "Temporary overlay not found, automatically creating a new one."
cp "$OVERLAY_DIRECTORY/$TMP_OVERLAY_SOURCE.gz" "$TMPDIR"
gunzip "$TMPDIR/$TMP_OVERLAY_SOURCE.gz"
mv "$TMPDIR/$TMP_OVERLAY_SOURCE" "$TMP_OVERLAY"

fi



singularity exec --no-home -B $HOME/.ssh -B /scratch -B $PWD --nv \
    --cleanenv \
    --overlay $TMP_OVERLAY \
    --overlay overlay-base.ext3:ro \
    --overlay overlay-packages.ext3:ro \
    --overlay $DATA_DIRECTORY/UCLA-protest.sqf:ro \
    $IMAGE /bin/bash -c "source /ext3/env.sh; python train.py \
    --data_dir UCLA-protest/ --batch_size 32 --lr 0.002 --print_freq 100 --epochs 100 --cuda"
    


