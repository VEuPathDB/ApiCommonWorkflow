package ApiCommonWorkflow::Main::WorkflowSteps::InsertExemplarGenes;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $inputFile = $self->getParamValue('inputFile');
    my $mercatorInputsDir = $self->getParamValue('mercatorInputsDir');

    my $workflowDataDir = $self->getWorkflowDataDir();

    my $args = "--file $workflowDataDir/$inputFile";

    # see if there are multiple strains.  if not, exit
    my $inputsDir = "$workflowDataDir/$mercatorInputsDir";
    opendir(INPUT, $inputsDir) or $self->error("Could not open mercator inputs dir '$inputsDir' for reading.");
    my $c;
    foreach my $file (readdir INPUT) {
	$c++ if $file =~ /\.fasta$/; # count how many organisms we have
    }
    if ($c == 1) {
	$self->log("Only found 1 organism in input dir $inputsDir.  No comparision needed.  Exiting.");
	return;
    }    



    $self->testInputFile('inputFile', "$workflowDataDir/$inputFile");


    # see if there are multiple strains.  if not, exit
    opendir(INPUT, $inputsDir) or $self->error("Could not open mercator inputs dir '$inputsDir' for reading.");
    my $c;
    foreach my $file (readdir INPUT) {
	$c++ if $file =~ /\.fasta$/; # count how many organisms we have
    }
    if ($c == 1) {
	$self->log("Only found 1 organism in input dir $inputsDir.  No comparision needed.  Exiting.");
	return;
    }    
 

   $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::CreateGenesForGeneFeatures", $args);
}

1;
