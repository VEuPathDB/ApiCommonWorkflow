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
    publishDir params.outDir, mode: 'copy'

    input:
    tuple val(meta), path(bed)

    output:
    tuple val(meta), path("*_smoothed.bw"), path("*peaks.txt")

    script:
    """
    java -Xmx2000m -classpath \$GUS_HOME/lib/java/GGTools-Array.jar org.apidb.ggtools.array.ChIP_Chip_Peak_Finder $bed  peaks.tmp.txt smoothed.tmp.txt ${params.peakFinderArgs}
    reformatSmoothedProfiles.pl --inputFile smoothed.tmp.txt --outputFile smoothed.txt 
    cat smoothed.txt | tail -n +2 | sort -k1,1 -k2,2n >smoothed.bed
    reformatPeaks.pl  --inputFile peaks.tmp.txt --outputFile ${meta.id}_peaks.txt
    bedGraphToBigWig smoothed.bed ${params.seqSizeFile} ${meta.id}_smoothed.bw
    """
}

