/**
 * Engine adapter layer -- kernel integration behind a product-owned boundary.
 *
 * <p>This is the only package that may reference kernel types (ADR-002). Code in {@code domain} and
 * {@code api} must use product-defined interfaces, never kernel types directly.
 */
package com.keplerops.aphelion.infrastructure.engine;
