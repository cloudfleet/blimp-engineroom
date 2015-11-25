if [[ -z "$CF_INITIALIZED_P" ]] ; then
    # Define and ensure directories exist
    export CF=/opt/cloudfleet
    export CF_VAR=${CF}/var
    export CF_DATA=${CF}/data
    export CF_LOGS=${CF_DATA}/logs
    export CF_ENGINEROOM=${CF}/engineroom
    export CF_BIN=${CF_ENGINEROOM}/bin

    # Ensure directories exist
    mkdir -p "${CF_VAR}" || echo "Failed to create ${CF_VAR}. Continuing."

    # Debug settings

    ## Emit diagnostics
    date 
    uname -a 
    lsb_release -a
    lsblk --fs
    echo Initial ${CF_ENGINEROOM} git status
    (cd ${CF_ENGINEROOM} && git status)

    ## Log all command invocations
    set -x

fi

export CF_INITIALIZED_P=true


