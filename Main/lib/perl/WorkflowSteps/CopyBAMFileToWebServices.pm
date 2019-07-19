package ApiCommonWorkflow::Main::WorkflowSteps::CopyBAMFileToWebServices;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker;

use File::Basename;

sub run {
  my ($self, $test, $undo) = @_;

  # standard parameters for making download files
  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $projectName = $self->getParamValue('projectName');
  my $inputFile=$self->getParamValue('inputFile');
  my $experimentName=$self->getParamValue('experimentName');
  my $snpStrain=$self->getParamValue('snpStrain');
  my $webServicesRelativeDir = $self->getParamValue('relativeWebServicesDir');

  my $websiteFilesDir = $self->getWebsiteFilesDir($test);

  my $organismNameForFiles = $self->getOrganismInfo($test, $organismAbbrev)->getNameForFiles();

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $isBamFile = $inputFile =~ /\.bam$/ ? 1 : 0;

  my $copyToDir = "$websiteFilesDir/$webServicesRelativeDir/$organismNameForFiles/bam/$experimentName/$snpStrain/";

  my $bwCopyToDir = "$websiteFilesDir/$webServicesRelativeDir/$organismNameForFiles/bigwig/$experimentName/$snpStrain/";

  my $dirname = dirname("$workflowDataDir/$inputFile");
  my $basename = basename("$workflowDataDir/$inputFile");
  $basename =~ s/\.bam$/.bw/;


  if($undo) {
    $self->runCmd(0, "rm -f $copyToDir/*");
    $self->runCmd(0, "rm -f $bwCopyToDir/*") if($isBamFile);
  } else{
      if($test){
	  $self->runCmd(0, "mkdir -p $copyToDir");
	  $self->runCmd(0, "mkdir -p $bwCopyToDir") if($isBamFile);
      }
    $self->runCmd($test, "mkdir -p $copyToDir");
    $self->runCmd($test, "cp $workflowDataDir/$inputFile $copyToDir");

    # We need BOTH BAM and bigwig files for jbrowse (applies to ncRNASeq and DNASEq)
    if($isBamFile) {

      my $genomeFile = "${dirname}/genome.txt";
      if(!-e $genomeFile) {
        my $ncbiTaxonId = $self->getOrganismInfo($test, $organismAbbrev)->getNcbiTaxonId();
        my $tuningTablePrefix = $self->getTuningTablePrefix($organismAbbrev, $test);

        my $sql = "select sa.source_id||chr(9)||ns.length
            from ApidbTuning.${tuningTablePrefix}GenomicSeqAttributes sa, dots.nasequence ns
            where sa.is_top_level = 1
            and sa.na_sequence_id = ns.na_sequence_id
            and sa.NCBI_TAX_ID = $ncbiTaxonId";

        $self->runCmd($test,"makeFileWithSql --outFile $genomeFile --sql \"$sql\"");
      }


      $self->runCmd($test, "mkdir -p $bwCopyToDir");
#      $self->runCmd($test, "bedtools genomecov -ibam $workflowDataDir/$inputFile -bg |sort -k1,1 -k2,2n >${dirname}/tmpResult.bg");
      $self->runCmd($test, "bedtools genomecov -ibam $workflowDataDir/$inputFile -bg |LC_COLLATE=C sort -k1,1 -k2,2n >${dirname}/tmpResult.bg");
      $self->runCmd($test, "bedGraphToBigWig ${dirname}/tmpResult.bg $genomeFile ${bwCopyToDir}/${basename}");
      $self->runCmd(0, "rm -f ${dirname}/tmpResult.bg");
    }
  }
}

1;
