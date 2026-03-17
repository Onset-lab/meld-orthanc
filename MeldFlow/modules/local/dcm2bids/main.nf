process DCM2BIDS {
    tag "$meta.id"

    input:
    tuple val(meta), path(dicom)

    output:
    tuple val(meta), path("*__t1.nii.gz"), emit: t1
    tuple val(meta), path("*__flair.nii.gz"), emit: flair, optional: true
    path "versions.yml"                  , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    prefix = prefix.replaceAll(/[^a-zA-Z0-9]/, '')
    """
    dcm2bids -d ${dicom} -p ${prefix} -c /assets/*.conf
    cp sub-${prefix}/anat/sub-${prefix}_t1.nii.gz ${prefix}__t1.nii.gz
    cp sub-${prefix}/anat/sub-${prefix}_flair.nii.gz ${prefix}__flair.nii.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        dcm2bids: \$(pip list | grep dcm2bids | tr -s ' ' | cut -d " " -f 2)
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}__ct.nii.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        dcm2bids: \$(pip list | grep dcm2bids | tr -s ' ' | cut -d " " -f 2)
    END_VERSIONS
    """
}
