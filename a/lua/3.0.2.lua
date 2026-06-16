-- -*- lua -*-
help([==[

Description
===========
AlphaFold can predict protein structures with atomic accuracy even where no similar structure is known

More information
================
 - Homepage: https://github.com/google-deepmind/alphafold3
]==])

whatis([==[Description: AlphaFold can predict protein structures with atomic accuracy even where no similar structure is known]==])
whatis([==[Homepage: https://github.com/google-deepmind/alphafold3]==])

conflict("AlphaFold")

local version         = "3.0.2"
local alphafold_root  = "/gpfs3/apps/kir/eb/containers"
local container       = pathJoin(alphafold_root, "alphafold3-" .. version .. ".sif")

-- Core paths
setenv("ALPHAFOLD_ROOT",      alphafold_root)
setenv("ALPHAFOLD_CONTAINER", container)

-- Bind required GPFS paths into the container, preserving any paths the user
-- already has set (e.g. from ~/.bashrc or another module)
local existing_bind = os.getenv("APPTAINER_BIND") or ""
local af3_bind      = "/gpfs3/well,/gpfs3/users"
if existing_bind ~= "" then
    af3_bind = existing_bind .. "," .. af3_bind
end
pushenv("APPTAINER_BIND", af3_bind)

-- XLA / GPU settings
-- xla_gpu_enable_triton_gemm=false avoids known numerical issues with AF3 on some GPU architectures
pushenv("XLA_FLAGS",                      "--xla_gpu_enable_triton_gemm=false")
pushenv("XLA_PYTHON_CLIENT_PREALLOCATE",  "true")
pushenv("XLA_PYTHON_CLIENT_MEM_FRACTION", "0.95")

-- Expose run_alphafold.py as a shell function via the container runscript
set_shell_function("run_alphafold.py",
    string.format('apptainer run --nv %s python3 /app/alphafold/run_alphafold.py "$@"', container)
)

-- CPU-only variant: omit --nv and force JAX onto the CPU backend.
-- XLA GPU prealloc/mem-fraction flags above are ignored on CPU.
set_shell_function("run_alphafold_cpu.py",
    string.format('apptainer run --env JAX_PLATFORMS=cpu %s python3 /app/alphafold/run_alphafold.py "$@"', container)
)
