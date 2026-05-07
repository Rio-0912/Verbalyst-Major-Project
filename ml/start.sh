#!/bin/bash
#SBATCH --job-name=sfe_pipeline
#SBATCH --partition=general
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=32
#SBATCH --mem=120G
#SBATCH --time=02:00:00

LOGFILE="run.log"

exec > >(tee -a $LOGFILE) 2>&1

echo "===================================="
echo "JOB START: $(date)"
echo "===================================="

module load python/3.11.14
module load ffmpeg 2>/dev/null || true

echo "Setting up virtual environment..."
if [ ! -d "env" ]; then
    python3 -m venv env
fi
source env/bin/activate

echo "Upgrading pip..."
pip install --upgrade pip

echo "Installing dependencies from req.txt..."
pip install -r req.txt

export LD_LIBRARY_PATH=$VIRTUAL_ENV/lib:$LD_LIBRARY_PATH

if [ ! -f "./audio.mp3" ]; then
    echo "WARNING: ./audio.mp3 not found. Server will still start — send audio via POST /audio."
fi

echo ""
echo "Starting FastAPI server..."
echo "Endpoints:"
echo "  POST http://0.0.0.0:8000/audio  — upload audio, runs full pipeline, returns JSON"
echo ""

python -m uvicorn main:app --host 0.0.0.0 --port 8000
