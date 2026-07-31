package ApiCommonWorkflow::Main::WorkflowSteps::CopyDnaSeqMergeResultsToWebServices;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use ApiCommonWorkflow::Main::Util::OrganismInfo;

sub run {
  my ($self, $test, $undo) = @_;

  my $copyFromDir    = $self->getParamValue('copyFromDir');
  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $relativeDir    = $self->getParamValue('relativeDir');
  my $gusConfigFile  = $self->getParamValue('gusConfigFile');

  my $workflowDataDir = $self->getWorkflowDataDir();
  $gusConfigFile = "$workflowDataDir/$gusConfigFile";
  my $websiteFilesDir = $self->getWebsiteFilesDir($test);

  my $organismNameForFiles =
      $self->getOrganismInfo($test, $organismAbbrev, $gusConfigFile)->getNameForFiles();

  my $baseDir   = "$websiteFilesDir/$relativeDir/$organismNameForFiles/dnaseq";
  my $vcfDir    = "$baseDir/vcf";
  my $sourceDir = "$workflowDataDir/$copyFromDir";

  if ($undo) {
    # Derive the published readFreq dirs the same way the forward copy creates
    # them, so undo can't drift from the copy if the frequency set ever changes.
    my @published = glob("$baseDir/readFreq*");
    $self->runCmd(0, "rm -rf $vcfDir @published");
    return;
  }

  $self->testInputFile('copyFromDir', $sourceDir);

  # merged annotated VCF + index
  $self->runCmd($test, "mkdir -p $vcfDir");
  $self->runCmd($test, "cp $sourceDir/merged.ann.vcf.gz $vcfDir/");
  $self->runCmd($test, "cp $sourceDir/merged.ann.vcf.gz.tbi $vcfDir/");

  # high-speed-search dirs: hsss_readFreqN -> readFreqN
  my @hsssDirs = glob("$sourceDir/hsss_readFreq*");
  die "No hsss_readFreq* directories found in '$sourceDir'" unless @hsssDirs || $test;
  foreach my $dir (@hsssDirs) {
    my $name = (split '/', $dir)[-1];   # hsss_readFreq20
    (my $target = $name) =~ s/^hsss_//; # readFreq20
    $self->runCmd($test, "rm -rf $baseDir/$target");
    $self->runCmd($test, "cp -r $dir $baseDir/$target");
  }
}

1;
