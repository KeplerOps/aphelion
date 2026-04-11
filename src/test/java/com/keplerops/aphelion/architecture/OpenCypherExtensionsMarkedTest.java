package com.keplerops.aphelion.architecture;

import static com.tngtech.archunit.lang.syntax.ArchRuleDefinition.noClasses;

import com.tngtech.archunit.core.importer.ImportOption;
import com.tngtech.archunit.junit.AnalyzeClasses;
import com.tngtech.archunit.junit.ArchTest;
import com.tngtech.archunit.lang.ArchRule;

/**
 * ADR-004: openCypher extensions must be explicitly marked. ADR-008: Domain must not depend on
 * protocol-specific types.
 *
 * <p>The ADR-004 annotation-based rule (non-standard query functions must carry a CypherExtension
 * marker) cannot be tested until the query function registration mechanism exists (work order step
 * 3). This class currently enforces the ADR-008 structural constraint that the pseudo file also
 * covered.
 */
@AnalyzeClasses(
    packages = "com.keplerops.aphelion",
    importOptions = ImportOption.DoNotIncludeTests.class)
class OpenCypherExtensionsMarkedTest {

  @ArchTest
  static final ArchRule no_protocol_types_in_domain =
      noClasses()
          .that()
          .resideInAPackage("..domain..")
          .should()
          .dependOnClassesThat()
          .resideInAnyPackage("..bolt..", "..pgwire..", "..grpc..")
          .because("ADR-008: Domain must not depend on protocol-specific types");
}
