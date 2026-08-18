#!/usr/bin/env nextflow

/* enable dsl syntax extension (should be applied by default) */
nextflow.enable.dsl = 2


// FUNCTIONS

params.PUBLISH = true

include { 
    parseSupplementary as parseSupplementary;
    viewMeta as viewMeta;
    prepBridge as prepBridge;
    } from "./components/functions/core/Utils"

// SUBWORKFLOWS

include { 
    Info_Parse as ParseInfo;
    } from "./components/subworkflows/core/Info_Parse"

include { 
    Dummy_Add as AddDummy;
    } from "./components/subworkflows/core/Dummy_Add"

include {
    SUBWORKFLOW as Data;
    } from "./components/subworkflows/branches/BRANCH_Data"

include {
    SUBWORKFLOW as Paths;
    } from "./components/subworkflows/branches/BRANCH_Paths"

include {
    SUBWORKFLOW as Modify;
    } from "./components/subworkflows/branches/BRANCH_Modify"

////BRANCH_IMPORT////


workflow { 

    main:


        // SETUP

        parseSupplementary( params.supplementary, params )

        Parameters = params

        EXECUTE  = params.execute.split(',')

        RUN_ALL  = EXECUTE.contains('all')

        RUN_FEATURE = RUN_ALL ?: EXECUTE.contains('feature')

        RUN_DATA = RUN_ALL ?: EXECUTE.contains('data')

        RUN_PATHS = RUN_ALL ?: EXECUTE.contains('paths')

        ////BRANCH_FILTER////


        // MAIN

        println('PARSING INPUTS...')

        def InputMeta = params.INPUT.MAIN + [
            INFO     : params.inputs,
            TYPE     : "SAMPLES",
            DETAILED : true,
            EXISTS   : ['path'],
            ]

        Inputs = ParseInfo( InputMeta )

        Inputs = AddDummy(Inputs, [ dummy : 'optional.dummy' ])

        // SUPPLEMENTARY

        def SUPPLEMENTARYMeta = [
            INFO : params.SUPPLEMENTARY,
            TYPE : "SUPPLEMENTARY",
            ]

        SUPPLEMENTARY = ParseInfo( SUPPLEMENTARYMeta )


        // BRANCHES

        println('RUNNING BRANCHES...')
        
        // BRANCH( Inputs|BRANCH.out.Main)

        Data( Parameters, Inputs | filter { RUN_DATA }  )

        Paths( Parameters, Inputs | filter { RUN_PATHS }  )

        Modify( Parameters, Paths.out )

        ////BRANCH_RUN////


    /*
    */


    publish: 
    
        Data = Data.out.map{ coreMeta -> 
        
            def indexMeta = [:]
            
            def indexMetaNew = prepBridge( 
                coreMeta  : coreMeta, 
                indexMeta : indexMeta, 
                BASIC     : false, 
                UPDATE    : false, 
                INTERIM   : false,
                )      
            
            return indexMetaNew }

        Paths = Paths.out.map{ coreMeta -> 
        
            def indexMeta = [
                'head': coreMeta.OUTPUTS.SOFTWARE2.COMMAND2.PATHS.main,
                ]            
        
            def indexMetaNew = prepBridge( 
                coreMeta  : coreMeta, 
                indexMeta : indexMeta, 
                BASIC     : false, 
                UPDATE    : false, 
                INTERIM   : false,
                )      
            
            return indexMetaNew }

        Modify = Modify.out.map{ coreMeta -> 
        
            def indexMeta = [:]
            
            def indexMetaNew = prepBridge( 
                coreMeta  : coreMeta, 
                indexMeta : indexMeta, 
                BASIC     : false, 
                UPDATE    : false, 
                INTERIM   : false,
                )      
            
            return indexMetaNew }

        ////BRANCH_PUBLISH////

    }


output {

        Data { 
            enabled      false
            mode         'copy'
            overwrite    'standard'
            ignoreErrors false
            path { indexMeta -> 
                return "data/$indexMeta.ID/$indexMeta.TAG" }
            index {
                path   'bridge-data.csv'
                header true
                sep    '\t'
                }
            }

        Paths { 
            enabled      true
            mode         'copy'
            overwrite    'standard'
            ignoreErrors false
            path { indexMeta -> 
                return "paths/$indexMeta.ID/$indexMeta.TAG" }
            index {
                path   'bridge-paths.csv'
                header true
                sep    '\t'
                }
            }

        Modify { 
            enabled      false
            mode         'copy'
            overwrite    'standard'
            ignoreErrors false
            path { indexMeta -> 
                return "modify/$indexMeta.ID/$indexMeta.TAG" }
            index {
                path   'bridge-modify.csv'
                header true
                sep    '\t'
                }
            }

        ////BRANCH_OUTPUT////

    }
