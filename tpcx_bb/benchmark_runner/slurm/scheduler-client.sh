set -e pipefail

USERNAME=$(whoami)
TPCX_BB_HOME=$HOME/tpcx-bb
LOGDIR=$HOME/dask-local-directory/logs


# BSQL setup
export INTERFACE="enp97s0f1"
export BLAZING_ALLOCATOR_MODE="existing"
export BLAZING_LOGGING_DIRECTORY=/tpcx-bb-data/tpcx-bb/blazing_log
rm -rf $BLAZING_LOGGING_DIRECTORY/*

bash $TPCX_BB_HOME/tpcx_bb/cluster_configuration/cluster-startup-slurm.sh SCHEDULER &
echo "STARTED SCHEDULER"
sleep 10

CONDA_ENV_NAME="rapids-tpcx-bb"
CONDA_ENV_PATH="/opt/conda/etc/profile.d/conda.sh"
source $CONDA_ENV_PATH
conda activate $CONDA_ENV_NAME

cd $TPCX_BB_HOME/tpcx_bb
echo "Starting waiter.."
python benchmark_runner/wait.py benchmark_runner/benchmark_config.yaml > $LOGDIR/wait.log
# echo "Starting load test.."
# python queries/load_test/tpcx_bb_load_test.py --config_file benchmark_runner/benchmark_config.yaml > $LOGDIR/load_test.log
echo "Starting E2E run.."
python benchmark_runner.py --config_file benchmark_runner/benchmark_config.yaml > $LOGDIR/benchmark_runner.log
