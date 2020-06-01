package ApiCommonWorkflow::Main::WorkflowSteps::FixSeqIdEbiVCF;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $vcf = $self->getParamValue('vcfFile');
  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $workflowDataDir = $self->getWorkflowDataDir();

  $vcf = "$workflowDataDir/$vcf";

  if ($undo) {
#      foreach my $vcf (glob "$fullPath/*.vcf.gz") {
        my $oldVcf = "$vcf.old";
        $self->runCmd(0, "rm $vcf");
        $self->runCmd(0, "mv $oldVcf $vcf");
#      }
#      foreach my $index (glob "$fullPath/*.tbi") {
        $self->runCmd(0, "rm $vcf.tbi");
#      }

  } else {


    $self->runCmd($test, "ebiVCFRegionNameMapping.pl --VCF_File $vcf --organism_abbrev $organismAbbrev");

  }

}


1;
