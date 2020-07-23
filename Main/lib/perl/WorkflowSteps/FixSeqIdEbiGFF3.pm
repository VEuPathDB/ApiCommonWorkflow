package ApiCommonWorkflow::Main::WorkflowSteps::FixSeqIdEbiGFF3;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $gff3 = $self->getParamValue('gff3File');
  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $workflowDataDir = $self->getWorkflowDataDir();

  $gff3 = "$workflowDataDir/$gff3";

  if ($undo) {





#      foreach my $vcf (glob "$fullPath/*.vcf.gz") {
#              my $oldGff3 = "$gff3.old";
              $gff3 =~ s/final\///;
              $self->runCmd(0, "rm $gff3");
#              $self->runCmd(0, "mv $oldGff3 $gff3");
#             }
#             foreach my $index (glob "$fullPath/*.tbi") {
             $self->runCmd(0, "rm $gff3.tbi");
#             }



  } else {


    $self->runCmd($test, "ebiGFF3RegionNameMapping.pl --GFF3File $gff3 --organism_abbrev $organismAbbrev");

  }

}


1;
