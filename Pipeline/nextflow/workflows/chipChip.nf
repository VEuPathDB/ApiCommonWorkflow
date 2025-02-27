#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

workflow {
    // samplesheet has 2 fields (name and file)
    samples = Channel.fromPath(params.input + "/" + params.samplesheetFileName)
        .splitCsv( skip:1)

    rawToGenomeCoordinates(samplesFullPath = samples.map { row ->
        chipChipFile = file(params.input + "/" + row[1]);
        return [ [id: row[0] ], [chipChipFile] ]
    })

    peakFinderAndSmoother(rawToGenomeCoordinates.out)

    reformatSmoothedProfiles(peakFinderAndSmoother.out)
}

process rawToGenomeCoordinates [
    input:
    tuple val(meta), path(chipChipFile)

    output:
    tuple val(meta), path("genomeCoords.txt")

    script:
    """
    TransformRawDataToGenomeCoordinates  --inputFile ${params.workflowDataDir}/${chipChipFile} \\
                                         --outputFile genomeCoords.txt \\
                                         --extDbSpec '${params.platformExtDbRlsSpec}' \\
                                         --gusConfigFile ${params.gusConfigFile}
    """
]

process peakFinderAndSmoother {
    input:
    tuple val(meta), path(genomeCoords)

    output:
    tuple val(meta), path("smoothed.txt"), path("peaks.txt")

    script:
    """
    java -Xmx2000m -classpath ${params.gusHome}/lib/java/GGTools-Array.jar org.apidb.ggtools.array.ChIP_Chip_Peak_Finder $genomeCoords  peaks.tmp.txt smoothed.tmp.txt ${params.peakFinderArgs}";
    reformatSmoothedProfiles.pl --inputFile smoothed.tmp.txt --outputFile smoothed.txt
    reformatPeaks.pl  --inputFile peaks.tmp.txt --outputFile peaks.txt
    """
}

