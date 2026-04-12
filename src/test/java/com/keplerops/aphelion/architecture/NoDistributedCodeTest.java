package com.keplerops.aphelion.architecture;

import static com.tngtech.archunit.lang.syntax.ArchRuleDefinition.noClasses;

import com.tngtech.archunit.core.importer.ImportOption;
import com.tngtech.archunit.junit.AnalyzeClasses;
import com.tngtech.archunit.junit.ArchTest;
import com.tngtech.archunit.lang.ArchRule;

/** ADR-003, ADR-005, ADR-009: V1 is single-node only. No distributed primitives. */
@AnalyzeClasses(
    packages = "com.keplerops.aphelion",
    importOptions = ImportOption.DoNotIncludeTests.class)
class NoDistributedCodeTest {

  @ArchTest
  static final ArchRule no_raft_consensus =
      noClasses()
          .should()
          .haveSimpleNameContaining("RaftConsensus")
          .because("ADR-003: V1 is single-node only");

  @ArchTest
  static final ArchRule no_paxos =
      noClasses()
          .should()
          .haveSimpleNameContaining("PaxosConsensus")
          .because("ADR-003: V1 is single-node only");

  @ArchTest
  static final ArchRule no_leader_election =
      noClasses()
          .should()
          .haveSimpleNameContaining("LeaderElection")
          .because("ADR-003: V1 is single-node only");

  @ArchTest
  static final ArchRule no_distributed_transactions =
      noClasses()
          .should()
          .haveSimpleNameContaining("DistributedTransaction")
          .because("ADR-005: V1 transactions are single-node local");

  @ArchTest
  static final ArchRule no_cluster_coordinator =
      noClasses()
          .should()
          .haveSimpleNameContaining("ClusterCoordinator")
          .because("ADR-009: Replication and HA mechanism deferred");

  @ArchTest
  static final ArchRule no_node_discovery =
      noClasses()
          .should()
          .haveSimpleNameContaining("NodeDiscovery")
          .because("ADR-009: Replication and HA mechanism deferred");

  @ArchTest
  static final ArchRule no_replication_manager =
      noClasses()
          .should()
          .haveSimpleNameContaining("ReplicationManager")
          .because("ADR-009: Replication and HA mechanism deferred");

  @ArchTest
  static final ArchRule no_failover_controller =
      noClasses()
          .should()
          .haveSimpleNameContaining("FailoverController")
          .because("ADR-009: Replication and HA mechanism deferred");

  @ArchTest
  static final ArchRule no_shard_manager =
      noClasses()
          .should()
          .haveSimpleNameContaining("ShardManager")
          .because("ADR-003: V1 is single-node only");

  @ArchTest
  static final ArchRule no_cross_node_query =
      noClasses()
          .should()
          .haveSimpleNameContaining("CrossNodeQuery")
          .because("ADR-003: V1 is single-node only");
}
