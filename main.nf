include { count_kmers; get_hapmers } from './workflows/get_hapmers'
include { assemble } from './workflows/assemble'
include { eval_assembly_merqury; 
          eval_assembly_yak;
          eval_assembly_yak_premade;
          eval_gfastats;
          build_table} from './workflows/eval_assembly'

// Validate all required parameters
def validateParams() {
    def errors = []
    
    // Validate tool parameter
    if (!params.tool || !(params.tool in ['yak', 'merqury', 'both'])) {
        errors << "Invalid tool parameter. Must be one of: 'yak', 'merqury', or 'both'. Got: ${params.tool}"
    }
    
    // Always required parameters
    def alwaysRequired = [
        'dad_short_reads_R1', 'dad_short_reads_R2',
        'mom_short_reads_R1', 'mom_short_reads_R2', 
        'child_short_reads_R1', 'child_short_reads_R2',
        'child_long_reads',
        'method', 'dataset'
    ]
    
    alwaysRequired.each { param ->
        if (!params[param]) {
            errors << "Required parameter '${param}' is missing"
        }
    }
    
    // Assembly parameters - either from_assembly or assembly input files
    if (params.from_assembly) {
        def assemblyRequired = ['hap_mom_fasta', 'hap_dad_fasta', 'gfa_noseq_hapA', 'gfa_noseq_hapB']
        assemblyRequired.each { param ->
            if (!params[param]) {
                errors << "When from_assembly=true, required parameter '${param}' is missing"
            }
        }
    } else {
        def assemblyInputRequired = ['hap_mom_ids', 'hap_dad_ids', 'hap_unknown_ids']
        assemblyInputRequired.each { param ->
            if (!params[param]) {
                errors << "When from_assembly=false, required parameter '${param}' is missing"
            }
        }
    }
    
    // Tool-specific validations
    if (params.tool == 'yak' || params.tool == 'both') {
        if (params.from_yak) {
            def yakRequired = ['yak_mom', 'yak_dad']
            yakRequired.each { param ->
                if (!params[param]) {
                    errors << "When tool includes 'yak' and from_yak=true, required parameter '${param}' is missing"
                }
            }
        }
        // If from_yak=false, yak will use short reads (already validated above)
    }
    
    if (params.tool == 'merqury' || params.tool == 'both') {
        if (params.from_meryl) {
            def merylRequired = ['meryl_dad', 'meryl_mom', 'meryl_child_sr']
            merylRequired.each { param ->
                if (!params[param]) {
                    errors << "When tool includes 'merqury' and from_meryl=true, required parameter '${param}' is missing"
                }
            }
        }
        // If from_meryl=false, merqury will use short reads (already validated above)
    }
    
    if (errors.size() > 0) {
        error "Parameter validation failed:\n" + errors.join('\n')
    }
}

// Run parameter validation
validateParams()

workflow  {
    dad_sr = Channel.value(tuple file(params.dad_short_reads_R1), file(params.dad_short_reads_R2))
    mom_sr = Channel.value(tuple file(params.mom_short_reads_R1), file(params.mom_short_reads_R2))
    child_sr = Channel.value(tuple file(params.child_short_reads_R1), file(params.child_short_reads_R2))
    child_lr = Channel.value(file(params.child_long_reads))
    
    //Read parameters
    //Parameters depending on the tool
    if(params.tool == "yak" || params.tool == "both"){
        //If yak is already made, we can skip the counting step
        if (params.from_yak){
            yak_mom = Channel.value(file(params.yak_mom))
            yak_dad = Channel.value(file(params.yak_dad))
        }
    }
    if(params.tool == "merqury" || params.tool == "both"){
        //If merqury is already made, we can skip the counting step
        if (params.from_meryl){
            meryl_dad = Channel.value(file(params.meryl_dad))
            meryl_mom = Channel.value(file(params.meryl_mom))
            meryl_child_sr = Channel.value(file(params.meryl_child_sr))
        }
    }
    //Assembly
    //If the assembly is already made, we can skip the assembly step
    if(params.from_assembly){
        hap_mom_fasta = Channel.value(file(params.hap_mom_fasta))
        hap_dad_fasta = Channel.value(file(params.hap_dad_fasta))
        gfanoseq_hapA = Channel.value(file(params.gfa_noseq_hapA))
        gfanoseq_hapB = Channel.value(file(params.gfa_noseq_hapB))
    }
    else{
        hap_mom_ids = Channel.value(file(params.hap_mom_ids))
        hap_dad_ids = Channel.value(file(params.hap_dad_ids))
        hap_unknown_ids = Channel.value(file(params.hap_unknown_ids))
        //Else, let's assemble the haplotypes
        assemble(hap_mom_ids, hap_dad_ids, hap_unknown_ids, child_lr)
        hap_mom_fasta = assemble.out.hap_mom_fasta
        hap_dad_fasta = assemble.out.hap_dad_fasta
        gfanoseq_hapA= assemble.out.gfa_noseq_hapA
        gfanoseq_hapB= assemble.out.gfa_noseq_hapB
    }
    //Merqury evaluation
    if (params.tool == "merqury" || params.tool == "both"){
        if(!params.from_meryl){
            //If meryl is not already made, let's count the kmers
            count_kmers(dad_sr, mom_sr, child_sr)
            meryl_dad = count_kmers.out.meryl_dad
            meryl_mom = count_kmers.out.meryl_mom
            meryl_child_sr = count_kmers.out.meryl_child_sr
        }
        //Now we can get the hapmers and evaluate the assembly with merqury
        get_hapmers(meryl_dad,
            meryl_mom,
            meryl_child_sr)
        merqury_res = eval_assembly_merqury(get_hapmers.out.hapmers, meryl_child_sr,
            hap_mom_fasta, hap_dad_fasta)
    }
    else{
        merqury_res = false
    }
    //Yak evaluation
    if (params.tool == "yak" || params.tool == "both"){
        if(params.from_yak){
            //If yak is already made, let's just use it
            yak_res=eval_assembly_yak_premade(yak_mom, yak_dad,
                hap_mom_fasta, hap_dad_fasta)
        }
        else{
            //Else, let's conut the kmers and evaluate with yak
            yak_res = eval_assembly_yak(mom_sr, dad_sr,
                hap_mom_fasta, hap_dad_fasta)
        }
    }
    else{
        yak_res = false
    }
    //Gfastats for N50 retrieval.
    eval_res = eval_gfastats(gfanoseq_hapA, gfanoseq_hapB)
    //Build the final table with the results
    build_table(
        eval_res.gfastats_mom,
        eval_res.gfastats_dad,
        merqury_res ? merqury_res.phased_stats_hapA : null,
        merqury_res ? merqury_res.phased_stats_hapB : null,
        params.method,
        params.dataset,
        yak_res ? yak_res.result_mom : null,
        yak_res ? yak_res.result_dad : null
    )
}