include { count_kmers; get_hapmers } from './workflows/get_hapmers'
include { assemble } from './workflows/assemble'
include { eval_assembly_merqury; 
          eval_assembly_yak;
          eval_assembly_yak_premade;
          eval_gfastats;
          build_table} from './workflows/eval_assembly'

workflow  {
    dad_sr = Channel.value(tuple file(params.dad_short_reads_R1), file(params.dad_short_reads_R2))
    mom_sr = Channel.value(tuple file(params.mom_short_reads_R1), file(params.mom_short_reads_R2))
    child_sr = Channel.value(tuple file(params.child_short_reads_R1), file(params.child_short_reads_R2))
    child_lr = Channel.value(file(params.child_long_reads))
    

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

    //If the assembly is already made, we can skip the assembly step
    if(params.from_assembly){
        hap_mom_fasta = Channel.value(file(params.hap_mom_fasta))
        hap_dad_fasta = Channel.value(file(params.hap_dad_fasta))
        
    }
    else{
        hap_mom_ids = Channel.value(file(params.hap_mom_ids))
        hap_dad_ids = Channel.value(file(params.hap_dad_ids))
        hap_unknown_ids = Channel.value(file(params.hap_unknown_ids))
        //Else, let's assemble the haplotypes
        assemble(hap_mom_ids, hap_dad_ids, hap_unknown_ids, child_lr)
        hap_mom_fasta = assemble.out.hap_mom_fasta
        hap_dad_fasta = assemble.out.hap_dad_fasta
    }

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
        merqury_res=eval_assembly_merqury(get_hapmers.out.hapmers, meryl_child_sr,
            hap_mom_fasta, hap_dad_fasta)
        //eval_assembly_merqury.out.view()
    }
    

    if (params.tool == "yak" || params.tool == "both"){
        if(params.from_yak){
            //If yak is already made, let's just use it
            yak_res=eval_assembly_yak_premade(yak_mom, yak_dad,
                hap_mom_fasta, hap_dad_fasta)
            eval_assembly_yak_premade.out.result_dad.view()
            eval_assembly_yak_premade.out.result_mom.view()
        }
        else{
            //Else, let's conut the kmers and evaluate with yak
            eval_assembly_yak(mom_sr, dad_sr,
                hap_mom_fasta, hap_dad_fasta)
            eval_assembly_yak.out.result_dad.view()
            eval_assembly_yak.out.result_mom.view()
        }
    }

    gfanoseq_hapA = Channel.value(file(params.gfa_noseq_hapA))
    gfanoseq_hapB = Channel.value(file(params.gfa_noseq_hapB))


    eval_res=eval_gfastats(gfanoseq_hapA,gfanoseq_hapB)

    hapA_gfastats = eval_res.gfastats_mom
    hapB_gfastats = eval_res.gfastats_dad

    hapA_gfastats.view()
    hapB_gfastats.view()
    
    hapA_phased_stats= merqury_res.phased_stats_hapA
    hapB_phased_stats= merqury_res.phased_stats_hapB

    hapA_phased_stats.view()
    hapB_phased_stats.view()

    method = Channel.value(file(params.method))
    dataset = Channel.value(file(params.dataset))

    yak_hapA= yak_res.result_mom
    yak_hapB= yak_res.result_dad

    yak_hapA.view()
    yak_hapB.view()


    build_table(hapA_gfastats, hapB_gfastats,
    hapA_phased_stats, hapB_phased_stats , method, dataset, yak_hapA, yak_hapB)

}