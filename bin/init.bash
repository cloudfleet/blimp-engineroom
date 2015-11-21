if [ -z "$CF_INITIALIZED_P" ] ; then
    # Define and ensure directories exist
    export CF=/opt/cloudfleet
    export CF_VAR=${CF}/var
    mkdir -p "${CF_VAR}" || echo "Failed to create ${CF_VAR}. Continuing."

    # Debug settings

    ## Emit diagnostics
    date 
    uname -a 
    lsb_release -a
    lsblk --fs

    ## Log all command invocations
    set -x

fi

export CF_INITIALIZED_P=true


