package ApiCommonWorkflow::Main::WorkflowSteps::LoadGenegenomicsequenceByQuery;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;



sub run {
  my ($self, $test,$undo) = @_;

  my $extDbRlsSpec = $self->getParamValue('genomeExtDbRlsSpecList');

  my @extDbRlsSpecList = split(/,/, $extDbRlsSpec);

  my $dbRlsIds;

  foreach my $db (@extDbRlsSpecList){

     $dbRlsIds .= $self->getExtDbRlsId($test, $db).",";

  }

  $dbRlsIds =~ s/(,)$//g;

  my $deleteSql ="delete apidb.genegenomicsequence";

  if ($undo) {
      $self->runCmd(0, "executeIdSQL.pl --idSql \"$deleteSql\"");
    } else {
        if ($test) {
        }else{
            $self->runCmd($test,"geneGenomicSequenceByQuery --dbRlsIds '$dbRlsIds'");
        }
    }
}

sub getParamsDeclaration {
  return (
	  'extDbRlsSpec',
	 );
}

sub getConfigDeclaration {
  return (

	 );
}
