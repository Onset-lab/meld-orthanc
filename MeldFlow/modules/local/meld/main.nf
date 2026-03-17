process MELD {
    tag "$meta.id"

    input:
    tuple val(meta), path(t1)

    output:
    tuple val(meta), path("*__MELD_report.pdf"), emit: meld_report
    path "versions.yml"                  , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    prefix = prefix.replaceAll(/[^a-zA-Z0-9]/, '')
    """
    mkdir -p /data/input/${prefix}/T1
    mv ${t1} /data/input/${prefix}/T1/T1w.nii.gz
    FS_LICENSE=/run/secrets/license.txt
    MELD_LICENSE=/run/secrets/meld_license.txt
    FREESURFER_HOME=/opt/freesurfer-7.2.0

    source $FREESURFER_HOME/FreeSurferEnv.sh
    python scripts/new_patient_pipeline/new_pt_pipeline.py -id ${prefix} --fastsurfer

    mv /data/output/predictions_reports/${prefix}/reports/*report*.pdf ${prefix}__MELD_report.pdf

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        meld: v2.5.5
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}__MELD_report.pdf

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        meld: v2.5.5
    END_VERSIONS
    """
}
