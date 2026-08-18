
// BRANCH

// IMPORT

include { 
    viewMeta as viewMeta;
    } from "../../functions/core/Utils"

include { 
    Config_Parse as ParseConfig;
    } from "../core/Config_Parse"

include {
    STAGING as SeqSeqkit;
    } from "../leaves/seqkit/seq/STAGING_Seqkit_Seq.nf"

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

        Processed

    }
