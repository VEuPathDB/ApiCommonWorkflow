package ApiCommonWorkflow::Main::WorkflowSteps::MakeTandemConfigFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;
  
  my $string = "input_file =  ".$self->getParamValue('tandemInputDir')."\n";
  
  $string = $string."fasta_file".$self->getParamValue('decoyFastaFile')."\n"; 

  $string = $string."enzyme_name".$self->getParamValue('enzymeName')."\n";
  
  $string = $string."product_tolerance = ".$self->getParamValue('productTolerance')."\n"; 
  
  $string = $string."precursor_tolerance = ".$self->getParamValue('precursorTolerance')."\n";
  
  $string = $string."fixed_mod_id = ".$self->getParamValue('fixedModId')."\n"; 

  $string = $string."variable_mod_id = ".$self->getParamValue('variableModId')."\n";
  
  $string = $string."missed_cleavages = ".$self->getParamValue('missedCleavages')."\n"; 
  
  $string = $string."output_file = ".$self->getParamValue('tandemOutputFile')."\n";
  
  $string = $string."species = ".$self->getParamValue('species')."\n"; 

  $string = $string."default_input_file = ".$self->getParamValue('tandemDefaultInputFile')."\n";
  
  $string = $string."taxonomy_file = ".$self->getParamValue('taxonomyFile')."\n";

  my $outputFile = $self->getParamValue('writeToFile');

  $outputFile=~ s/\s/_/g;
  
  my $workflowDataDir = $self->getWorkflowDataDir();
  
  $outputFile=$workflowDataDir .'/'.$outputFile;

  $outputFile =~ s/\/+/\//g;
 
  my $cmd = "echo $string $outputFile";

  if ($test) {
    $self->runCmd(0, "echo test > $outputFile");
  }

  if ($undo) {
    $self->runCmd(0, "rm -f $outputFile");
  } else {
    $self->runCmd($test, $cmd);
  }

}

sub getParamsDeclaration {
  return (
		'tandemInputDir',
		'decoyFastaFile',
		'enzymeName',
		'productTolerance',
		'precursorTolerance',
		'fixedModId',
		'variableModId',
		'missedCleavages',
		'tandemOutputFile',
		'species',
		'tandemDefaultInputFile',
		'taxonomyFile',
		'writeToFile',
         );
}

sub getConfigDeclaration {
  return (
         # [name, default, description]
         # ['', '', ''],
         );
}
  