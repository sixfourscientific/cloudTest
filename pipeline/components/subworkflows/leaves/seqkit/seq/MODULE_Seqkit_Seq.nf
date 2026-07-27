
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

            def outFile = "${task.ext.tag}.modified.fa"

            return outFile }


    // TAKE & EMIT

    input:

        tuple   val  (CoreMeta),
                path (INPUT),
                path (OPTIONAL),
                val  (Arguments)

    output:

        tuple   val  (CoreMeta),
                path ('*.fa'),

                emit: Main

    // MAIN

    script:

        """

        seqkit seq \\
            $task.ext.arguments \\
            --out-file $task.ext.outFile \\
            $INPUT

        """

    }

/* 

VERSION: X.X

HELP

*/
