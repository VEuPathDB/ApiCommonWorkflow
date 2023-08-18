package ApiCommonWorkflow::Main::WorkflowSteps::MakeGffForWebservices;

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

  my $copyToDir = "$websiteFilesDir/$webServicesRelativeDir/$organismNameForFiles/gff/";

  my $extDbRlsId = $self->getExtDbRlsId($test,$self->getParamValue('genomeExtDbRlsSpec'));

  my $tuningTablePrefix = $self->getTuningTablePrefix($self->getParamValue('organismAbbrev'), $test);

  my $gffFile = "${copyToDir}/annotated_transcripts";

  my $cmd = "makeGff.pl --extDbRlsId $extDbRlsId --outputFile ${gffFile}.tmp --tuningTablePrefix $tuningTablePrefix";

  # sort and remove header lines
  my $sortGffCmd = "grep -v '^#' ${gffFile}.tmp | sort -k1,1 -k4,4n > $gffFile ";
  my $bgzipCmd = "bgzip $gffFile";
  my $tabixCmd = "tabix -p gff ${gffFile}.gz";
  my $rmTmpCmd = "rm ${gffFile}.tmp";


  if($undo) {
      $self->runCmd(0, "rm -f ${gffFile}*");
  } else{
      if($test){
          $self->runCmd(0, "echo test > ${gffFile}.gff.gz");
          $self->runCmd(0, "echo test > ${gffFile}.gff.gz.tbi");
      }
      $self->runCmd($test, "mkdir -p $copyToDir");
      $self->runCmd($test, $cmd);
      $self->runCmd($test, $sortGffCmd);
      $self->runCmd($test, $bgzipCmd);
      $self->runCmd($test, $tabixCmd);
      $self->runCmd($test, $rmTmpCmd);
  }
}

1;
