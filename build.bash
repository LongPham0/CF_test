#!/bin/bash


for i in $(cat /workspace/diff);
do
    cd $i
    # get settings for environment variables
    ev=$( echo "$ev"  | sed -nEe '/\ev:/!d;N;:loop' -e 's/.*\n//;${p;d;};N;P;/ev\n/D;bloop' buildSettings.yaml)
    ev=$( echo "$ev"  | sed -Ee 's/:[^:\/\/]/=/g;s/$//g;s/ *=/=/g' <<< $ev)
    ev=$( echo "$ev"  | sed -Ee 's/ /,/g' <<< $ev)

    #ev=$( echo "$ev"  | sed -n 's/.*/&,/;H;$x;$s/,\n/,/g;$s/\n\(.*\)/\1/;$s/\(.*\),/\1/;$p' <<< $ev)
    echo "ev:"
    echo $ev
    echo "\n"

    settings=$( echo "$settings"  | sed -nEe '/\settings:/!d;N;:loop' -e 's/.*\n//;${p;d;};N;P;/ev/D;bloop' buildSettings.yaml)
    echo "settings:"
    echo $settings
    echo "\n"
    #get function name
    functionName=$( echo "$functionName"  | sed -nEe '/\entryPointFN/!d;' -e 's/.*\n\r//;${p;d;};N;P;/\n\r/D;b' buildSettings.yaml)
    echo "functionName - parse1:"
    echo $functionName
    functionName=$( echo "$functionName"  | sed -Ee 's/.*://' <<< $functionName)
    echo "functionName - parse2:"
    echo $functionName
    #trim
    functionName=$( echo "$functionName"  | sed -Ee 's/^[ \t]*//;s/[ \t]*$//' <<< $functionName)
    echo "functionNames - parse3:"
    echo "functionNames:"
    echo $functionNames
    echo "\n"



    #get function name
    triggerTopic=$( echo "$triggerTopic"  | sed -nEe '/\entryPointFT/!d;' -e 's/.*\n\r//;${p;d;};N;P;/\n\r/D;b' buildSettings.yaml)
    echo "triggerTopic - parse1:"
    echo $triggerTopic
    triggerTopic=$( echo "$triggerTopic"  | sed -Ee 's/.*://' <<< $triggerTopic)
    echo "triggerTopic - parse2:"
    echo $triggerTopic
    #trim
    triggerTopic=$( echo "$triggerTopic"  | sed -Ee 's/^[ \t]*//;s/[ \t]*$//' <<< $triggerTopic)
    echo "triggerTopic - parse3:"
    echo "triggerTopic:"
    echo $triggerTopic
    echo "\n"

    #get entry point
    entryPoint=$( echo "$entryPoint"  | sed -nEe '/\entryPointExecute/!d;' -e 's/.*\n//;${p;d;};N;P;/\n/D;b' buildSettings.yaml)
    echo "entryPoint - parse1:"
    echo $entryPoint
    entryPoint=$( echo "$entryPoint"  | sed -Ee 's/.*://' <<< $entryPoint)
    echo "entryPoint - parse2:"
    echo $entryPoint
    #trim
    entryPoint=$( echo "$entryPoint"  | sed -Ee 's/^[ \t]*//;s/[ \t]*$//' <<< $entryPoint)
    echo "entryPoint - parse3:"
    echo $entryPoint
    echo "\n"

     #get memory
    memory=$( echo "$memory"  | sed -nEe '/\entryPointMemory/!d;' -e 's/.*\n\r//;${p;d;};N;P;/\n\r/D;b' buildSettings.yaml)
    echo "memory - parse1:"
    echo $memory
    memory=$( echo "$memory"  | sed -Ee 's/.*://' <<< $memory)
    echo "memory - parse2:"
    echo $memory
    #trim
    memory=$( echo "$memory"  | sed -Ee 's/^[ \t]*//;s/[ \t]*$//' <<< $memory)
    echo "memory - parse3:"
    echo "memory:"
    echo $memory
    echo "\n"

     #get runtime
    runtime=$( echo "$runtime"  | sed -nEe '/\entryPointRuntime/!d;' -e 's/.*\n\r//;${p;d;};N;P;/\n\r/D;b' buildSettings.yaml)
    echo "runtime - parse1:"
    echo $runtime
    runtime=$( echo "$runtime"  | sed -Ee 's/.*://' <<< $runtime)
    echo "runtime - parse2:"
    echo $runtime
    #trim
    runtime=$( echo "$runtime"  | sed -Ee 's/^[ \t]*//;s/[ \t]*$//' <<< $runtime)
    echo "runtime - parse3:"
    echo "runtime:"
    echo $runtime
    echo "\n"

    #get timeout
    timeout=$( echo "$timeout"  | sed -nEe '/\entryPointTimeout/!d;' -e 's/.*\n\r//;${p;d;};N;P;/\n\r/D;b' buildSettings.yaml)
    echo "timeout - parse1:"
    echo $timeout
    timeout=$( echo "$timeout"  | sed -Ee 's/.*://' <<< $timeout)
    echo "timeout - parse2:"
    echo $timeout
    #trim
    timeout=$( echo "$timeout"  | sed -Ee 's/^[ \t]*//;s/[ \t]*$//' <<< $timeout)
    echo "timeout - parse3:"
    echo "timeout:"
    echo $timeout
    echo "\n"

    substitationEnvVariables="DB_CLIENT=${DB_CLIENT},DB_HOST=${DB_HOST},DB_HOST=${DB_HOST},DB_USER=${DB_USER},DB_PASSWORD=${DB_PASSWORD},BUCKET=${BUCKET}"


    if [ -z "$ev" ]
    then
          echo "${substitationEnvVariables}"
          completeEV="${substitationEnvVariables}"
    else
          echo "${ev},${substitationEnvVariables}"
          completeEV="${ev},${substitationEnvVariables}"
    fi

    # check if triggertopic exists
    gcloud pubsub topics list --filter=$triggerTopic

    triggerTopicExist=$( echo "$triggerTopic"  | gcloud pubsub topics list --filter=$triggerTopic)

    if [ $triggerTopicExist = "Listed 0 items." ];
    then
        # create topic
        gcloud pubsub topics create $triggerTopic
    fi

     if [ -z "$completeEV" ]
    then
          echo "deploy cloud function without ev"
          # deploy cloud function without ev
          gcloud functions deploy $functionName --runtime=$runtime --timeout=$timeout --trigger-topic=$triggerTopic --entry-point=$entryPoint --region=europe-west3 --memory=$memory
    else
          echo "deploy cloud function with ev"
          # deploy cloud function with ev
          gcloud functions deploy $functionName --runtime=$runtime --timeout=$timeout --trigger-topic=$triggerTopic --entry-point=$entryPoint --set-env-vars=$completeEV --region=europe-west3 --memory=$memory
    fi
    cd ..
done
