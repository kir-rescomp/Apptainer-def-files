-- -*- lua -*-
help([==[

Description
===========
AlphaFold 3 can predict the structure of proteins, DNA, RNA, and ligands with atomic accuracy.

More information
================
 - Homepage: https://github.com/google-deepmind/alphafold3
]==])

whatis([==[Description: AlphaFold 3 can predict the structure of proteins, DNA, RNA, and ligands]==])
whatis([==[Homepage: https://github.com/google-deepmind/alphafold3]==])



local version = "3.0.1"
local alphafold_root = "/gpfs3/well/kir/projects/mirror/containers/Apptainer-def-files/a/"
local container = pathJoin(alphafold_root, "alphafold3-" .. version .. ".sif")

-- Set environment variables
setenv("ALPHAFOLD_ROOT", alphafold_root)
setenv("ALPHAFOLD_CONTAINER", container)

-- run_alphafold.py is invoked via the container's runscript
-- Use 'apptainer run' so the %runscript entry point is used
set_shell_function("run_alphafold.py",
    string.format('apptainer run --nv %s python3 /app/alphafold/run_alphafold.py "$@"', container)
)

-- GPU / XLA settings
pushenv("XLA_FLAGS", "--xla_gpu_enable_triton_gemm=false")
pushenv("XLA_PYTHON_CLIENT_PREALLOCATE", "true")
pushenv("XLA_CLIENT_MEM_FRACTION", "0.95")

conflict("AlphaFold")
