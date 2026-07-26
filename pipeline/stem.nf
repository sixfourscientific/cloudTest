#!/usr/bin/env nextflow

/* enable dsl syntax extension (should be applied by default) */
nextflow.enable.dsl = 2




// IMPORTS

import java.nio.file.Files

// FUNCTIONS

params.PUBLISH = true

params.importMap = [ 'subworkflows', 'functions' ]

        .collectEntries { subDir -> 

                def subPath = [ workflow.projectDir, 'components', subDir, ]
                
                        .join('/')
                
                return [ (subDir) : subPath ] }


include { 
    parseSupplementary as parseSupplementary;
    viewMeta as viewMeta;
    prepBridge as prepBridge;
    } from "$params.importMap.functions/core/Utils"

// SUBWORKFLOWS

include { 
    Info_Parse as ParseInfo;
    } from "${params.importMap.subworkflows}/core/Info_Parse"

include {
    SUBWORKFLOW as Data;
    } from "${params.importMap.subworkflows}/branches/BRANCH_Data"

include {
    SUBWORKFLOW as Paths;
    } from "${params.importMap.subworkflows}/branches/BRANCH_Paths"

include {
    SUBWORKFLOW as Modify;
    } from "${params.importMap.subworkflows}/branches/BRANCH_Modify"

////BRANCH_IMPORT////


// SETUP

parseSupplementary( params.supplementary, params )

Parameters = params

EXECUTE  = params.execute.split(',')

RUN_ALL  = EXECUTE.contains('all')

RUN_DATA = RUN_ALL ?: EXECUTE.contains('data')

RUN_PATHS = RUN_ALL ?: EXECUTE.contains('paths')

RUN_MODIFY = RUN_ALL ?: EXECUTE.contains('modify')

////BRANCH_FILTER////


workflow { 

    main:

        println('PARSING INPUTS...')

        // MAIN

        def InputMeta = params.INPUT.MAIN + [
            INFO     : params.inputs,
            TYPE     : "SAMPLES",
            DETAILED : true,
            ]

        Inputs = ParseInfo( InputMeta )

        // SUPPLEMENTARY

        def SUPPLEMENTARYMeta = [
            INFO : params.SUPPLEMENTARY,
            TYPE : "SUPPLEMENTARY",
            ]

        SUPPLEMENTARY = ParseInfo( SUPPLEMENTARYMeta )


        // BRANCHES

        println('RUNNING BRANCHES...')
        
        // BRANCH( Inputs|BRANCH.out.Main)

        Inputs.view{ it -> ">>>> $it\n"}
        
        Data( Parameters, Inputs | filter { RUN_DATA }  )

        Paths( Parameters, Inputs | filter { RUN_PATHS }  )

        Modify( Parameters, Inputs | filter { RUN_MODIFY }  )

        ////BRANCH_RUN////


    /*
    */


    publish: 
    
        Data = Data.out.Main.map{ coreMeta -> 
        
            def indexMeta = [:]
            
            def indexMetaNew = prepBridge( 
                coreMeta  : coreMeta, 
                indexMeta : indexMeta, 
                BASIC     : false, 
                UPDATE    : false, 
                INTERIM   : false,
                )      
            
            return indexMetaNew }

        Paths = Paths.out.Main.map{ coreMeta -> 
        
            def indexMeta = [:]
            
            def indexMetaNew = prepBridge( 
                coreMeta  : coreMeta, 
                indexMeta : indexMeta, 
                BASIC     : false, 
                UPDATE    : false, 
                INTERIM   : false,
                )      
            
            return indexMetaNew }

        Modify = Modify.out.Main.map{ coreMeta -> 
        
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
            enabled      false
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
