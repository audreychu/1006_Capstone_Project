#!/bin/bash

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --time=8:00:00
#SBATCH --mem=16GB
#SBATCH --gres=gpu:1
#SBATCH --job-name=AL_Heur1_Method2

module purge

set -e

# Note: on GCP the overlay directory does not exist
OVERLAY_DIRECTORY=/scratch/work/public/overlay-fs-ext3/
if [[ ! -d $OVERLAY_DIRECTORY ]]; then
OVERLAY_DIRECTORY=/scratch/wz2247/singularity/overlays/
fi

TMP_OVERLAY_SOURCE=overlay-0.5GB-200K.ext3
#TMP_OVERLAY_SOURCE=overlay-pytorch-15GB-500k.ext3

TMP_OVERLAY=${TMP_OVERLAY:-overlay-temp_1_2.ext3}

DATA_DIRECTORY=${DATA_DIRECTORY:-/scratch/fnk9850}
IMAGE=${IMAGE:-/scratch/wz2247/singularity/images/pytorch_21.06-py3.sif}

if [[ ! -f $TMP_OVERLAY ]]; then

tmpdir="${TMPDIR:-/scratch/cr3221/1006_Capstone_Project/src}"

echo "Temporary overlay not found, automatically creating a new one."
cp "$OVERLAY_DIRECTORY/$TMP_OVERLAY_SOURCE.gz" "$tmpdir"
gunzip "$tmpdir/$TMP_OVERLAY_SOURCE.gz"
mv "$tmpdir/$TMP_OVERLAY_SOURCE" "$TMP_OVERLAY"

fi



singularity exec --no-home -B $HOME/.ssh -B /scratch -B $PWD --nv \
    --cleanenv \
    --overlay $TMP_OVERLAY \
    --overlay overlay-base.ext3:ro \
    --overlay overlay-packages.ext3:ro \
    --overlay $DATA_DIRECTORY/UCLA-protest.sqf:ro \
    $IMAGE /bin/bash -c "source activate /ext3/conda/bootcamp; python train.py --data_dir /UCLA-protest/ --batch_size 32 --lr 0.002 --print_freq 100 --epochs 170 --cuda --method_id 2 --heuristic_id 1"