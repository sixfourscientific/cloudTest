
// STAGING

// IMPORT

include { 
    preStage  as preStage;
    postStage as postStage;
    } from "$params.importMap.functions/core/Utils"

include { 
    MODULE as Run;
    } from "${params.importMap.subworkflows}/leaves/software2/command2/MODULE_Software2_Command2.nf"

workflow STAGING {

    take: 

        Inputs

        Config

    main:

        Inputs

        | combine ( Config )


        // PRE-STAGE

                | map { coreMeta, configMeta ->

                    def coreMetaNew  = preStage( 
                        coreMeta     : coreMeta, 
                        configMeta   : configMeta,
                        tagDelimiter : null,
                        tagDefault   : null,                        
                        )

                    return coreMetaNew }


        // STAGE

                | map { coreMeta ->

                    def skipOptional = !coreMeta.optional || !coreMeta.STAGING.ARGS.containsKey('--optional')

                    def optionalFile  = file( !skipOptional ? coreMeta.optional : 'optional.dummy' )

                    return [
                        coreMeta,
                        coreMeta.path,
                        optionalFile,
                        coreMeta.STAGING.ARGS,
                        ] }


        | Run


         // POST-STAGE

                | map { coreMeta, output ->
                    

                    def updateList = [
                        [['SOFTWARE2', 'COMMAND2', coreMeta.STAGING.BRANCH, 'main'],  output],
                        ]

                    def coreMetaNew = postStage( 
                        coreMeta     : coreMeta,
                        updateList   : updateList,
                        tagDelimiter : null,
                        tagDefault   : null,
                        )

                    return coreMetaNew }


        | set { Processed }


    emit:

        Main = Processed

    }
