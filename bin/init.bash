# Define and ensure directories exist
export CF=/opt/cloudfleet
export CF_VAR=${CF}/var
mkdir -p ${CF_VAR} || echo "Failed to create ${CF_VAR}. Continuing."

# Debug settings
set -x

# Emit diagnostics
date 
uname -a 
lsb_release -a 
