package ApiCommonWorkflow::Main::WorkflowSteps::UpdateLongReadGtf;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
    my ($self, $test, $undo) = @_;
   
    my $gffFile = $self->getParamValue('gffFile');
    my $countFile = $self->getParamValue('countFile');
    my $gffFileOut = $self->getParamValue('gffFileOut');


  if ($undo) {
	 $self->runCmd(0,"rm -rf $gffFileOut");  	
 } else{
	$self->runCmd($test, "UpdateLongReadGtf.pl --GFF3File $gff_file --CountFile $count_file --UpdatedGffName $gtfOut"); 
}
