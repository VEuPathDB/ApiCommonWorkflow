#!/usr/bin/env nextflow


nextflow.enable.dsl = 2

workflow {

    // samplesheet has 2 fields (name and file)
    samples = Channel.fromPath(params.input + "/" + params.samplesheetFileName)
        .splitCsv( skip:1)

    rawToGenomeCoordinates(samplesFullPath = samples.map { row ->
        chipChipFile = file(params.input + "/" + row[1]);
        return [ [id: row[0] ], chipChipFile ]
    })

    peakFinderAndSmoother(rawToGenomeCoordinates.out)

    peakFinderAndSmoother.out.studyConfig.collectFile(name: "insert_study_results", storeDir: params.outDir, keepHeader: true, skip: 1)
    
}

process rawToGenomeCoordinates {
    input:
    tuple val(meta), path(chipChipFile)

    output:
    tuple val(meta), path("genomeCoords.txt")

    script:
    """
    TransformRawDataToGenomeCoordinates  --inputFile ${params.input}/${chipChipFile} \\
                                         --outputFile genomeCoords.txt \\
                                         --probesBamFile '${params.platformBamFile}'
    """
}


process peakFinderAndSmoother {
    publishDir params.outDir, mode: 'copy', pattern: "*.bw"
    publishDir params.outDir, mode: 'copy', pattern: "*.gz"
    publishDir params.outDir, mode: 'copy', pattern: "*.txt"
    publishDir params.outDir, mode: 'copy', pattern: "*.tbi"

    input:
    tuple val(meta), path(bed)

    output:
    tuple val(meta), path("*_smoothed.bw"), path("*peaks.txt"), path("*bed.gz*")
    path("study.config"), emit: studyConfig

    script:
    """
    java -Xmx2000m -classpath \$GUS_HOME/lib/java/GGTools-Array.jar org.apidb.ggtools.array.ChIP_Chip_Peak_Finder $bed  peaks.tmp.txt smoothed.tmp.txt ${params.peakFinderArgs}

    reformatSmoothedProfiles.pl --inputFile smoothed.tmp.txt --outputFile smoothed.txt 
    cat smoothed.txt | tail -n +2 | sort -k1,1 -k2,2n >smoothed.bed
    bedGraphToBigWig smoothed.bed ${params.seqSizeFile} ${meta.id}_smoothed.bw

    reformatPeaks.pl  --inputFile peaks.tmp.txt --outputFile ${meta.id}_peaks.txt
    tail -n +2 ${meta.id}_peaks.txt | cut -f 1,2,3,5 | sort -k1,1 -k2,2n >${meta.id}_peaks.bed
    bgzip ${meta.id}_peaks.bed
    tabix -p bed ${meta.id}_peaks.bed.gz

    writeStudyConfig --file ${meta.id}_peaks.txt --outputFile study.config --name '${meta.id}_peaks (ChIP-chip)' --protocol 'chipChipPeaks' --sourceIdType segment --profileSetName '${params.profileSetName}'
    """
}

