
// BRANCH

// IMPORT

include { 
    viewMeta as viewMeta;
    } from "../../functions/core/Utils"

include { 
    Config_Parse as ParseConfig;
    } from "../core/Config_Parse"

include {
    STAGING as Command1Software1;
    } from "../leaves/software1/command1/STAGING_Software1_Command1.nf"

////LEAF_IMPORT////


workflow SUBWORKFLOW {


    take: 

        Parameters

        Inputs


    main:

        ////LEAF_START////

        // SOFTWARE1 COMMAND1
        
        ConfigCommand1Software1 = ParseConfig( Parameters, [software: 'SOFTWARE1', command: 'COMMAND1', branch: 'DATA'] )
        
        Command1Software1( Inputs, ConfigCommand1Software1 )

        ////LEAF_PARSE_RUN////

        | set { Processed }


    emit :

        Processed

    }
