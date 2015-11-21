# Define and ensure directories exist
export CF=/opt/cloudfleet
export CF_VAR=${CF_ROOT}/var
mkdir -p ${CF_VAR}

# Debug settings
set -x 
