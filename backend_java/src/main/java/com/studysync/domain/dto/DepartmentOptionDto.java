/* FILE PURPOSE: API veri tasima modeli (request/response); istemci sozlesmesiyle birebir alanlar. */

package com.studysync.domain.dto;

/**
 * Kayıt / profil bölüm seçimi — {@code GET /reference/departments}.
 *
 * <p>Şimdilik sabit iskelet; ileride veritabanı tablosu veya yönetim paneli ile doldurulur.
 */
public record DepartmentOptionDto(String id, String name) {}
