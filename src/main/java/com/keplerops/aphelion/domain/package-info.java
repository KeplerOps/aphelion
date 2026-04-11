/**
 * Domain layer -- business logic and product-defined interfaces.
 *
 * <p>This package must not import from {@code infrastructure.engine} (ADR-002) or any
 * protocol-specific types (ADR-008). Dependency flows inward: {@code api -> domain <-
 * infrastructure}.
 */
package com.keplerops.aphelion.domain;
