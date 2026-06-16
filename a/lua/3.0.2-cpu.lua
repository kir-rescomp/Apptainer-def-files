-- -*- lua -*-
help([==[

Description
===========
AlphaFold can predict protein structures with atomic accuracy even where no
similar structure is known.

This is the CPU-only variant: it runs inference on the CPU backend (no GPU
required). The container is built with JAX_PLATFORMS=cpu and a source patch
that tolerates the absence of a GPU device. Useful for small/short inputs or
when GPU partitions are saturated; inference is substantially slower than GPU.

More information
================
 - Homepage: https://github.com/google-deepmind/alphafold3
]==])

whatis([==[Description: AlphaFold (CPU-only) protein structure prediction]==])
whatis([==[Homepage: https://github.com/google-deepmind/alphafold3]==])

local version        = "3.0.2"
local alphafold_root = "/gpfs3/apps/kir/eb/containers"
local container      = pathJoin(alphafold_root, "alphafold3-" .. version .. "-cpu.sif")

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

-- CPU backend. The image already exports JAX_PLATFORMS=cpu in %environment;
-- set it here too so the CPU intent is explicit and robust to image rebuilds.
pushenv("JAX_PLATFORMS", "cpu")

-- NOTE: no --nv (CPU only) and no GPU/XLA memory flags. The XLA_PYTHON_CLIENT_*
-- prealloc/mem-fraction knobs are GPU-memory settings and are inert on CPU;
-- CPU memory is governed entirely by the Slurm --mem allocation.

-- run_alphafold.py is invoked via the container's runscript (no --nv).
set_shell_function("run_alphafold.py",
    string.format('apptainer run %s python3 /app/alphafold/run_alphafold.py "$@"', container)
)

conflict("AlphaFold")
