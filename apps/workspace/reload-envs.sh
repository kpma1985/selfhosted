docker exec workspace "for f in /root/envs/*.yaml; do mamba env create -f $f || mamba env update -f $f --prune; done"