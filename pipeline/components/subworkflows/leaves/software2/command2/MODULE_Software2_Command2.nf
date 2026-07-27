
include { 
    formatArguments as formatArguments;
    makeTag as makeTag;
    } from "$params.importMap.functions/core/Utils"

process MODULE {

    // SETUP

    tag "$task.ext.tag"

    label workflow.profile in params.profileLabels 
        ? workflow.profile.toUpperCase()
        : 'DEFAULT'

    // EXTRA

    ext tag : {

        def tag = makeTag(
            tags      : [ CoreMeta.ID, CoreMeta.TAG ],
            delimiter : '-',
            )
 
        return tag },
    
    version : {

            def version = CoreMeta.STAGING.VERSION

            return version },

        arguments: { 

            def arguments = formatArguments( Arguments, '\s', '            ')

            return arguments },

        outFile: { 

            def outFile = "${CoreMeta.name}.head.fa"

            return outFile }


    // TAKE & EMIT

    input:

        tuple   val  (CoreMeta),
                path (INPUT),
             // path (OPTIONAL),
                val  (Arguments)

    output:

        tuple   val  (CoreMeta),
                path ('*.fa'),

                emit: Main

    // MAIN

    script:

        """

        head -n 2 $INPUT > $task.ext.outFile

        """

    }

/* 

VERSION: X.X

HELP

*/
