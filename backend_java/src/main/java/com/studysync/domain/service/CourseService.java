/* FILE PURPOSE: Is kurallari ve use-case akislari; controller ve repository arasinda orkestrasyon. */

package com.studysync.domain.service;

import com.studysync.domain.dto.ActionResultDto;
import com.studysync.domain.dto.CourseDto;
import java.util.List;
import org.springframework.stereotype.Service;

/**
 * Ders kataloğu ve zorluk oylaması.
 *
 * <p><b>getCourses()</b>: Tüm dersleri veya kullanıcının bölümüne göre filtrelenmiş listeyi döndürün.
 * Ortalama zorluk ve oy sayısı aggregate sorgu ile hesaplanabilir (rating tablosu).
 *
 * <p><b>rateCourse(courseCode, rating)</b>: 1–5 doğrulaması; kullanıcı başına ders başına tek aktif oy veya
 * güncelleme politikası; başarıda {@code ActionResultDto} ile isteğe bağlı sorumluluk puanı etkisi.
 */
@Service
public class CourseService {

    public List<CourseDto> getCourses() {
        // TODO: JPA/SQL ile doldurun. Flutter boş liste gelirse istemci mock’a düşer.
        return List.of();
    }

    public ActionResultDto rateCourse(String courseCode, Integer rating) {
        // TODO: Persist rating; duplicate kontrolü.
        return new ActionResultDto(true, "Stub: rating for " + courseCode + " = " + rating, null, null);
    }
}
