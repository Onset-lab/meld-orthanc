#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { PIPELINE_INITIALISATION } from './subworkflows/local/pipeline_initialisation/main.nf'
include { MELD_REPORT } from './subworkflows/local/meld_report/main.nf'

if(params.help) {
    usage = file("$baseDir/USAGE")

    cpu_count = Runtime.runtime.availableProcessors()
    bindings = ["acq3T":"$params.acq3T",
                "seg_only":"$params.seg_only",
                "output_dir":"$params.output_dir"]

    engine = new groovy.text.SimpleTemplateEngine()
    template = engine.createTemplate(usage.text).make(bindings)

    print template.toString()
    return
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow {

    main:
    //
    // SUBWORKFLOW: Run initialisation tasks
    //
    PIPELINE_INITIALISATION (
        params.input,
        params.dicom,
        params.bids,
        params.output_dir
    )

    MELD_REPORT(
        PIPELINE_INITIALISATION.out.t1,
        PIPELINE_INITIALISATION.out.dicom_example,
    )
}
