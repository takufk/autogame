#!/bin/bash

BRANCH=$1
GAMENUM=$2
OPP=$3

source ../config
export PATH=$LOGANALYZER3_DIR:$PATH

cd $OUR_TEAM
git fetch && git checkout $BRANCH && git pull
./bootstrap
./configure --with-librcsc=$LIBRCSC_DIR
make

#your team directory
TEAM_L="'${OUR_TEAM}/src/start.sh -t develop --offline-logging'"

mkdir -p ${LOG_DIR}
rm ${LOG_DIR}/*

# start loop
TEAM_R="$HOME/rcss/teams/$OPP/start.sh"
SYNCH="true"
if [[ ${TEAM_R} == *fractals* ]]; then
	SYNCH="false"
elif [[ ${TEAM_R} == *fraunited* ]]; then
	SYNCH="false"
fi

rcssserver server::auto_mode = 1 \
       server::synch_mode = $SYNCH \
       server::team_l_start = ${TEAM_L} server::team_r_start = ${TEAM_R} \
       server::kick_off_wait = 50 \
       server::half_time = 300 \
       server::nr_normal_halfs = 2 server::nr_extra_halfs = 0 \
       server::penalty_shoot_outs = 0 \
       server::game_logging = 1 server::text_logging = 1 \
       server::game_log_dir = "${LOG_DIR}" server::text_log_dir = "${LOG_DIR}" \
       server::game_log_compression = 1 \
       server::text_log_compression = 1

# kill process
${OUR_TEAM}/kill
${HOME}/rcss/teams/${OPP}/kill

# rename game logs
mkdir -p ${LOG_DIR}/game${GAMENUM}
mv /tmp/*.ocl ${LOG_DIR}/game${GAMENUM}
tar czf ${LOG_DIR}/game${GAMENUM}.ocl.tar.gz ${LOG_DIR}/game${GAMENUM}
YEAR=`date +%Y`
mv ${LOG_DIR}/${YEAR}*.rcg.gz ${LOG_DIR}/game${GAMENUM}.rcg.gz
mv ${LOG_DIR}/${YEAR}*.rcl.gz ${LOG_DIR}/game${GAMENUM}.rcl.gz

# log analyze
cd ${LOG_DIR}
loganalyzer3 ${LOG_DIR}/ --side l
mv *csv game${GAMENUM}.csv