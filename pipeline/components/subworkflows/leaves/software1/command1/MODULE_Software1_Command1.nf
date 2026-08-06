
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

            def outFile = "OUTPUT.EXT"

            return outFile }


    // TAKE & EMIT

    input:

        tuple   val  (CoreMeta),
                val  (INPUT),
                path (OPTIONAL),
                val  (Arguments)

    output:

        tuple   val  (CoreMeta),
                path ('{*.txt,**/*.txt}'),

                emit: Main

    // MAIN

    script:
        println("|>|> $task.cpus")
        """

        mkdir -p subDir
        echo 'DATA: $INPUT' > OUTPUT1.txt
        echo 'DATA: $INPUT' > subDir/OUTPUT2.txt

        """

    }

/* 

VERSION: X.X

HELP

*/
