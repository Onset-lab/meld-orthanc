
def logoHeader(){
    // Log colors ANSI codes
    c_reset = "\033[0m";
    c_dim = "\033[2m";
    c_blue = "\033[0;34m";

    return """
    ${c_dim}-----------------------------------${c_reset}
    ${c_blue}    ___  _   _ ____  _____ _____   ${c_reset}
    ${c_blue}   / _ \\| \\ | / ___|| ____|_   _|  ${c_reset}
    ${c_blue}  | | | |  \\| \\___ \\|  _|   | |    ${c_reset}
    ${c_blue}  | |_| | |\\  |___) | |___  | |    ${c_reset}
    ${c_blue}   \\___/|_| \\_|____/|_____| |_|    ${c_reset}

    ${c_dim}------------------------------------${c_reset}
    """.stripIndent()
}

log.info logoHeader()

log.info "\033[0;33m ${workflow.manifest.name} \033[0m"
log.info "  ${workflow.manifest.description}"
log.info "  Version: ${workflow.manifest.version}"
log.info "  Github: ${workflow.manifest.homePage}"
log.info " "

workflow.onComplete {
    log.info " "
    log.info "Pipeline completed at: $workflow.complete"
    log.info "Execution status: ${ workflow.success ? 'OK' : 'failed' }"
    log.info "Execution duration: $workflow.duration"
}

include { DCM2BIDS } from '../../../modules/local/dcm2bids/main.nf'

workflow PIPELINE_INITIALISATION {

    take:
    input           // path
    dicom           // path
    bids            // path
    outdir          // path

    main:

    if (input) {
        t1_channel = Channel.fromPath("$input/**/*t1.nii.gz")
                        .map{ch1 ->
                            def fmeta = [:]
                            // Set meta.id
                            fmeta.id = ch1.parent.name
                            [fmeta, ch1]
                            }
        flair_channel = Channel.fromPath("$input/**/*flair.nii.gz")
                        .map{ch1 ->
                            def fmeta = [:]
                            // Set meta.id
                            fmeta.id = ch1.parent.name
                            [fmeta, ch1]
                            }
        dicom_example = Channel.empty()
    }
    else if (dicom) {
        dicom_channel = Channel.fromPath("$dicom", type:"dir")
                        .map{ch1 ->
                            def fmeta = [:]
                            // Set meta.id
                            fmeta.id = ch1.name.replaceAll(/[^a-zA-Z0-9]/, '')
                            [fmeta, ch1]
                            }
        
        DCM2BIDS( dicom_channel )
        t1_channel = DCM2BIDS.out.t1
        flair_channel = DCM2BIDS.out.flair

        ch_sid_dicom = dicom_channel.map{[it[0]]}

        dicom_example = Channel.fromPath("$dicom/**/*[!.nii.gz,!DICOMDIR]")
            .first()
            .mix(ch_sid_dicom)
            .collect()
    }
    else if (bids) {
        t1_channel = Channel.fromPath("$bids/**/anat/*t1.nii.gz")
                        .map{ch1 ->
                            def fmeta = [:]
                            // Set meta.id
                            fmeta.id =  ch1.parent.parent.parent.name
                            [fmeta, ch1]
                            }
        flair_channel = Channel.fromPath("$input/**/anat/*flair.nii.gz")
                        .map{ch1 ->
                            def fmeta = [:]
                            // Set meta.id
                            fmeta.id = ch1.parent.name
                            [fmeta, ch1]
                            }
        dicom_example = Channel.empty()
    }
    else {
        log.error "Please provide either --input or --dicom or --bids"
        exit 1
    }

    log.info "\033[0;33m Parameters \033[0m"
    log.info " Input: ${input}"
    log.info " DICOM: ${dicom}"
    log.info " BIDS: ${bids}"

    log.info " Output directory: ${outdir}"

    emit:
    t1 = t1_channel        // channel: [ val(meta), [ image ] ]
    flair = flair_channel  // channel: [ val(meta), [ image ] ]
    dicom_example = dicom_example // channel: [ path ]
}
