package ApiCommonWorkflow::Main::WorkflowSteps::LoadGenegenomicsequenceBySqlLdr;

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

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $instance = $self->getSharedConfig('instance');

  my $apidbPassword = $self->getConfig('apidbPassword');


  my $selectSql = "select gf.source_id,
                     case
                       when type = 'exon' and gl.is_reversed = 0
                       then substr(s.sequence, gm.start_min, (gm.end_max - gm.start_min) + 1)
                       when type = 'exon' and gl.is_reversed = 1
                       then apidb.reverse_complement_clob(substr(s.sequence, gm.start_min, (gm.end_max - gm.start_min) + 1))
                       when type = 'intron' and gl.is_reversed = 0
                       then lower(substr(s.sequence, gm.start_min, (gm.end_max - gm.start_min) + 1))
                      else lower(apidb.reverse_complement_clob(substr(s.sequence, gm.start_min, (gm.end_max - gm.start_min) + 1)))
                      end as sequence
                  from dots.GeneFeature gf, dots.nalocation gl, dots.NaSequence s,
                  (  select 'exon' as type, ef.parent_id as na_feature_id,  el.start_min as start_min, el.end_max as end_max
                     from dots.ExonFeature ef, dots.nalocation el
                     where ef.na_feature_id = el.na_feature_id
                     union
                     select 'intron' as type, left.parent_id as na_feature_id, leftLoc.end_max + 1  as start_min, rightLoc.start_min - 1 as end_max
                     from dots.ExonFeature left, dots.nalocation leftLoc,  dots.ExonFeature right, dots.nalocation rightLoc
                     where left.parent_id = right.parent_id
                       and (left.order_number = right.order_number - 1 or left.order_number = right.order_number + 1)
                       and leftLoc.start_min < rightLoc.start_min
                       and left.na_feature_id = leftLoc.na_feature_id
                       and right.na_feature_id = rightLoc.na_feature_id ) gm
                  where gm.na_feature_id = gf.na_feature_id
                    and s.na_sequence_id = gf.na_sequence_id
                    and gf.na_feature_id = gl.na_feature_id
                    and gf.external_database_release_id in ($dbRlsIds)
                  order by case when gl.is_reversed = 1 then -1 * gm.start_min else gm.start_min end";

  my $deleteSql ="delete apidb.genegenomicsequence";

  if ($undo) {
      $self->runCmd(0, "executeIdSQL.pl --idSql \"$deleteSql\"");
      $self->runCmd(0, "rm -f $workflowDataDir/geneGenomicSeq*");
    } else {
        if ($test) {
        }else{
            $self->runCmd($test,"gusExtractSequences --outputFile $workflowDataDir/geneGenomicSeq.fsa --verbose --idSQL \"$selectSql\"");
            $self->runCmd($test,"geneGenomicSequence --inFile $workflowDataDir/geneGenomicSeq.fsa --outFile $workflowDataDir/geneGenomicSeqSqlLdr.txt");
            $self->runCmd($test,"nohup sqlldr  apidb/$apidbPassword@$instance control=$workflowDataDir/geneGenomicSeqSqlLdr.txt");
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
