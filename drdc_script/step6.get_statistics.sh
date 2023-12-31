#!/bin/bash

# this scriptis calculate the mean, median, se, sign test and ttest for each PNC_PNR output
# the output is ./dRdC_dat/HON*/PNC_PNR.target_*.control_*.[charge|MY].Rout

WORK_DIR=$(pwd)
TARGET_CLADES=$(ls clades.target_*.control*.txt | cut -d"." -f2 | cut -d"_" -f2- | sort | uniq)

for TARGET in ${TARGET_CLADES[@]} ; do
  cd ${WORK_DIR}
  CONTROL_CLADES=$(ls clades.target_${TARGET}.control_*.txt | cut -d"." -f3 | cut -d"_" -f2- | sort | uniq)
  for CONTROL in ${CONTROL_CLADES[@]} ; do
    echo ":::::: Target = $TARGET, Control = $CONTROL ::::::"
    while read LINE ; do
      if [[ ${LINE:0:3} == 'HON' ]] ; then

        HON=$(echo $LINE | cut -d"=" -f1)
        HON_DIR=$(echo $LINE | cut -d"=" -f2)
        echo ">>> $HON"
        cd ${WORK_DIR}/dRdC_dat/${HON}

	# statistics
	COMB="target_${TARGET}.control_${CONTROL}"
	for CLASS in 'charge' 'MY' ; do
	  Rscript ${WORK_DIR}/scripts/mean_se_median_signtest_ttest.R PNC_PNR.${COMB}.${CLASS}.txt > PNC_PNR.${COMB}.${CLASS}.Rout
	  # print out pvalues for preview
	  # sign test
  	  pval=$(grep -A 1 "data:  num" PNC_PNR.${COMB}.${CLASS}.Rout | tail -1 )
	  if [[ $pval == *\<* ]] ; then
	    echo "    $CLASS sign-test: < $( echo $pval | cut -d"<" -f2 | sed 's/ //g')"
	  else
	    echo "    $CLASS sign-test: $( echo $pval | cut -d"=" -f4 | sed 's/ //g')"
	  fi
	  # t-test
	  pval=$(grep -A 1 "data:  dat" PNC_PNR.${COMB}.${CLASS}.Rout | tail -1 )
	  if [[ $pval == *\<* ]] ; then
	    echo "    $CLASS t-test: < $( echo $pval | cut -d"<" -f2 | sed 's/ //g')"
	  else
	    echo "    $CLASS t-test: $( echo $pval | cut -d"=" -f4 | sed 's/ //g')"
	  fi
	done

      fi
    done < ${WORK_DIR}/dRdC_pipeline.cfg
  done
done
