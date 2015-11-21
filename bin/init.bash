# Define and ensure directories exist
export CF=/opt/cloudfleet
export CF_VAR=${CF}/var
mkdir -p ${CF_VAR}

# Debug settings
set -x 
