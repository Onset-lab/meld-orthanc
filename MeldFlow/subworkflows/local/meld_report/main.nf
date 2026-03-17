include { MELD } from '../../../modules/local/meld/main.nf'
include { PDF2DCM } from '../../../modules/local/pdf2dcm/main.nf'

workflow MELD_REPORT {

    take:
    t1         // path
    dicom_example // path (if --dicom)

    main:

    ch_versions = Channel.empty()

    MELD( t1 )
    ch_versions = ch_versions.mix(MELD.out.versions.first())

    PDF2DCM( MELD.out.meld_report.join(dicom_example) )
    ch_versions = ch_versions.mix(PDF2DCM.out.versions.first())

    emit:
    versions = ch_versions                          // channel: [ versions.yml ]
}
