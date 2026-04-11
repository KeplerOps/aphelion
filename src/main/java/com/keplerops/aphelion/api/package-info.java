/**
 * API layer -- server endpoints and client-facing protocol handling.
 *
 * <p>This package must not import from {@code infrastructure.engine} (ADR-002, ADR-007).
 * Authentication, authorization, and observability attach here, not in the kernel.
 */
package com.keplerops.aphelion.api;
