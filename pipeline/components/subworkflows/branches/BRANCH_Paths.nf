
// BRANCH

// IMPORT

include { 
    viewMeta as viewMeta;
    } from "$params.importMap.functions/core/Utils"

include { 
    Config_Parse as ParseConfig;
    } from "${params.importMap.subworkflows}/core/Config_Parse"

include {
    STAGING as Command2Software2;
    } from "${params.importMap.subworkflows}/leaves/software2/command2/STAGING_Software2_Command2.nf"

////LEAF_IMPORT////


workflow SUBWORKFLOW {


    take: 

        Parameters

        Inputs


    main:

        ////LEAF_START////

        // SOFTWARE2 COMMAND2
        
        ConfigCommand2Software2 = ParseConfig( Parameters, [software: 'SOFTWARE2', command: 'COMMAND2', branch: 'PATHS'] )
        
        Command2Software2( Inputs, ConfigCommand2Software2 )

        ////LEAF_PARSE_RUN////

        | set { Processed }


    emit :

        Main = Processed

    }
