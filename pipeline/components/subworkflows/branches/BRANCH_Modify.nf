
// BRANCH

// IMPORT

include { 
    viewMeta as viewMeta;
    } from "$params.importMap.functions/core/Utils"

include { 
    Config_Parse as ParseConfig;
    } from "${params.importMap.subworkflows}/core/Config_Parse"

include {
    STAGING as SeqSeqkit;
    } from "${params.importMap.subworkflows}/leaves/seqkit/seq/STAGING_Seqkit_Seq.nf"

////LEAF_IMPORT////


workflow SUBWORKFLOW {


    take: 

        Parameters

        Inputs


    main:

        ////LEAF_START////

        // SEQKIT SEQ
        
        ConfigSeqSeqkit = ParseConfig( Parameters, [software: 'SEQKIT', command: 'SEQ', branch: 'MODIFY'] )
        
        SeqSeqkit( Inputs, ConfigSeqSeqkit )

        ////LEAF_PARSE_RUN////

        | set { Processed }


    emit :

        Main = Processed

    }
