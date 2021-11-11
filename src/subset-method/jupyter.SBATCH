#!/bin/bash

#SBATCH --job-name=jupyter
#SBATCH --nodes=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=10GB
## Uncomment the next line if you need GPU
##SBATCH --gres=gpu 
#SBATCH --time=03:00:00

module purge

set -e

# Note: on GCP the overlay directory does not exist
OVERLAY_DIRECTORY=/scratch/work/public/overlay-fs-ext3/
if [[ ! -d $OVERLAY_DIRECTORY ]]; then
OVERLAY_DIRECTORY=/scratch/wz2247/singularity/overlays/
fi

TMP_OVERLAY_SOURCE=overlay-0.5GB-200K.ext3

TMP_OVERLAY=${TMP_OVERLAY:-overlay-temp.ext3}

DATA_DIRECTORY=${DATA_DIRECTORY:-/scratch/cr3221/1006_Capstone_Project/data/raw}
IMAGE=${IMAGE:-/scratch/wz2247/singularity/images/pytorch_21.06-py3.sif}

if [[ ! -f $TMP_OVERLAY ]]; then

tmpdir="${TMPDIR:-/scratch/cr3221/1006_Capstone_Project/src}"

echo "Temporary overlay not found, automatically creating a new one."
cp "$OVERLAY_DIRECTORY/$TMP_OVERLAY_SOURCE.gz" "$tmpdir"
gunzip "$tmpdir/$TMP_OVERLAY_SOURCE.gz"
mv "$tmpdir/$TMP_OVERLAY_SOURCE" "$TMP_OVERLAY"

fi


port=$(shuf -i 10000-65500 -n 1)

/usr/bin/ssh -N -f -R $port:localhost:$port log-1
/usr/bin/ssh -N -f -R $port:localhost:$port log-2
/usr/bin/ssh -N -f -R $port:localhost:$port log-3

cat<<EOF

Jupyter server is running on: $(hostname)
Job starts at: $(date)

Step 1 :

If you are working in NYU campus, please open an iTerm window, run command

ssh -L $port:localhost:$port $USER@greene.hpc.nyu.edu

If you are working off campus, you should already have ssh tunneling setup through HPC bastion host, 
that you can directly login to greene with command

ssh $USER@greene

Please open an iTerm window, run command

ssh -L $port:localhost:$port $USER@greene

Step 2:

Keep the iTerm windows in the previouse step open. Now open browser, find the line with

The Jupyter Notebook is running at: $(hostname)

the URL is something: http://localhost:${port}/?token=XXXXXXXX (see your token below)

you should be able to connect to jupyter notebook running remotly on greene compute node with above url

EOF


unset XDG_RUNTIME_DIR
if [ "$SLURM_JOBTMP" != "" ]; then
    export XDG_RUNTIME_DIR=$SLURM_JOBTMP
fi

if [[ $(hostname -s) =~ ^g ]]; then nv="--nv"; fi


singularity exec --no-home -B $HOME/.ssh -B /scratch -B $PWD --nv \
    --cleanenv \
    --overlay $TMP_OVERLAY \
    --overlay overlay-base.ext3:ro \
    --overlay overlay-packages.ext3:ro \
    --overlay $DATA_DIRECTORY/UCLA-protest.sqf:ro \
    $IMAGE /bin/bash -c "source /ext3/conda/bootcamp; jupyter notebook --no-browser --port $port --notebook-dir=$(pwd)"
