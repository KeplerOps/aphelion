package com.keplerops.aphelion.architecture;

import static com.tngtech.archunit.lang.syntax.ArchRuleDefinition.noClasses;

import com.tngtech.archunit.core.importer.ImportOption;
import com.tngtech.archunit.junit.AnalyzeClasses;
import com.tngtech.archunit.junit.ArchTest;
import com.tngtech.archunit.lang.ArchRule;

/**
 * ADR-007: Public endpoints belong in the API layer, not the engine layer. The product is exposed
 * as a server process, not as the raw embedded kernel API.
 */
@AnalyzeClasses(
    packages = "com.keplerops.aphelion",
    importOptions = ImportOption.DoNotIncludeTests.class)
class ServerLayerRequiredTest {

  // This test will become more specific once the server framework is chosen.
  // For now, it guards against the most common accidental endpoint annotations
  // appearing in the engine adapter layer.

  @ArchTest
  static final ArchRule engine_layer_has_no_endpoint_annotations =
      noClasses()
          .that()
          .resideInAPackage("..infrastructure.engine..")
          .should()
          .beAnnotatedWith("org.springframework.web.bind.annotation.RestController")
          .orShould()
          .beAnnotatedWith("org.springframework.web.bind.annotation.Controller")
          .orShould()
          .beAnnotatedWith("jakarta.ws.rs.Path")
          .because("ADR-007: Public endpoints belong in the api layer, not the engine layer");
}
