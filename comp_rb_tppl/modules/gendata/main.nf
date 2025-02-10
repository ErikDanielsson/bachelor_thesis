process generate_trees_and_interactions {
    publishDir "gen_data"

    input:
        val genid
        val nsymbiont
        val nhost

    output:
        tuple val(genid), path("symbiont_tree.${genid}.tre"), emit: symbiont_tree
        tuple val(genid), path("host_tree.${genid}.tre"), emit: host_tree 
        tuple val(genid), path("interactions.${genid}.csv"), emit: interactions_csv 
        tuple val(genid), path("interactions.${genid}.nex"), emit: interactions_nex

    script:
    """
    Rscript $baseDir/scripts/generate_data.R ${genid} ${nsymbiont} ${nhost}
    """
}

process rev_annotate_tree {
    publishDir "gen_data"

    input:
        val(genid)
        path(input)

    output:
        tuple val(genid), path("${input.getBaseName()}" + ".rev.tre"), emit: rev_tree

    script:
    """
    rb $baseDir/scripts/annotate_tree.Rev --args ${input} --args ${input.baseName}.rev.tre
    """
}

process generate_phyjson {
    input:
        val genid
        path symbiont_tree_file 
        path host_tree_file
        path interactions_csv_file

    output:
        tuple val(genid), path("dirty_host_parasite.${genid}.json"), emit: dirty_phyjson
    
    script:
    """
    Rscript $baseDir/scripts/transform_data_to_phyjson.R ${symbiont_tree_file} ${host_tree_file} ${interactions_csv_file} dirty_host_parasite.${genid}.json
    """
}

process clean_phyjson {
    publishDir "gen_data"

    input:
        val genid
        path dirty_phyjson

    output:
        tuple val(genid), path("host_parasite.${genid}.json"), emit: phyjson

    script:
    """
    python $baseDir/scripts/clean_phyjson.py ${dirty_phyjson} "host_parasite.${genid}.json"
    """
}