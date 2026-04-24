/* FILE PURPOSE: Is kurallari ve use-case akislari; controller ve repository arasinda orkestrasyon. */

package com.studysync.domain.service;

import com.studysync.domain.dto.ActionResultDto;
import com.studysync.domain.dto.LostItemDto;
import java.util.List;
import org.springframework.stereotype.Service;

/**
 * Kayıp eşya raporları.
 *
 * <p><b>getLostItems()</b>: Süresi dolmamış (ör. 24 saat) kayıtları listeleyin; workspace ile join.
 *
 * <p><b>reportLostItem</b>: Yeni kayıt, {@code reportedAt} sunucu saati; süre sonunda otomatik arşiv/cron.
 */
@Service
public class LostFoundService {

    public List<LostItemDto> getLostItems() {
        // TODO: DB sorgusu. Boş liste → Flutter örnek veriye dönebilir.
        return List.of();
    }

    public ActionResultDto reportLostItem(String workspaceId, String description) {
        // TODO: Validasyon + insert; haritada sarı gösterim için istemci workspaceId kullanıyor.
        return new ActionResultDto(true, "Stub report at " + workspaceId, null, null);
    }
}
