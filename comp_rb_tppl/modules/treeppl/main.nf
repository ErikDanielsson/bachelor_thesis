process compile_hostrep_treeppl {
    publishDir "gen_bin"

    input:
        val runid

    output:
        tuple val(runid), path("hostrep.${runid}.bin"), emit: hostrep_bin
    
    script:
    """
    tpplc $baseDir/models/host_repertoire.tppl \
        -m mcmc-lw-dk \
        --align \
        --cps none \
        --kernel \
        --drift 0.1\
        --mcmc-lw-gprob 0.0 \
        --output hostrep.${runid}.bin \
        --seed ${runid}
    chmod +x hostrep.${runid}.bin
    """
}

process run_hostrep_treeppl {
    publishDir "output"

    input:
        tuple val(runid), path(hostrep_bin), val(genid), path(phyjson_file) 
        val niter
    
    output:
        tuple val(runid), path("output.${genid}.${runid}.json"), emit: output_json
    
    script:
    """
    ./${hostrep_bin} ${phyjson_file} ${niter} > output.${genid}.${runid}.json
    """
}

process time_hostrep_treeppl {
    publishDir "output"

    input:
        tuple val(runid), path(hostrep_bin), val(genid), path(phyjson_file) 
        val niter

    output:
        tuple val(runid), path("time.treeppl.${genid}.${runid}.txt"), emit: time
        tuple val(runid), path("output.${genid}.${runid}.json"), emit: output_json
    
    script:
    """
    { time \
        ./${hostrep_bin} ${phyjson_file} ${niter} \
        1> output.${genid}.${runid}.json \
        2> /dev/null; \
    } 2> "time.treeppl.${genid}.${runid}.txt"
    """
}

process perf_hostrep_treeppl {
    publishDir "output"

    input:
        val runid
        val niter
        path hostrep_bin
        path phyjson_file
    
    output:
        path "time.treeppl.${runid}.txt"
        path "output.${runid}.json" 
    
    script:
    """
    { perf \
        ./${hostrep_bin} ${phyjson_file} ${niter} \
        1> output.${runid}.json \
        2> /dev/null; \
    } 2> "time.treeppl.${runid}.txt"
    """
}