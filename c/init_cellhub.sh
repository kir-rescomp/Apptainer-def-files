#!/bin/bash
# Source this file to enable cellhub in current shell

# Set the container path
export CELLHUB_CONTAINER="/gpfs3/well/sansom/projects/cellhub.aif"

# Set bind paths
export APPTAINER_BIND="/gpfs3/well,/gpfs3/users"

# Create a function instead of a script
cellhub() {
    apptainer exec --pwd "$PWD" "$CELLHUB_CONTAINER" cellhub "$@"
}

# Export the function so it's available in the shell
export -f cellhub

echo "cellhub environment loaded. Use 'cellhub <command>' to run."
