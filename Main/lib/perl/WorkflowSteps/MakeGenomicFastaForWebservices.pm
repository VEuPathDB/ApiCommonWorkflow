package ApiCommonWorkflow::Main::WorkflowSteps::MakeGenomicFastaForWebservices;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker;

sub run {
  my ($self, $test, $undo) = @_;

  my $organismAbbrev = $self->getParamValue('organismAbbrev');

  my $webServicesRelativeDir = $self->getParamValue('relativeWebServicesDir');

  my $websiteFilesDir = $self->getWebsiteFilesDir($test);

  my $organismNameForFiles = $self->getOrganismInfo($test, $organismAbbrev)->getNameForFiles();

  my $copyToDir = "$websiteFilesDir/$webServicesRelativeDir/$organismNameForFiles/fasta/";

  my $ncbiTaxonId = $self->getOrganismInfo($test, $organismAbbrev)->getNcbiTaxonId();

  my $tuningTablePrefix = $self->getTuningTablePrefix($organismAbbrev, $test);

    my $sql = <<"EOF";
       SELECT sa.source_id
                ||' | organism='||
               replace(sa.organism, ' ', '_')
                ||' | version='||
               sa.database_version
                ||' | length=' ||
               sa.length || ' | SO=' || so.name
               as defline,
               ns.sequence
           FROM dots.nasequence ns, sres.ontologyTerm so,
                ApidbTuning.${tuningTablePrefix}GenomicSeqAttributes sa
          WHERE ns.na_sequence_id = sa.na_sequence_id
            AND sa.ncbi_tax_id = $ncbiTaxonId
            AND sa.is_top_level = 1
            AND so.source_id = sa.so_id
          ORDER BY sa.chromosome_order_num, sa.source_id
EOF

  my $fastaFile = "${copyToDir}/genome.fasta";
  my $cmd = "gusExtractSequences --outputFile $fastaFile  --idSQL \"$sql\" ";

  my $indexCmd = "samtools faidx $fastaFile";


  if($undo) {
      $self->runCmd(0, "rm -f ${fastaFile}*");
  } else{
      if($test){
          $self->runCmd(0, "echo test > $fastaFile");
          $self->runCmd(0, "echo test > ${fastaFile}.fai");
      }
      $self->runCmd($test, "mkdir -p $copyToDir");
      $self->runCmd($test, $cmd);
      $self->runCmd($test, $indexCmd);
  }
}

1;
