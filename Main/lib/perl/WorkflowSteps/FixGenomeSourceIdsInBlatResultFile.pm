package ApiCommonWorkflow::Main::WorkflowSteps::FixGenomeSourceIdsInBlatResultFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getParamValue('inputFile');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $new_file = "";

  if ($undo) {
  } else {
      if ($test) {
	  $self->testInputFile('seqFile', "$workflowDataDir/$inputFile");
      }else{
	    open (F, "$workflowDataDir/$inputFile");
	    while (<F>){
		while (m/\#/g){
		    $_ =~ s|\#|\.|;
		    $new_file .= $_;
		}
		close F;
	    }
	    system ("cp $workflowDataDir/$inputFile $workflowDataDir/$inputFile.bak");
	    open (OUT, ">$workflowDataDir/$inputFile");
	    print OUT $new_file;
	    close OUT;
      }
  }
}

sub getParamDeclaration {
  return (
	  'inputFile',
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}

