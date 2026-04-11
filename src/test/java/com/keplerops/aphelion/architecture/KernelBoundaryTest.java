package com.keplerops.aphelion.architecture;

import static com.tngtech.archunit.lang.syntax.ArchRuleDefinition.noClasses;

import com.tngtech.archunit.core.importer.ImportOption;
import com.tngtech.archunit.junit.AnalyzeClasses;
import com.tngtech.archunit.junit.ArchTest;
import com.tngtech.archunit.lang.ArchRule;

/** ADR-002, ADR-007: Domain and API must not depend on the engine adapter layer. */
@AnalyzeClasses(
    packages = "com.keplerops.aphelion",
    importOptions = ImportOption.DoNotIncludeTests.class)
class KernelBoundaryTest {

  @ArchTest
  static final ArchRule domain_must_not_depend_on_engine =
      noClasses()
          .that()
          .resideInAPackage("..domain..")
          .should()
          .dependOnClassesThat()
          .resideInAPackage("..infrastructure.engine..")
          .because("ADR-002: Domain must not depend on the kernel engine layer");

  @ArchTest
  static final ArchRule api_must_not_depend_on_engine =
      noClasses()
          .that()
          .resideInAPackage("..api..")
          .should()
          .dependOnClassesThat()
          .resideInAPackage("..infrastructure.engine..")
          .because("ADR-002, ADR-007: API must not depend on the kernel engine layer");
}
