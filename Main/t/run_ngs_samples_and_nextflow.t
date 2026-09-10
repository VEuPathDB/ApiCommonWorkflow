use strict;
use warnings;

use lib "$ENV{GUS_HOME}/lib/perl";

use ApiCommonWorkflow::Main::WorkflowSteps::RunNgsSamplesAndNextflow;
use Test::More;

# the step class only needs paramValues to build its run list
package TestStep;
our @ISA = ('ApiCommonWorkflow::Main::WorkflowSteps::RunNgsSamplesAndNextflow');
sub new { my ($class, $paramValues) = @_; return bless({paramValues => $paramValues}, $class) }
sub log { }

package main;

my %params = (nextflowWorkflow             => 'VEuPathDB/dnaseq-nextflow',
              nextflowConfigFile           => '/data/exp/dnaseqNextflow/analysisDir/nextflow.config',
              resultsDir                   => '/data/exp/dnaseqNextflow/analysisDir/results',
              entry                        => 'processSingleExperiment',
              ngsSamplesNextflowConfigFile => '/data/exp/dnaseqNextflow/analysisDir/ngs-samples-nextflow.config',
              ngsSamplesResultsDir         => '/data/exp/dnaseqNextflow/analysisDir/ngs-samples-results');

my @runs = TestStep->new({%params})->nextflowRuns();

is(scalar(@runs), 2, "ngs-samples run precedes the analysis run");

is($runs[0]->{workflow}, 'VEuPathDB/ngs-samples-nextflow', "ngs-samples workflow");
is($runs[0]->{entry}, '', "ngs-samples takes no entry");
is($runs[0]->{configFile}, $params{ngsSamplesNextflowConfigFile}, "ngs-samples config");
is($runs[0]->{resultsDir}, $params{ngsSamplesResultsDir}, "ngs-samples results dir");

is($runs[1]->{workflow}, 'VEuPathDB/dnaseq-nextflow', "analysis workflow");
is($runs[1]->{entry}, 'processSingleExperiment', "analysis entry");
is($runs[1]->{configFile}, $params{nextflowConfigFile}, "analysis config");

# the on-cluster file names must not change: crash recovery finds an already
# finished run by its own log, and in-flight runs must stay resumable
is($runs[0]->{clusterJobInfoFileName}, 'ngs-samples-clusterJobInfo.txt', "ngs job info file");
is($runs[0]->{logFileName}, 'ngs-samples-nextflow.log', "ngs log file");
is($runs[0]->{traceFileName}, 'ngs-samples-trace.txt', "ngs trace file");
is($runs[0]->{nextflowStdoutFileName}, 'ngs-samples-nextflow.txt', "ngs stdout file");

is($runs[1]->{clusterJobInfoFileName}, 'clusterJobInfo.txt', "analysis job info file");
is($runs[1]->{logFileName}, 'nextflow.log', "analysis log file");
is($runs[1]->{traceFileName}, 'trace.txt', "analysis trace file");
is($runs[1]->{nextflowStdoutFileName}, 'nextflow.txt', "analysis stdout file");

# no distinct log files would mean run 2 could never resume past run 1
isnt($runs[0]->{logFileName}, $runs[1]->{logFileName}, "each run gets its own log");
isnt($runs[0]->{clusterJobInfoFileName}, $runs[1]->{clusterJobInfoFileName}, "each run gets its own job info");

# the 24 annotation callers pass no ngs-samples config: they must run one workflow
my @oneRun = TestStep->new({%params, ngsSamplesNextflowConfigFile => ''})->nextflowRuns();
is(scalar(@oneRun), 1, "empty ngs-samples config drops that run");
is($oneRun[0]->{workflow}, 'VEuPathDB/dnaseq-nextflow', "the remaining run is the analysis");
is($oneRun[0]->{logFileName}, 'nextflow.log', "and it keeps the unprefixed log name");

done_testing;
